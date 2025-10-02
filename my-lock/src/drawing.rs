use cairo::{XCBConnection, XCBSurface, XCBVisualType};
use xcb::Xid;
use xcb_sys::{xcb_depth_next, xcb_depth_visuals_iterator, xcb_get_setup, xcb_screen_allowed_depths_iterator, xcb_screen_next, xcb_setup_roots_iterator, xcb_setup_t, xcb_visualtype_next};


pub fn create_surface(
    conn: &xcb::Connection,
    screen: &xcb::x::Screen,
    screen_num: i32,
    win: &xcb::x::Window
) -> (cairo::Context, cairo::XCBSurface)
{
    // 3. Prepare Cairo connection + visual
    let cairo_conn = unsafe {
        // Safe cast since cairo and xcb refer to the same pointer
        XCBConnection::from_raw_none(conn.get_raw_conn() as *mut _)
    };

    // Find the screen's visual type manually
    let visual = unsafe {
        XCBVisualType::from_raw_none(find_visual(
                // Safe cast since xcb and xcb_sys refer to the same pointer
                xcb_get_setup(conn.get_raw_conn() as *mut _),
                screen_num,
                screen.root_visual())
            // Safe cast since xcb_sys and cairo refer to the same pointer
            as *mut _
        )
    };

    // 4. Create Cairo surface + context tied to the X11 window
    let surface = XCBSurface::create(
        &cairo_conn,
        &cairo::XCBDrawable(win.resource_id()),
        &visual,
        screen.width_in_pixels().into(),
        screen.height_in_pixels().into(),
    ).unwrap();
    let ct = cairo::Context::new(&surface).unwrap();

    (ct, surface)
}

// Helper function to retrieve the pointer to the visual type
fn find_visual(
    setup: *const xcb_setup_t,
    screen_num: i32,
    root_visual: u32,
) -> *mut xcb_sys::xcb_visualtype_t { unsafe {
    // step to the right screen
    let mut s_iter = xcb_setup_roots_iterator(setup);
    for _ in 0..screen_num {
        xcb_screen_next(&mut s_iter);
    }
    let screen: *mut xcb_sys::xcb_screen_t = s_iter.data;

    // iterate allowed depths
    let mut d_iter = xcb_screen_allowed_depths_iterator(screen);
    while d_iter.rem != 0 {
        // iterate visuals in this depth
        let mut v_iter = xcb_depth_visuals_iterator(d_iter.data);
        while v_iter.rem != 0 {
            let vis = v_iter.data;
            if (*vis).visual_id == root_visual {
                return vis;
            }
            xcb_visualtype_next(&mut v_iter);
        }
        xcb_depth_next(&mut d_iter);
    }
    std::ptr::null_mut()
}}
