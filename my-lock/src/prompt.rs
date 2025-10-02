pub struct PasswordBox {
    x: f64,
    y: f64,
    width: f64,
    height: f64
}

impl PasswordBox {
    pub fn init(
        conn: &xcb::Connection,
        screen: &xcb::x::Screen,
        box_w: f64,
        box_h: f64,
        offset: Option<(f64, f64)>
    ) -> Result<Self, Box<dyn std::error::Error>> {
        let mon_dims = crate::randr::get_primary_mon_dimensions(conn, screen)?.unwrap_or_default();

        let (x, y) = if let Some((dx, dy)) = offset {
            ((mon_dims.width as f64 - box_w) / 2.0 + mon_dims.x as f64 + dx,
            (mon_dims.height as f64 - box_h) / 2.0 + mon_dims.y as f64 + dy)
        } else {
            ((mon_dims.width as f64 - box_w) / 2.0 + mon_dims.x as f64,
            (mon_dims.height as f64 - box_h) / 2.0 + mon_dims.y as f64)
        };

        Ok(Self {
            width: box_w,
            height: box_h,
            x,
            y,
        })
    }

    pub fn update_box(
        &self,
        ct: &cairo::Context,
        password: &str,
        err: bool
    ) {
        let shadow_offset = 5.0;
        // Limit drawing area
        ct.save().unwrap();

        // Create shadow for password input
        ct.set_source_rgba(0.0, 0.0, 0.0, 0.5);
        rounded_rect(ct, self.x + shadow_offset, self.y + shadow_offset, self.width, self.height, 10.0);
        ct.fill().unwrap();

        // Create box for password input
        ct.set_source_rgba(0.2, 0.2, 0.2, 0.7);
        // ct.rectangle(self.x, self.y, self.width, self.height);
        rounded_rect(ct, self.x, self.y, self.width, self.height, 10.0);
        ct.fill().unwrap();

        // Create border for password input
        if !err {
            ct.set_source_rgba(0.8, 0.8, 0.8, 0.7);
        } else {
            ct.set_source_rgba(0.8, 0.0, 0.0, 0.7);
        }
        rounded_rect(ct, self.x, self.y, self.width, self.height, 10.0);
        // ct.rectangle(self.x, self.y, self.width, self.height);
        ct.stroke().unwrap();

        // 5. Render password dots
        let dot_radius = 4.0;
        let spacing = 10.0;
        let start_x = self.x + 20.0;
        let center_y = self.y + self.height / 2.0;

        ct.set_source_rgba(0.8, 0.8, 0.8, 0.7);
        for (i, _) in password.chars().enumerate() {
            let cx = start_x + i as f64 * spacing;
            ct.arc(cx, center_y, dot_radius, 0.0, 2.0 * std::f64::consts::PI);
            ct.fill().unwrap();
        }
        ct.restore().unwrap();
    }
}

fn rounded_rect(ct: &cairo::Context, x: f64, y: f64, w: f64, h: f64, r: f64) {
    let degrees = std::f64::consts::PI / 180.0;
    ct.new_sub_path();
    ct.arc(x + w - r, y + r, r, -90.0 * degrees, 0.0 * degrees);
    ct.arc(x + w - r, y + h - r, r, 0.0 * degrees, 90.0 * degrees);
    ct.arc(x + r, y + h - r, r, 90.0 * degrees, 180.0 * degrees);
    ct.arc(x + r, y + r, r, 180.0 * degrees, 270.0 * degrees);
    ct.close_path();
}
