"""Generate an OSRS-themed app icon for the companion app."""
from PIL import Image, ImageDraw, ImageFont
import math
import os


def _scale_poly(points, cx, cy, scale):
    """Scale polygon points toward a center."""
    return [(cx + (px - cx) * scale, cy + (py - cy) * scale) for px, py in points]


def _kite_shield(cx, cy, w, h, s):
    """Generate a classic OSRS kite shield polygon.
    Wide at top, straight sides in upper half, tapering to a point at bottom.
    """
    pts = []
    top = cy - h * 0.45
    mid = cy + h * 0.05       # where the straight part ends and taper starts
    bot = cy + h * 0.55
    half_w = w / 2
    r = int(10 * s)           # corner radius

    # Top-left rounded corner
    for i in range(8):
        t = i / 7
        a = math.pi + t * (math.pi / 2)
        pts.append((cx - half_w + r + r * math.cos(a), top + r + r * math.sin(a)))

    # Top edge
    pts.append((cx + half_w - r, top))

    # Top-right rounded corner
    for i in range(8):
        t = i / 7
        a = -math.pi / 2 + t * (math.pi / 2)
        pts.append((cx + half_w - r + r * math.cos(a), top + r + r * math.sin(a)))

    # Right straight side down to mid
    pts.append((cx + half_w, mid))

    # Right taper to bottom point (gentle curve)
    for i in range(1, 16):
        t = i / 15
        x = cx + half_w * (1 - t ** 1.3)
        y = mid + t * (bot - mid)
        pts.append((x, y))

    # Bottom point
    pts.append((cx, bot))

    # Left taper up from bottom point (mirror)
    for i in range(1, 16):
        t = i / 15
        x = cx - half_w * (1 - (1 - t) ** 1.3)
        y = mid + (1 - t) * (bot - mid)
        pts.append((x, y))

    # Left straight side up
    pts.append((cx - half_w, mid))

    return pts


def draw_osrs_icon(size=256):
    """Create an OSRS-style icon: gold kite shield with crossed swords."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    cx, cy = size / 2, size / 2
    s = size / 256

    # ── Background ──
    m = int(6 * s)
    rad = int(36 * s)
    draw.rounded_rectangle([m, m, size - m, size - m], radius=rad, fill=(22, 15, 5))
    draw.rounded_rectangle([m, m, size - m, size - m], radius=rad,
                           outline=(92, 69, 41, 140), width=max(2, int(2 * s)))

    # ── Crossed swords (drawn BEHIND shield) ──
    sword_half = int(80 * s)
    sw = max(3, int(5 * s))
    angle = math.radians(30)
    shield_cy = cy - int(10 * s)

    for d in (-1, 1):
        a = d * angle
        sin_a, cos_a = math.sin(a), math.cos(a)
        # Blade endpoints
        x1 = cx - sword_half * sin_a
        y1 = shield_cy - sword_half * cos_a
        x2 = cx + sword_half * sin_a
        y2 = shield_cy + sword_half * cos_a

        # Blade shadow
        draw.line([(x1, y1), (x2, y2)], fill=(60, 60, 70, 180), width=sw + max(3, int(3 * s)))
        # Blade body
        draw.line([(x1, y1), (x2, y2)], fill=(185, 195, 210), width=sw)
        # Blade highlight
        draw.line([(x1, y1), (x2, y2)], fill=(215, 220, 235, 160), width=max(1, int(2 * s)))

        # Guard (perpendicular bar near handle end)
        gx = cx + (sword_half * 0.6) * sin_a
        gy = shield_cy + (sword_half * 0.6) * cos_a
        perp = a + math.pi / 2
        gw = int(14 * s)
        draw.line([
            (gx - gw * math.cos(perp), gy + gw * math.sin(perp)),
            (gx + gw * math.cos(perp), gy - gw * math.sin(perp)),
        ], fill=(180, 140, 20), width=max(3, int(5 * s)))
        # Guard highlight
        draw.line([
            (gx - gw * 0.7 * math.cos(perp), gy + gw * 0.7 * math.sin(perp)),
            (gx + gw * 0.7 * math.cos(perp), gy - gw * 0.7 * math.sin(perp)),
        ], fill=(220, 180, 50, 180), width=max(1, int(2 * s)))

        # Handle
        hx1 = gx + int(8 * s) * sin_a
        hy1 = gy + int(8 * s) * cos_a
        hx2 = gx + int(28 * s) * sin_a
        hy2 = gy + int(28 * s) * cos_a
        draw.line([(hx1, hy1), (hx2, hy2)], fill=(70, 45, 18), width=max(3, int(4 * s)))
        # Pommel
        pr = int(4 * s)
        draw.ellipse([hx2 - pr, hy2 - pr, hx2 + pr, hy2 + pr], fill=(180, 140, 20))

    # ── Shield ──
    shield_w = int(110 * s)
    shield_h = int(135 * s)
    sp = _kite_shield(cx, shield_cy, shield_w, shield_h, s)

    # Shield layers (dark to bright for gold gradient feel)
    draw.polygon(sp, fill=(120, 90, 12))
    draw.polygon(_scale_poly(sp, cx, shield_cy, 0.94), fill=(170, 130, 18))
    draw.polygon(_scale_poly(sp, cx, shield_cy, 0.86), fill=(205, 165, 30))
    draw.polygon(_scale_poly(sp, cx, shield_cy - int(8 * s), 0.7), fill=(225, 190, 50, 220))
    draw.polygon(_scale_poly(sp, cx, shield_cy - int(16 * s), 0.45), fill=(240, 210, 75, 160))

    # Shield outline
    draw.polygon(sp, outline=(85, 62, 8), width=max(2, int(3 * s)))

    # Shield inner border (decorative trim)
    trim = _scale_poly(sp, cx, shield_cy, 0.90)
    draw.polygon(trim, outline=(140, 105, 15, 160), width=max(1, int(2 * s)))

    # ── Horizontal band across shield (OSRS style) ──
    band_y = shield_cy - int(25 * s)
    band_hw = int(shield_w * 0.40)
    draw.line([(cx - band_hw, band_y), (cx + band_hw, band_y)],
              fill=(120, 90, 12, 180), width=max(2, int(3 * s)))

    # ── Center emblem: 4-point star ──
    emblem_cy = shield_cy - int(2 * s)
    star_r_out = int(16 * s)
    star_r_in = int(9 * s)
    star_pts = []
    for i in range(8):
        a2 = -math.pi / 2 + i * math.pi / 4
        r = star_r_out if i % 2 == 0 else star_r_in
        star_pts.append((cx + r * math.cos(a2), emblem_cy + r * math.sin(a2)))
    draw.polygon(star_pts, fill=(255, 235, 110), outline=(160, 120, 15))
    # Inner dot
    dot_r = int(4 * s)
    draw.ellipse([cx - dot_r, emblem_cy - dot_r, cx + dot_r, emblem_cy + dot_r],
                 fill=(160, 120, 15))

    # ── "OSRS" text ──
    try:
        fs = int(28 * s)
        font = ImageFont.truetype("arialbd.ttf", fs)
    except (OSError, IOError):
        try:
            font = ImageFont.truetype("arial.ttf", fs)
        except (OSError, IOError):
            font = ImageFont.load_default()

    text = "OSRS"
    bb = draw.textbbox((0, 0), text, font=font)
    tw = bb[2] - bb[0]
    tx = cx - tw / 2
    ty = size - m - int(36 * s)
    draw.text((tx + 2 * s, ty + 2 * s), text, fill=(0, 0, 0, 200), font=font)
    draw.text((tx, ty), text, fill=(255, 217, 102), font=font)

    return img


def main():
    print("Generating OSRS Companion icon...")
    
    # Generate at 256x256 (master size)
    icon_256 = draw_osrs_icon(256)
    
    # Create smaller sizes by resizing
    sizes = [16, 24, 32, 48, 64, 128, 256]
    icons = []
    for sz in sizes:
        if sz == 256:
            icons.append(icon_256)
        else:
            icons.append(icon_256.resize((sz, sz), Image.LANCZOS))
    
    # Save as .ico (Windows icon format with multiple sizes)
    ico_path = os.path.join("windows", "runner", "resources", "app_icon.ico")
    icon_256.save(
        ico_path,
        format='ICO',
        sizes=[(sz, sz) for sz in sizes],
        append_images=icons[:-1],  # All except the 256 which is the base
    )
    print(f"Saved: {ico_path}")
    
    # Also save a PNG preview
    preview_path = "app_icon_preview.png"
    icon_256.save(preview_path)
    print(f"Preview saved: {preview_path}")
    
    print("Done! Rebuild the app with 'flutter run' to see the new icon.")


if __name__ == "__main__":
    main()
