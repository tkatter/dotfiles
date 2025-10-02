use std::fs::File;

use cairo::{Context, Format, ImageSurface};
use image::GenericImageView; // for .dimensions()

pub fn load_jpeg_as_cairo(path: &str) -> cairo::ImageSurface {
    // Load JPEG into an RGBA8 buffer
    let img = image::open(path).expect("failed to load image").to_rgba8();
    let (width, height) = img.dimensions();
    let data = img.into_raw(); // Vec<u8>

    let bgra = rgba_to_bgra(data);

    // Create cairo surface with same dimensions
    let mut surface = ImageSurface::create(
        Format::ARgb32,
        width as i32,
        height as i32,
    ).expect("Couldn't create surface");

    {
        // Copy decoded pixels into cairo buffer
        let mut surf_data = surface.data().unwrap();
        // Note: Cairo wants premultiplied ARGB32 (endian ≈ BGRA on x86_64)
        // You may need to swizzle RGBA to BGRA depending on your use case.
        surf_data.copy_from_slice(&bgra);
    }

    surface
}

fn run_jpg() {
    let surface = load_jpeg_as_cairo("moon_wallpaper_3780x2205.jpg");
    let cr = Context::new(&surface).unwrap();

    // Example: write it back to PNG to test
    let mut file = File::options().create(true).write(true).truncate(true).open("test-out.png").unwrap();
    surface.write_to_png(&mut file).unwrap();
}

fn rgba_to_bgra(rgba: Vec<u8>) -> Vec<u8> {
    let mut out = Vec::with_capacity(rgba.len());
    let pixels = rgba.chunks_exact(4);

    for px in pixels {
        let r = px[0] as u32;
        let g = px[1] as u32;
        let b = px[2] as u32;
        let a = px[3] as u32;

        let r = (r * a + 127) / 255;
        let g = (g * a + 127) / 255;
        let b = (b * a + 127) / 255;

        out.push(b as u8);
        out.push(g as u8);
        out.push(r as u8);
        out.push(a as u8);
    }
    out
}
