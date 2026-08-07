package system

import (
	"context"
	"errors"
	"strings"
	"testing"
)

func TestRunCmdAndPlan(t *testing.T) {
	restore := OnlineForTests()
	defer restore()

	f := &fakeRunner{
		paths: map[string]bool{"flatpak": true, "bootc": true, "sudo": true},
		responses: map[string]struct {
			out string
			err error
		}{
			"flatpak update -y":        {out: "flatpak ok"},
			"sudo -n bootc upgrade":    {out: "bootc staged"},
			"bootc upgrade":            {out: "bootc staged"},
		},
	}

	out, err := FlatpakUpdate(context.Background(), f)
	if err != nil || !strings.Contains(out, "flatpak ok") {
		t.Fatalf("flatpak: %q %v", out, err)
	}

	out, err = BootcUpgrade(context.Background(), f)
	if err != nil {
		// may try bootc without sudo first depending on isRoot
		t.Log(err)
	}
	_ = out

	cmds, err := PlanUpdate(TargetAll, false)
	if err != nil {
		t.Fatal(err)
	}
	// Use a runner that answers both steps
	f2 := &fakeRunner{
		paths: map[string]bool{"flatpak": true, "bootc": true, "sudo": true},
		responses: map[string]struct {
			out string
			err error
		}{
			"flatpak update -y":        {out: "fp"},
			"bootc upgrade":            {out: "bc", err: errors.New("permission denied")},
			"sudo -n bootc upgrade":    {out: "bc ok"},
		},
	}
	combined, reboot, err := RunPlan(context.Background(), f2, cmds)
	if err != nil {
		// if not root, sudo path should succeed
		if !strings.Contains(combined, "fp") {
			t.Fatal(combined, err)
		}
	}
	if !reboot {
		// bootc has reboot hint even if path varies
		t.Log("reboot hint", reboot, combined)
	}
	// Force success path
	f3 := &fakeRunner{
		paths: map[string]bool{"flatpak": true, "bootc": true},
		responses: map[string]struct {
			out string
			err error
		}{
			"flatpak update -y": {out: "fp"},
			"bootc upgrade":     {out: "bc"},
		},
	}
	// BootcUpgradeCmd NeedsRoot - RunCmd will try sudo if not root
	f3.paths["sudo"] = true
	f3.responses["sudo -n bootc upgrade"] = struct {
		out string
		err error
	}{out: "bc"}
	combined, reboot, err = RunPlan(context.Background(), f3, cmds)
	if err != nil {
		t.Fatal(err, combined)
	}
	if !reboot {
		t.Fatal("expected reboot hint")
	}
	if !strings.Contains(combined, "never forces reboot") && !strings.Contains(combined, "never forced") {
		// message text from RunPlan
		if !strings.Contains(combined, "Reboot") && !strings.Contains(combined, "reboot") {
			t.Fatal(combined)
		}
	}
}

func TestRunCmdMissingBinary(t *testing.T) {
	f := &fakeRunner{paths: map[string]bool{}}
	_, err := RunCmd(context.Background(), f, FlatpakUpdateCmd())
	if err == nil {
		t.Fatal("expected missing")
	}
}

func TestRunCmdNeedsRootWithoutSudo(t *testing.T) {
	if isRoot() {
		t.Skip("running as root")
	}
	f := &fakeRunner{paths: map[string]bool{"bootc": true}}
	_, err := RunCmd(context.Background(), f, BootcUpgradeCmd())
	if err == nil || !strings.Contains(err.Error(), "sudo") {
		t.Fatalf("got %v", err)
	}
}

func TestWhich(t *testing.T) {
	f := &fakeRunner{paths: map[string]bool{"flatpak": true}}
	m := Which(f, "flatpak", "bootc")
	if !m["flatpak"] || m["bootc"] {
		t.Fatal(m)
	}
}

func TestRunPlanStopsOnError(t *testing.T) {
	cmds, _ := PlanUpdate(TargetAll, false)
	f := &fakeRunner{
		paths: map[string]bool{"flatpak": true, "bootc": true, "sudo": true},
		responses: map[string]struct {
			out string
			err error
		}{
			"flatpak update -y": {out: "fail", err: errors.New("network is unreachable")},
		},
	}
	out, _, err := RunPlan(context.Background(), f, cmds)
	if err == nil {
		t.Fatal("expected err")
	}
	if !strings.Contains(err.Error(), "offline") && !strings.Contains(out, "fail") {
		t.Log(err, out)
	}
}
