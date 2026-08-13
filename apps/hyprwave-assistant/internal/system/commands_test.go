package system

import (
	"strings"
	"testing"
)

func TestPlanUpdate(t *testing.T) {
	cmds, err := PlanUpdate(TargetAll, false)
	if err != nil {
		t.Fatal(err)
	}
	if len(cmds) != 2 {
		t.Fatalf("len=%d", len(cmds))
	}
	if cmds[0].Name != "flatpak" || cmds[1].Name != "bootc" {
		t.Fatalf("order: %+v %+v", cmds[0], cmds[1])
	}
	if !cmds[1].RebootHint {
		t.Fatal("bootc should hint reboot")
	}
	if cmds[1].NeedsRoot != true {
		t.Fatal("bootc needs root")
	}

	check, err := PlanUpdate(TargetFlatpak, true)
	if err != nil {
		t.Fatal(err)
	}
	if len(check) != 1 || check[0].Args[0] != "remote-ls" {
		t.Fatalf("check plan: %+v", check)
	}
}

func TestPlanUpdateUnknown(t *testing.T) {
	_, err := PlanUpdate(Target("nope"), false)
	if err == nil {
		t.Fatal("expected error")
	}
}

func TestFormatPlanDryRun(t *testing.T) {
	cmds, _ := PlanUpdate(TargetBase, false)
	s := FormatDryRun(cmds)
	if !strings.Contains(s, "Dry-run") {
		t.Fatal(s)
	}
	if !strings.Contains(s, "bootc upgrade") {
		t.Fatal(s)
	}
	if !strings.Contains(s, "never forced") {
		t.Fatal(s)
	}
	if !strings.Contains(FormatPlan(cmds), "Command plan") {
		t.Fatal(FormatPlan(cmds))
	}
}

func TestFlatpakInstallCmd(t *testing.T) {
	c, err := PlanInstall("org.libreoffice.LibreOffice")
	if err != nil {
		t.Fatal(err)
	}
	if c.Shell() != "flatpak install -y flathub org.libreoffice.LibreOffice" {
		t.Fatal(c.Shell())
	}
	_, err = PlanInstall("  ")
	if err == nil {
		t.Fatal("empty id")
	}
}

func TestCmdArgv(t *testing.T) {
	c := FlatpakUpdateCmd()
	av := c.Argv()
	if av[0] != "flatpak" || av[1] != "update" {
		t.Fatalf("%v", av)
	}
}

func TestClassifyError(t *testing.T) {
	err := ClassifyError(errString("sudo: a password is required"), "bootc upgrade")
	if !strings.Contains(err.Error(), "elevated privileges") {
		t.Fatal(err)
	}
	err = ClassifyError(errString("network is unreachable"), "flatpak update")
	if !strings.Contains(err.Error(), "offline") {
		t.Fatal(err)
	}
}

type errString string

func (e errString) Error() string { return string(e) }

func TestDetectNeedsRebootStagedNone(t *testing.T) {
	if DetectNeedsReboot("Staged: none\nBooted: yes") {
		t.Fatal("false positive")
	}
}
