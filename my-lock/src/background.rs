use std::path::PathBuf;

#[derive(PartialEq, Eq, Debug, Clone, Copy)]
pub enum FitMode {
    Contain,
    Cover(AlignX, AlignY),
    Stretch
}

#[derive(PartialEq, Eq, Debug, Clone, Copy)]
pub enum AlignX {
    Left,
    Center,
    Right
}

#[derive(PartialEq, Eq, Debug, Clone, Copy)]
pub enum AlignY {
    Top,
    Center,
    Bottom
}

#[derive(Debug, Clone)]
pub struct Background {
    pub surface: cairo::ImageSurface,
}

impl Background {
    pub fn surface_from_png<P: Into<PathBuf>>(png: P) -> Result<Self, Box<dyn std::error::Error>> {
        use std::fs::File;
        // Load the PNG
        let mut file = File::options().read(true).open(png.into()).unwrap();
        let img = cairo::ImageSurface::create_from_png(&mut file)?;
        Ok(Self {
            surface: img,
        })
    }
}

impl Background {
    pub fn draw_background(
        &self,
        ct: &cairo::Context,
        win_width: f64,
        win_height: f64,
        mode: FitMode
    ) {
        let w: f64 = self.surface.width().into();
        let h: f64 = self.surface.height().into();

        if mode == FitMode::Stretch {
            let sx = win_width / w;
            let sy = win_height / h;
            ct.save().unwrap();
            ct.scale(sx, sy);
            ct.set_source_surface(&self.surface, 0.0, 0.0).unwrap();
            ct.paint().unwrap();
            ct.restore().unwrap();

            return;
        }

        let (scale, new_w, new_h) = match mode {
            FitMode::Contain => {
                let s = f64::min(win_width / w, win_height / h);
                (s, w * s, h * s)
            }
            FitMode::Cover(_, _) => {
                let s = f64::max(win_width / w, win_height / h);
                (s, w * s, h * s)
            }
            _ => unreachable!()
        };

        // alignment
        let (dx, dy) = match mode {
            FitMode::Contain => (
                (win_width - new_w) / 2.0,
                (win_height - new_h) / 2.0,
            ),
            FitMode::Cover(align_x, align_y) => {
                let dx = match align_x {
                    AlignX::Left => 0.0,
                    AlignX::Center => (win_width - new_w) / 2.0,
                    AlignX::Right => win_width - new_w,
                };
                let dy = match align_y {
                    AlignY::Top => 0.0,
                    AlignY::Center => (win_height - new_h) / 2.0,
                    AlignY::Bottom => win_height - new_h,
                };
                (dx, dy)
            }
            _ => unreachable!()
        };

        ct.save().unwrap();
        ct.translate(dx, dy);
        ct.scale(scale, scale);
        ct.set_source_surface(&self.surface, 0.0, 0.0).unwrap();
        ct.paint().unwrap();
        ct.restore().unwrap();
    }
}
