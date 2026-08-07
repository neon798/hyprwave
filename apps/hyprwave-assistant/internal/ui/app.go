// Package ui implements the Bubble Tea Hyprwave Assistant TUI.
package ui

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/charmbracelet/bubbles/viewport"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"

	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/catalog"
	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/kb"
	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/style"
	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/system"
)

// Tab indices.
const (
	tabUpdater = iota
	tabInstaller
	tabKB
	tabAbout
	tabCount
)

var tabNames = []string{"UPDATER", "INSTALLER", "KNOWLEDGE BASE", "ABOUT"}

// Config seeds the root model.
type Config struct {
	Runner  system.Runner
	Catalog *catalog.Catalog
	KB      *kb.Store
	DataDir string
	Version string
	Theme   string // best-effort active theme name
}

// Model is the root multi-tab application.
type Model struct {
	cfg    Config
	active int
	width  int
	height int

	// Updater
	status       system.Status
	statusLoaded bool
	statusErr    string
	busy         bool
	busyLabel    string
	lastOutput   string
	lastErr      string

	// Confirm dialog
	confirm *confirmState

	// Installer
	flatItems []flatItem
	instCursor int
	instFilter string
	filtering  bool

	// KB
	kbResults []kb.Article
	kbCursor  int
	kbQuery   string
	kbSearch  bool
	kbReading bool
	kbBody    viewport.Model

	// Shared log viewport (updater/installer output)
	logVP viewport.Model
	showLog bool
}

type flatItem struct {
	Category string
	Item     catalog.Item
}

type confirmState struct {
	title   string
	message string
	action  confirmAction
	danger  bool // shows reboot warning chrome
	// step 1 = first confirm, step 2 = second confirm (double-confirm for mutations)
	step int
}

type confirmAction int

const (
	actionUpdateBase confirmAction = iota
	actionUpdateFlatpaks
	actionUpdateAll
	actionInstall
)

// Messages
type statusMsg struct {
	status system.Status
}

type cmdDoneMsg struct {
	label  string
	output string
	err    error
	reboot bool // hint after base upgrade
}

// New creates the root model.
func New(cfg Config) Model {
	if cfg.Runner == nil {
		cfg.Runner = system.ExecRunner{}
	}
	if cfg.Version == "" {
		cfg.Version = "dev"
	}
	m := Model{
		cfg:   cfg,
		logVP: viewport.New(80, 12),
		kbBody: viewport.New(80, 16),
	}
	if cfg.Catalog != nil {
		for _, row := range cfg.Catalog.FlatList() {
			m.flatItems = append(m.flatItems, flatItem{Category: row.Category, Item: row.Item})
		}
	}
	if cfg.KB != nil {
		m.kbResults = cfg.KB.Search("")
	}
	return m
}

func (m Model) Init() tea.Cmd {
	return m.refreshStatus()
}

func (m Model) refreshStatus() tea.Cmd {
	r := m.cfg.Runner
	return func() tea.Msg {
		return statusMsg{status: system.CollectStatus(r)}
	}
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
		innerW := max(20, msg.Width-4)
		innerH := max(5, msg.Height-10)
		m.logVP.Width = innerW
		m.logVP.Height = max(5, innerH/2)
		m.kbBody.Width = innerW
		m.kbBody.Height = max(5, innerH)
		return m, nil

	case statusMsg:
		m.status = msg.status
		m.statusLoaded = true
		m.busy = false
		return m, nil

	case cmdDoneMsg:
		m.busy = false
		m.busyLabel = ""
		m.lastOutput = msg.output
		if msg.err != nil {
			m.lastErr = msg.err.Error()
		} else {
			m.lastErr = ""
		}
		if msg.reboot {
			if m.lastOutput != "" {
				m.lastOutput += "\n\n"
			}
			m.lastOutput += "⚠ Base image updated (or staged). Reboot to apply the new deployment."
		}
		m.showLog = true
		m.logVP.SetContent(m.formatLog())
		// Refresh status after mutating ops.
		return m, m.refreshStatus()

	case tea.KeyMsg:
		return m.handleKey(msg)
	}

	// Viewport scroll when showing log or reading KB.
	if m.showLog {
		var cmd tea.Cmd
		m.logVP, cmd = m.logVP.Update(msg)
		return m, cmd
	}
	if m.kbReading {
		var cmd tea.Cmd
		m.kbBody, cmd = m.kbBody.Update(msg)
		return m, cmd
	}
	return m, nil
}

func (m Model) handleKey(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	key := msg.String()

	// Global quit when not in a modal filter.
	if key == "ctrl+c" {
		return m, tea.Quit
	}

	// Confirm dialog takes over.
	if m.confirm != nil {
		return m.handleConfirmKey(key)
	}

	// Filter / search input modes.
	if m.filtering {
		return m.handleFilterKey(key)
	}
	if m.kbSearch {
		return m.handleKBSearchKey(key)
	}
	if m.kbReading {
		return m.handleKBReadKey(key)
	}
	if m.showLog {
		switch key {
		case "esc", "q", "enter", "backspace":
			m.showLog = false
			return m, nil
		case "j", "down":
			m.logVP.LineDown(1)
			return m, nil
		case "k", "up":
			m.logVP.LineUp(1)
			return m, nil
		case "pgdown", "ctrl+d":
			m.logVP.HalfViewDown()
			return m, nil
		case "pgup", "ctrl+u":
			m.logVP.HalfViewUp()
			return m, nil
		}
		return m, nil
	}

	if m.busy {
		// Only allow quit while busy.
		if key == "q" {
			return m, tea.Quit
		}
		return m, nil
	}

	switch key {
	case "q":
		return m, tea.Quit
	case "tab", "right", "l":
		m.active = (m.active + 1) % tabCount
		return m, nil
	case "shift+tab", "left", "h":
		m.active = (m.active + tabCount - 1) % tabCount
		return m, nil
	case "1":
		m.active = tabUpdater
		return m, nil
	case "2":
		m.active = tabInstaller
		return m, nil
	case "3":
		m.active = tabKB
		return m, nil
	case "4":
		m.active = tabAbout
		return m, nil
	}

	switch m.active {
	case tabUpdater:
		return m.handleUpdaterKey(key)
	case tabInstaller:
		return m.handleInstallerKey(key)
	case tabKB:
		return m.handleKBKey(key)
	case tabAbout:
		// no special keys
	}
	return m, nil
}

func (m Model) handleConfirmKey(key string) (tea.Model, tea.Cmd) {
	switch key {
	case "y", "Y", "enter":
		if m.confirm.step < 2 {
			// Second confirmation required for all destructive actions.
			m.confirm.step = 2
			m.confirm.title = "Confirm again: " + m.confirm.title
			m.confirm.message = "Second confirmation required.\n\n" + m.confirm.message +
				"\n\nPress Y again to execute, or N to cancel."
			return m, nil
		}
		act := m.confirm.action
		m.confirm = nil
		return m.startConfirmed(act)
	case "n", "N", "esc", "q":
		m.confirm = nil
		return m, nil
	}
	return m, nil
}

func (m Model) handleUpdaterKey(key string) (tea.Model, tea.Cmd) {
	switch key {
	case "r", "R":
		m.busy = true
		m.busyLabel = "Refreshing status…"
		return m, m.refreshStatus()
	case "b", "B":
		if ban := m.status.Preflight.OfflineBanner(); ban != "" && m.statusLoaded {
			m.lastErr = ban
			m.lastOutput = "Base upgrades need network. KB and catalog still work offline."
			m.showLog = true
			m.logVP.SetContent(m.formatLog())
			return m, nil
		}
		plan, _ := system.PlanUpdate(system.TargetBase, false)
		m.confirm = &confirmState{
			title: "Update base system (bootc)",
			message: "This stages a new deployment. Reboot is NEVER forced.\n\n" +
				system.FormatPlan(plan) + "\nMay need root/sudo/polkit.\nDouble-confirm required (Y twice).",
			action: actionUpdateBase,
			danger: true,
			step:   1,
		}
		return m, nil
	case "f", "F":
		if ban := m.status.Preflight.OfflineBanner(); ban != "" && m.statusLoaded {
			m.lastErr = ban
			m.lastOutput = "Flatpak updates need network. KB and catalog still work offline."
			m.showLog = true
			m.logVP.SetContent(m.formatLog())
			return m, nil
		}
		plan, _ := system.PlanUpdate(system.TargetFlatpak, false)
		m.confirm = &confirmState{
			title: "Update Flatpaks",
			message: "Updates installed Flatpaks (usually no reboot).\n\n" +
				system.FormatPlan(plan) + "\nDouble-confirm required (Y twice).",
			action: actionUpdateFlatpaks,
			step:   1,
		}
		return m, nil
	case "a", "A":
		if ban := m.status.Preflight.OfflineBanner(); ban != "" && m.statusLoaded {
			m.lastErr = ban
			m.lastOutput = "Update-all needs network. KB and catalog still work offline."
			m.showLog = true
			m.logVP.SetContent(m.formatLog())
			return m, nil
		}
		plan, _ := system.PlanUpdate(system.TargetAll, false)
		m.confirm = &confirmState{
			title: "Update all",
			message: "Flatpaks first, then base image. Reboot is NEVER forced.\n\n" +
				system.FormatPlan(plan) + "\nDouble-confirm required (Y twice).",
			action: actionUpdateAll,
			danger: true,
			step:   1,
		}
		return m, nil
	case "o", "O":
		if m.lastOutput != "" || m.lastErr != "" {
			m.showLog = true
			m.logVP.SetContent(m.formatLog())
		}
		return m, nil
	}
	return m, nil
}

func (m Model) handleInstallerKey(key string) (tea.Model, tea.Cmd) {
	items := m.visibleInstallItems()
	switch key {
	case "j", "down":
		if m.instCursor < len(items)-1 {
			m.instCursor++
		}
		return m, nil
	case "k", "up":
		if m.instCursor > 0 {
			m.instCursor--
		}
		return m, nil
	case "/":
		m.filtering = true
		return m, nil
	case "esc":
		m.instFilter = ""
		m.instCursor = 0
		return m, nil
	case "enter", "i":
		if len(items) == 0 {
			return m, nil
		}
		it := items[m.instCursor].Item
		msg := fmt.Sprintf("Install %s?\n\n%s\nSource: %s\n\n", it.Name, it.Description, it.InstallLabel())
		if it.Source == catalog.SourceLayer {
			msg += system.LayerNote(it.Packages) + "\n\n(Layer items show instructions only — not auto-installed.)"
			// Layer notes are non-destructive; single confirm is enough, but step=2 skips second prompt.
			m.confirm = &confirmState{
				title:   "Layer package (manual)",
				message: msg + "\n\nPress Y to show instructions in the log.",
				action:  actionInstall,
				step:    2,
			}
		} else {
			if ban := m.status.Preflight.OfflineBanner(); ban != "" && m.statusLoaded {
				m.lastErr = ban
				m.lastOutput = "Install needs network. Browse the catalog offline; install when online."
				m.showLog = true
				m.logVP.SetContent(m.formatLog())
				return m, nil
			}
			msg += "This runs `flatpak install -y flathub <id>`.\nDouble-confirm required (Y twice).\n\nProceed?"
			m.confirm = &confirmState{
				title:   "Install " + it.Name,
				message: msg,
				action:  actionInstall,
				step:    1,
			}
		}
		return m, nil
	}
	return m, nil
}

func (m Model) handleFilterKey(key string) (tea.Model, tea.Cmd) {
	switch key {
	case "esc", "enter":
		m.filtering = false
		m.instCursor = 0
		return m, nil
	case "backspace":
		if len(m.instFilter) > 0 {
			m.instFilter = m.instFilter[:len(m.instFilter)-1]
		}
		return m, nil
	default:
		if len(key) == 1 && key[0] >= 32 {
			m.instFilter += key
			m.instCursor = 0
		}
		return m, nil
	}
}

func (m Model) handleKBKey(key string) (tea.Model, tea.Cmd) {
	switch key {
	case "j", "down":
		if m.kbCursor < len(m.kbResults)-1 {
			m.kbCursor++
		}
		return m, nil
	case "k", "up":
		if m.kbCursor > 0 {
			m.kbCursor--
		}
		return m, nil
	case "/":
		m.kbSearch = true
		return m, nil
	case "esc":
		m.kbQuery = ""
		if m.cfg.KB != nil {
			m.kbResults = m.cfg.KB.Search("")
		}
		m.kbCursor = 0
		return m, nil
	case "enter":
		if len(m.kbResults) == 0 {
			return m, nil
		}
		a := m.kbResults[m.kbCursor]
		m.kbReading = true
		m.kbBody.SetContent(a.Body)
		m.kbBody.GotoTop()
		return m, nil
	}
	return m, nil
}

func (m Model) handleKBSearchKey(key string) (tea.Model, tea.Cmd) {
	switch key {
	case "esc":
		m.kbSearch = false
		return m, nil
	case "enter":
		m.kbSearch = false
		if m.cfg.KB != nil {
			m.kbResults = m.cfg.KB.Search(m.kbQuery)
		}
		m.kbCursor = 0
		return m, nil
	case "backspace":
		if len(m.kbQuery) > 0 {
			m.kbQuery = m.kbQuery[:len(m.kbQuery)-1]
		}
		return m, nil
	default:
		if len(key) == 1 && key[0] >= 32 {
			m.kbQuery += key
		}
		return m, nil
	}
}

func (m Model) handleKBReadKey(key string) (tea.Model, tea.Cmd) {
	switch key {
	case "esc", "q", "backspace":
		m.kbReading = false
		return m, nil
	case "j", "down":
		m.kbBody.LineDown(1)
		return m, nil
	case "k", "up":
		m.kbBody.LineUp(1)
		return m, nil
	case "pgdown", "ctrl+d", " ":
		m.kbBody.HalfViewDown()
		return m, nil
	case "pgup", "ctrl+u":
		m.kbBody.HalfViewUp()
		return m, nil
	}
	return m, nil
}

// startConfirmed sets busy state on the model and returns the async command.
func (m Model) startConfirmed(act confirmAction) (Model, tea.Cmd) {
	r := m.cfg.Runner
	switch act {
	case actionUpdateBase:
		m.busy = true
		m.busyLabel = "Running bootc upgrade…"
		return m, runPlanCmd(r, system.TargetBase)
	case actionUpdateFlatpaks:
		m.busy = true
		m.busyLabel = "Running flatpak update…"
		return m, runPlanCmd(r, system.TargetFlatpak)
	case actionUpdateAll:
		m.busy = true
		m.busyLabel = "Updating Flatpaks then base…"
		return m, runPlanCmd(r, system.TargetAll)
	case actionInstall:
		items := m.visibleInstallItems()
		if len(items) == 0 || m.instCursor >= len(items) {
			return m, nil
		}
		it := items[m.instCursor].Item
		if it.Source == catalog.SourceLayer {
			note := system.LayerNote(it.Packages)
			return m, func() tea.Msg {
				return cmdDoneMsg{label: "layer note", output: note, err: nil}
			}
		}
		m.busy = true
		m.busyLabel = "Installing " + it.Name + "…"
		appID := it.Flatpak
		return m, func() tea.Msg {
			ctx, cancel := context.WithTimeout(context.Background(), system.LongTimeout)
			defer cancel()
			out, err := system.FlatpakInstall(ctx, r, appID)
			return cmdDoneMsg{label: "flatpak install " + appID, output: out, err: err}
		}
	}
	return m, nil
}

func runPlanCmd(r system.Runner, target system.Target) tea.Cmd {
	return func() tea.Msg {
		cmds, err := system.PlanUpdate(target, false)
		if err != nil {
			return cmdDoneMsg{label: string(target), err: err}
		}
		ctx, cancel := context.WithTimeout(context.Background(), system.LongTimeout)
		defer cancel()
		out, reboot, err := system.RunPlan(ctx, r, cmds)
		return cmdDoneMsg{label: string(target), output: out, err: err, reboot: reboot}
	}
}

func (m Model) visibleInstallItems() []flatItem {
	if m.instFilter == "" {
		return m.flatItems
	}
	q := strings.ToLower(m.instFilter)
	var out []flatItem
	for _, it := range m.flatItems {
		hay := strings.ToLower(it.Item.Name + " " + it.Item.ID + " " + it.Item.Description + " " + it.Category)
		if strings.Contains(hay, q) {
			out = append(out, it)
		}
	}
	return out
}

func (m Model) formatLog() string {
	var b strings.Builder
	if m.lastErr != "" {
		b.WriteString(style.Error.Render("Error:") + "\n" + m.lastErr + "\n\n")
	}
	if m.lastOutput != "" {
		b.WriteString(m.lastOutput)
	}
	if b.Len() == 0 {
		return "(no output)"
	}
	return b.String()
}

func (m Model) View() string {
	if m.width == 0 {
		m.width = 80
		m.height = 24
	}

	themeBit := ""
	if m.cfg.Theme != "" {
		themeBit = " · " + m.cfg.Theme
	}
	header := style.Title.Render("◈ Hyprwave Assistant") + " " + style.Muted.Render("v"+m.cfg.Version+themeBit)
	tabs := style.RenderTabs(tabNames, m.active)

	var body string
	switch {
	case m.confirm != nil:
		body = m.viewConfirm()
	case m.showLog:
		body = m.viewLog()
	case m.busy:
		body = style.Highlight.Render("⏳ "+m.busyLabel) + "\n\n" + style.Muted.Render("Please wait… (Ctrl+C to force quit)")
	default:
		switch m.active {
		case tabUpdater:
			body = m.viewUpdater()
		case tabInstaller:
			body = m.viewInstaller()
		case tabKB:
			if m.kbReading {
				body = m.viewKBArticle()
			} else {
				body = m.viewKBList()
			}
		case tabAbout:
			body = m.viewAbout()
		}
	}

	help := m.viewHelp()
	content := lipgloss.JoinVertical(lipgloss.Left,
		header,
		tabs,
		"",
		body,
		"",
		help,
	)
	return style.Frame.Width(max(40, m.width-2)).Render(content)
}

func (m Model) viewConfirm() string {
	c := m.confirm
	stepLabel := style.Muted.Render(fmt.Sprintf("confirm %d/2", max(1, c.step)))
	title := style.Highlight.Render(c.title) + "  " + stepLabel
	msg := style.Body.Render(c.message)
	warn := ""
	if c.danger {
		warn = "\n" + style.Warning.Render("⚠ REBOOT WARNING: base changes apply on next boot — never forced here.")
	}
	prompt := "\n\n"
	if c.step < 2 {
		prompt += style.Success.Render("[Y]") + " continue to 2nd confirm   " + style.Error.Render("[N]") + " cancel"
	} else {
		prompt += style.Success.Render("[Y]") + " execute now   " + style.Error.Render("[N]") + " cancel"
	}
	return title + "\n\n" + msg + warn + prompt
}

func (m Model) viewLog() string {
	title := style.Title.Render("Command output") + "  " + style.Muted.Render("(Esc to close)")
	return title + "\n" + m.logVP.View()
}

func (m Model) viewUpdater() string {
	var b strings.Builder
	b.WriteString(style.Title.Render("System updater") + "\n\n")

	if !m.statusLoaded {
		b.WriteString(style.Muted.Render("Loading status…"))
		return b.String()
	}

	// Preflight strip
	pf := m.status.Preflight
	b.WriteString(style.Highlight.Render("Preflight") + "  ")
	b.WriteString(style.Muted.Render(fmt.Sprintf("online=%s  root=%s  bootc=%s  flatpak=%s",
		boolYN(pf.Online), boolYN(pf.IsRoot), boolYN(pf.HasBootc), boolYN(pf.HasFlatpak))) + "\n")
	if ban := pf.OfflineBanner(); ban != "" {
		b.WriteString(style.Error.Render("  "+ban) + "\n")
		b.WriteString(style.Muted.Render("  KB + catalog still work offline. Updates/installs need network.") + "\n")
	}
	if len(pf.Warnings) > 0 {
		for _, w := range pf.Warnings {
			b.WriteString(style.Warning.Render("  ⚠ "+w) + "\n")
		}
	}
	b.WriteString("\n")

	// bootc
	b.WriteString(style.Highlight.Render("Base (bootc)") + "\n")
	if m.status.BootcAvailable {
		if m.status.BootcError != "" {
			b.WriteString(style.Error.Render(m.status.BootcError) + "\n")
		} else {
			b.WriteString(style.Muted.Render(truncateLines(m.status.BootcStatus, 10)) + "\n")
		}
		if m.status.NeedsReboot {
			b.WriteString(style.Warning.Render("⚠ Staged/pending changes — reboot yourself when ready (never forced).") + "\n")
		}
	} else {
		b.WriteString(style.Muted.Render(emptyOr(m.status.BootcError, "bootc unavailable")) + "\n")
	}

	b.WriteString("\n" + style.Highlight.Render("Flatpak") + "\n")
	if m.status.FlatpakAvailable {
		if m.status.FlatpakError != "" {
			b.WriteString(style.Error.Render(m.status.FlatpakError) + "\n")
		} else {
			b.WriteString(style.Muted.Render(truncateLines(m.status.FlatpakStatus, 8)) + "\n")
		}
	} else {
		b.WriteString(style.Muted.Render(emptyOr(m.status.FlatpakError, "flatpak unavailable")) + "\n")
	}

	if m.lastErr != "" {
		b.WriteString("\n" + style.Error.Render("Last error: ") + m.lastErr + "\n")
	} else if m.lastOutput != "" {
		b.WriteString("\n" + style.Success.Render("Last operation completed.") + style.Muted.Render(" Press o to view output.") + "\n")
	}

	b.WriteString("\n" + style.Muted.Render("Actions: ") +
		"[r] refresh  [b] update base  [f] update flatpaks  [a] update all  [o] output")
	b.WriteString("\n" + style.Muted.Render("CLI: hyprwave-assistant update --dry-run | --check | --yes"))
	return b.String()
}

func (m Model) viewInstaller() string {
	var b strings.Builder
	b.WriteString(style.Title.Render("Software installer") + "\n")
	if len(m.flatItems) == 0 {
		b.WriteString("\n" + style.Warning.Render("Catalog empty") + "\n")
		b.WriteString(style.Muted.Render("No catalog.toml loaded from:\n  "+m.cfg.DataDir+"\n") + "\n")
		b.WriteString(style.Muted.Render("Set HYPRWAVE_ASSISTANT_DATA or rebuild the image with assistant data."))
		return b.String()
	}
	if m.filtering {
		b.WriteString(style.CyanSearch("Filter: "+m.instFilter+"█") + "\n\n")
	} else if m.instFilter != "" {
		b.WriteString(style.Muted.Render("Filter: "+m.instFilter+"  (Esc clear, / edit)") + "\n\n")
	} else {
		b.WriteString(style.Muted.Render("Curated catalog — Enter to install, / to filter") + "\n\n")
	}

	items := m.visibleInstallItems()
	if len(items) == 0 {
		b.WriteString(style.Muted.Render("(no packages match filter — Esc to clear)"))
		return b.String()
	}

	// Keep cursor in range.
	if m.instCursor >= len(items) {
		m.instCursor = len(items) - 1
	}
	if m.instCursor < 0 {
		m.instCursor = 0
	}

	maxShow := 14
	start := 0
	if m.instCursor >= maxShow {
		start = m.instCursor - maxShow + 1
	}
	end := min(len(items), start+maxShow)

	var lastCat string
	for i := start; i < end; i++ {
		row := items[i]
		if row.Category != lastCat {
			b.WriteString(style.Highlight.Render("▸ "+row.Category) + "\n")
			lastCat = row.Category
		}
		src := string(row.Item.Source)
		line := fmt.Sprintf("  %s  %s", row.Item.Name, style.Muted.Render("("+src+")"))
		if i == m.instCursor {
			b.WriteString(style.Selected.Render("› "+row.Item.Name) + " " + style.Muted.Render(row.Item.Description) + "\n")
		} else {
			b.WriteString(line + "\n")
		}
		_ = src
	}
	if end < len(items) {
		b.WriteString(style.Muted.Render(fmt.Sprintf("  … %d more", len(items)-end)) + "\n")
	}
	return b.String()
}

func (m Model) viewKBList() string {
	var b strings.Builder
	b.WriteString(style.Title.Render("Knowledge Base") + "\n")
	if m.cfg.KB == nil || len(m.cfg.KB.Articles) == 0 {
		b.WriteString("\n" + style.Warning.Render("No articles loaded") + "\n")
		b.WriteString(style.Muted.Render("Expected kb/*.md under:\n  "+m.cfg.DataDir+"\n"))
		return b.String()
	}
	if m.kbSearch {
		b.WriteString(style.CyanSearch("Search: "+m.kbQuery+"█") + "\n\n")
	} else if m.kbQuery != "" {
		b.WriteString(style.Muted.Render("Query: "+m.kbQuery+"  (Esc clear, / search)") + "\n\n")
	} else {
		b.WriteString(style.Muted.Render("Need-to-know about Hyprwave — Enter to read, / to search") + "\n\n")
	}

	if len(m.kbResults) == 0 {
		b.WriteString(style.Muted.Render("(no articles match — Esc to clear search)"))
		return b.String()
	}
	if m.kbCursor >= len(m.kbResults) {
		m.kbCursor = len(m.kbResults) - 1
	}

	for i, a := range m.kbResults {
		line := fmt.Sprintf("%s — %s", a.Title, a.Preview)
		if i == m.kbCursor {
			b.WriteString(style.Selected.Render("› "+a.Title) + "\n")
			if a.Preview != "" {
				b.WriteString(style.Muted.Render("  "+a.Preview) + "\n")
			}
		} else {
			b.WriteString("  " + line + "\n")
		}
	}
	return b.String()
}

func (m Model) viewKBArticle() string {
	title := ""
	if m.kbCursor < len(m.kbResults) {
		title = m.kbResults[m.kbCursor].Title
	}
	return style.Title.Render(title) + "  " + style.Muted.Render("(Esc back)") + "\n" + m.kbBody.View()
}

func (m Model) viewAbout() string {
	var b strings.Builder
	b.WriteString(style.Title.Render("About Hyprwave Assistant") + "\n\n")
	b.WriteString(style.Body.Render("Version: ") + m.cfg.Version + "\n")
	b.WriteString(style.Body.Render("Data:    ") + style.Muted.Render(m.cfg.DataDir) + "\n")
	theme := m.cfg.Theme
	if theme == "" {
		theme = "synthwave (default)"
	}
	b.WriteString(style.Body.Render("Theme:   ") + theme + "\n")
	if m.statusLoaded {
		if ban := m.status.Preflight.OfflineBanner(); ban != "" {
			b.WriteString(style.Error.Render(ban) + "\n")
			b.WriteString(style.Muted.Render("Offline-first: KB + catalog work; remote update/install blocked.") + "\n")
		} else {
			b.WriteString(style.Success.Render("Network probe: online") + "\n")
		}
	}
	b.WriteString("\n")
	b.WriteString("A single TUI for updates, curated installs, and distro knowledge.\n")
	b.WriteString("Built with Go + Bubble Tea + Lip Gloss.\n")
	b.WriteString(style.Muted.Render("Never forces reboot. Double-confirm for mutations. Dry-run always available.\n\n"))
	b.WriteString(style.Highlight.Render("Palette") + "  ")
	b.WriteString(lipgloss.NewStyle().Foreground(style.Pink).Render("■pink ") +
		lipgloss.NewStyle().Foreground(style.Cyan).Render("■cyan ") +
		lipgloss.NewStyle().Foreground(style.Purple).Render("■purple") + "\n\n")
	b.WriteString(style.Muted.Render("CLI: status | update | install | list | kb | version | --help\n"))
	b.WriteString(style.Muted.Render("Theme switcher: hyprwave-theme · App store: FlatArcade\n"))
	b.WriteString(style.Muted.Render("Install layout: /usr/share/hyprwave/assistant/{catalog.toml,kb/*.md}\n\n"))
	tools := system.Which(m.cfg.Runner, "bootc", "flatpak", "ghostty", "sudo")
	b.WriteString(style.Highlight.Render("Host tools") + "\n")
	for _, name := range []string{"bootc", "flatpak", "ghostty", "sudo"} {
		if tools[name] {
			b.WriteString("  " + style.Success.Render("●") + " " + name + "\n")
		} else {
			b.WriteString("  " + style.Error.Render("○") + " " + name + "\n")
		}
	}
	b.WriteString("\n" + style.Muted.Render(fmt.Sprintf("Refreshed context @ %s", time.Now().Format(time.RFC3339))))
	return b.String()
}

func (m Model) viewHelp() string {
	base := "tab/h/l switch  1-4 jump  q quit"
	switch {
	case m.confirm != nil:
		return style.Help.Render("y confirm · n/esc cancel")
	case m.showLog || m.kbReading:
		return style.Help.Render("j/k scroll · esc back · " + base)
	case m.filtering || m.kbSearch:
		return style.Help.Render("type to filter · enter done · esc cancel")
	case m.active == tabUpdater:
		return style.Help.Render("r refresh · b base · f flatpak · a all · o output · " + base)
	case m.active == tabInstaller:
		return style.Help.Render("j/k move · enter install · / filter · " + base)
	case m.active == tabKB:
		return style.Help.Render("j/k move · enter read · / search · " + base)
	default:
		return style.Help.Render(base)
	}
}

func truncateLines(s string, n int) string {
	lines := strings.Split(s, "\n")
	if len(lines) <= n {
		return s
	}
	return strings.Join(lines[:n], "\n") + fmt.Sprintf("\n… (%d more)", len(lines)-n)
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func boolYN(v bool) string {
	if v {
		return "yes"
	}
	return "no"
}

func emptyOr(s, fallback string) string {
	if strings.TrimSpace(s) == "" {
		return fallback
	}
	return s
}
