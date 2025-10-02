use xcb::x;

#[derive(Debug)]
pub struct PrimaryDisplay {
    pub width: u16,
    pub height: u16,
    pub x: i16,
    pub y: i16
}

impl Default for PrimaryDisplay {
    fn default() -> Self {
        Self { width: 1920, height: 1920, x: 0, y: 0 }
    }
}

pub fn get_primary_mon_dimensions(
    conn: &xcb::Connection,
    screen: &x::Screen
) -> Result<Option<PrimaryDisplay>, xcb::Error>
{
    let cookie = conn.send_request(&xcb::randr::GetMonitors { window: screen.root(), get_active: true });
    let a = conn.wait_for_reply(cookie)?;

    let Some(pos) = a.monitors().position(|m| {
        m.primary()
    }) else {
        return Ok(None)
    };

    let Some(m_info) = a.monitors().nth(pos) else {
        return Ok(None)
    };

    Ok(Some(PrimaryDisplay {
        width: m_info.width(),
        height: m_info.height(),
        x: m_info.x(),
        y: m_info.y()
    }))
}
