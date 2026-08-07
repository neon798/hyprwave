// Generates COSMIC dark theme key files for a Hyprwave palette.
// Uses the real cosmic-theme crate so derived component colors match
// what cosmic-settings would produce.
//
// Usage:
//   themegen --name hyprwave --bg 15052e --accent ff2d95 --text e0e0ff \
//            --neutral b967ff --hint 00f0ff --out /path/to/XDG_CONFIG_HOME
//
// Writes under $out/cosmic/com.system76.CosmicTheme.Dark{,.Builder}/v1/

use cosmic_config::CosmicConfigEntry;
use cosmic_theme::{Theme, ThemeBuilder};
use palette::Srgba;
use std::env;
use std::path::PathBuf;
use std::process::ExitCode;

fn c(hex: u32) -> Srgba {
    Srgba::new(
        ((hex >> 16) & 0xff) as f32 / 255.0,
        ((hex >> 8) & 0xff) as f32 / 255.0,
        (hex & 0xff) as f32 / 255.0,
        1.0,
    )
}

fn parse_hex(s: &str) -> Result<u32, String> {
    let s = s.trim().trim_start_matches('#');
    u32::from_str_radix(s, 16).map_err(|e| format!("bad hex '{s}': {e}"))
}

fn usage() -> ! {
    eprintln!(
        "Usage: themegen --name NAME --bg HEX --accent HEX --text HEX \
         --neutral HEX --hint HEX --out DIR"
    );
    std::process::exit(2);
}

fn main() -> ExitCode {
    let mut name = String::from("hyprwave");
    let mut bg = 0x15052e_u32;
    let mut accent = 0xff2d95_u32;
    let mut text = 0xe0e0ff_u32;
    let mut neutral = 0xb967ff_u32;
    let mut hint = 0x00f0ff_u32;
    let mut out = PathBuf::from(".");

    let args: Vec<String> = env::args().skip(1).collect();
    let mut i = 0;
    while i < args.len() {
        match args[i].as_str() {
            "--name" => {
                i += 1;
                name = args.get(i).cloned().unwrap_or_else(|| usage());
            }
            "--bg" => {
                i += 1;
                bg = parse_hex(args.get(i).map(|s| s.as_str()).unwrap_or_else(|| usage()))
                    .unwrap_or_else(|e| {
                        eprintln!("{e}");
                        std::process::exit(1);
                    });
            }
            "--accent" => {
                i += 1;
                accent = parse_hex(args.get(i).map(|s| s.as_str()).unwrap_or_else(|| usage()))
                    .unwrap_or_else(|e| {
                        eprintln!("{e}");
                        std::process::exit(1);
                    });
            }
            "--text" => {
                i += 1;
                text = parse_hex(args.get(i).map(|s| s.as_str()).unwrap_or_else(|| usage()))
                    .unwrap_or_else(|e| {
                        eprintln!("{e}");
                        std::process::exit(1);
                    });
            }
            "--neutral" => {
                i += 1;
                neutral = parse_hex(args.get(i).map(|s| s.as_str()).unwrap_or_else(|| usage()))
                    .unwrap_or_else(|e| {
                        eprintln!("{e}");
                        std::process::exit(1);
                    });
            }
            "--hint" => {
                i += 1;
                hint = parse_hex(args.get(i).map(|s| s.as_str()).unwrap_or_else(|| usage()))
                    .unwrap_or_else(|e| {
                        eprintln!("{e}");
                        std::process::exit(1);
                    });
            }
            "--out" => {
                i += 1;
                out = PathBuf::from(args.get(i).cloned().unwrap_or_else(|| usage()));
            }
            "-h" | "--help" => usage(),
            other => {
                eprintln!("unknown arg: {other}");
                usage();
            }
        }
        i += 1;
    }

    // cosmic-config writes under $XDG_CONFIG_HOME/cosmic/...
    // Ensure parent exists; CosmicConfigEntry creates leaf files.
    let config_home = out;
    std::fs::create_dir_all(config_home.join("cosmic")).ok();
    // SAFETY: cosmic-config reads XDG_CONFIG_HOME at write time
    // (std::env::set_var is process-local; fine for a CLI tool).
    unsafe {
        env::set_var("XDG_CONFIG_HOME", &config_home);
    }

    let mut builder = ThemeBuilder::dark()
        .bg_color(c(bg))
        .accent(c(accent).color)
        .text_tint(c(text).color)
        .neutral_tint(c(neutral).color);
    builder.window_hint = Some(c(hint).color);

    let theme = builder.clone().build();

    let theme_cfg = Theme::dark_config().expect("open dark theme config");
    theme
        .write_entry(&theme_cfg)
        .expect("write generated theme keys");

    let builder_cfg = ThemeBuilder::dark_config().expect("open dark builder config");
    builder
        .write_entry(&builder_cfg)
        .expect("write builder keys");

    // Name key so Appearance shows a friendly label
    let name_path = config_home
        .join("cosmic/com.system76.CosmicTheme.Dark/v1/name");
    if let Some(parent) = name_path.parent() {
        std::fs::create_dir_all(parent).ok();
    }
    // COSMIC stores name as a RON string
    std::fs::write(&name_path, format!("\"{name}\"\n")).ok();

    println!("generated cosmic theme '{name}' → {}", config_home.display());
    ExitCode::SUCCESS
}
