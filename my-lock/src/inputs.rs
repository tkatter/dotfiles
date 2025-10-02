use xcb::Result;
use xcb::x;
use xcb::Xid;

pub fn grab_inputs(conn: &xcb::Connection, screen: &x::Screen) -> Result<()> {
    let kb = conn.send_request(&x::GrabKeyboard {
        owner_events: false,
        grab_window: screen.root(),
        time: x::CURRENT_TIME,
        pointer_mode: x::GrabMode::Async,
        keyboard_mode: x::GrabMode::Async
    });
    if conn.wait_for_reply(kb)?.status() != x::GrabStatus::Success {
        println!("Failed to get keyboard");
        return Ok(());
    }
    let pt = conn.send_request(&x::GrabPointer {
        owner_events: false,
        grab_window: screen.root(),
        time: x::CURRENT_TIME,
        pointer_mode: x::GrabMode::Async,
        keyboard_mode: x::GrabMode::Async,
        cursor: x::CURSOR_NONE,
        event_mask: (
            x::EventMask::BUTTON_PRESS |
            x::EventMask::BUTTON_RELEASE |
            x::EventMask::POINTER_MOTION
        ),
        confine_to: x::Window::none()
    });
    if conn.wait_for_reply(pt)?.status() != x::GrabStatus::Success {
        println!("Failed to get pointer");
        return Ok(());
    }

    Ok(())
}

pub fn kbd_init() -> xkbcommon::xkb::State {
    use xkbcommon::xkb;
    let ctx = xkb::Context::new(xkb::CONTEXT_NO_FLAGS);
    let keymap = xkb::Keymap::new_from_names(
        &ctx, "", "", "", "", None, xkb::KEYMAP_COMPILE_NO_FLAGS
    ).expect("Unable to compile keymap");
    xkb::State::new(&keymap)
}
