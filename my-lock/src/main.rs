mod background;
mod drawing;
mod inputs;
mod jpg;
mod pam;
mod prompt;
mod randr;
mod saver;

use background::{AlignX, AlignY, Background, FitMode};
use inputs::{kbd_init, grab_inputs};
use saver::create_saver_window;

use xcb::{x};
use xkbcommon::xkb;
use zeroize::Zeroize;

use crate::prompt::PasswordBox;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let (conn, screen_num) = xcb::Connection::connect(None).unwrap();
    let setup = conn.get_setup();
    let screen = setup.roots().nth(screen_num as usize).unwrap();

    // ID for screensaver window
    let win = conn.generate_id();

    // Create a window via conn.send_request
    create_saver_window(&conn, screen, win)?;
    // Grab keyboard and pointer input
    grab_inputs(&conn, screen)?;

    // Create Cairo Context and Surface for Window
    let (ct, surface) = drawing::create_surface(&conn, screen, screen_num, &win);
    // Initialize background from .png to cairo surface
    let bg = Background::surface_from_png("/home/thomas/.config/i3/moon_wallpaper_3780x2205.png")?;

    // Init xkbcommon
    let kbd_state = kbd_init();

    // Generate password prompt box
    let pwd_box = PasswordBox::init(
        &conn,
        screen,
        300.0,
        40.0,
        None
    )?;

    // Password buffer
    let mut buffer = String::new();


    loop {
        match conn.wait_for_event()? {
            xcb::Event::X(x::Event::Expose(_)) => {
                let win_w: f64 = screen.width_in_pixels().into();
                let win_h: f64 = screen.height_in_pixels().into();

                bg.draw_background(&ct, win_w, win_h, FitMode::Cover(AlignX::Center, AlignY::Center));
                // bg.draw_background(&ct, win_w, win_h, FitMode::Stretch);
                pwd_box.update_box(&ct, &buffer, false);

                surface.flush();
                conn.flush()?;
            }
            xcb::Event::X(x::Event::KeyPress(ev)) => {
                let code = ev.detail();
                let sym = kbd_state.key_get_one_sym(code.into());
                match sym {
                    xkb::Keysym::Return => {
                        if let Err(e) = pam::authenticate("thomas", &buffer) {
                            println!("{}", e);
                            buffer.zeroize();
                            pwd_box.update_box(&ct, &buffer, true);
                            surface.flush();
                            conn.flush()?;
                        } else {
                            buffer.zeroize();
                            break;
                        }
                    }
                    xkb::Keysym::BackSpace => {
                        buffer.pop();
                        pwd_box.update_box(&ct, &buffer, false);
                        surface.flush();
                        conn.flush()?;
                    }
                    _ => {
                        let utf8 = kbd_state.key_get_utf8(code.into());
                        buffer.push_str(&utf8);
                        pwd_box.update_box(&ct, &buffer, false);
                        surface.flush();
                        conn.flush()?;
                    }
                }
            }
            _ => {
                // eprintln!("{:#?}", e);
            }
        }
    }
    conn.send_request(&x::UngrabKeyboard { time: x::CURRENT_TIME });
    conn.send_request(&x::UngrabPointer { time: x::CURRENT_TIME });
    Ok(())
}
