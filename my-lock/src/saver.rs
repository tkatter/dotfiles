pub fn create_saver_window(
    conn: &xcb::Connection,
    screen: &xcb::x::Screen,
    win: xcb::x::Window
) -> xcb::Result<()> {
    use xcb::x;
        conn.send_request(&x::CreateWindow {
            depth: screen.root_depth(),
            visual: screen.root_visual(),
            wid: win,
            parent: screen.root(),
            x: 0,
            y: 0,
            width: screen.width_in_pixels(),
            height: screen.height_in_pixels(),
            border_width: 0,
            class: x::WindowClass::InputOutput,
            value_list: &[
                x::Cw::BackPixel(screen.black_pixel()),
                x::Cw::OverrideRedirect(true),
                x::Cw::EventMask(
                    x::EventMask::EXPOSURE |
                    x::EventMask::KEY_PRESS
                )
            ]
        });
        conn.send_request(&x::MapWindow { window: win });
        conn.flush()?;
        Ok(())
}
