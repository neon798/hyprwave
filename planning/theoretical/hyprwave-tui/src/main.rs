use ratatui::{
    backend::CrosstermBackend,
    widgets::{Block, Borders, List, ListItem, Paragraph},
    Terminal,
};
use crossterm::{
    event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use std::io;

#[derive(Clone)]
enum Screen {
    MainMenu,
    Updater,
    Installer,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let mut current_screen = Screen::MainMenu;
    let menu_items = vec!["Update System", "Install Software", "Exit"];

    loop {
        terminal.draw(|f| {
            let size = f.size();
            let block = Block::default().title("Hyprwave TUI").borders(Borders::ALL);

            match current_screen {
                Screen::MainMenu => {
                    let items: Vec<ListItem> = menu_items
                        .iter()
                        .map(|i| ListItem::new(*i))
                        .collect();
                    let list = List::new(items)
                        .block(block)
                        .highlight_style(ratatui::style::Style::default().bg(ratatui::style::Color::Cyan));
                    f.render_widget(list, size);
                }
                Screen::Updater => {
                    let text = Paragraph::new("Universal Updater\n\n[ U ] Update Base Image (bootc)\n[ F ] Update Flatpaks\n[ A ] Update All\n[ B ] Back")
                        .block(block);
                    f.render_widget(text, size);
                }
                Screen::Installer => {
                    let text = Paragraph::new("One-Click Installer\n\nCategories:\n- Office (LibreOffice)\n- Gaming (Steam + tools)\n- Networking (Tailscale)\n- Privacy (LibreWolf, Mullvad, Tor)\n\n[ Enter ] Install selected\n[ B ] Back")
                        .block(block);
                    f.render_widget(text, size);
                }
            }
        })?;

        if let Event::Key(key) = event::read()? {
            match current_screen {
                Screen::MainMenu => match key.code {
                    KeyCode::Char('1') | KeyCode::Up => current_screen = Screen::Updater,
                    KeyCode::Char('2') => current_screen = Screen::Installer,
                    KeyCode::Char('q') | KeyCode::Esc => break,
                    _ => {}
                },
                Screen::Updater => match key.code {
                    KeyCode::Char('b') | KeyCode::Esc => current_screen = Screen::MainMenu,
                    KeyCode::Char('u') => { /* run bootc update */ }
                    KeyCode::Char('f') => { /* run flatpak update */ }
                    KeyCode::Char('a') => { /* run all */ }
                    _ => {}
                },
                Screen::Installer => match key.code {
                    KeyCode::Char('b') | KeyCode::Esc => current_screen = Screen::MainMenu,
                    // TODO: handle selection + install
                    _ => {}
                },
            }
        }
    }

    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen, DisableMouseCapture)?;
    terminal.show_cursor()?;
    Ok(())
}
