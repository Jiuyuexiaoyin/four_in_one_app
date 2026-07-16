# getready geometry specification

Approved reference: `.ai_reference\branding\getready_brand_board.png` (1254×1254 RGB PNG)

Reference SHA-256: `BACA2369F76B8549276E6B932048E78D4397E589124BEB15BC1FB4E4F5BE019C`

The reference board contains presentation glow and lighting. Production masters deliberately normalize the approved silhouette into flat geometric vectors; they do not crop, trace pixels, embed the board, or reproduce its decorative effects.

## Source canvas and safe area

The canonical mark uses a `1000 × 1000` SVG viewBox. The three-step artwork occupies `x = 200…800` and `y = 275…725`.

- Horizontal safe area: 200 units on each side, exactly 20%.
- Vertical safe area: 275 units on each side, 27.5%.
- Combined artwork center: `(500, 500)`.
- Primary rounded-square background: `(0, 0, 1000, 1000)`, radius 220.

The extra vertical clearance keeps the rising sequence optically centered and resilient under circle, squircle, rounded-square, and vendor adaptive-icon masks.

## Step system

Every step is the same capsule. Variations in the presentation board are antialiasing/glow artifacts and are not copied.

| Step | X | Y | Width | Height | Radius |
|---|---:|---:|---:|---:|---:|
| Top | 500 | 275 | 300 | 110 | 55 |
| Middle | 350 | 445 | 300 | 110 | 55 |
| Bottom | 200 | 615 | 300 | 110 | 55 |

- Horizontal center shift per step: 150 units.
- Vertical center shift per step: 170 units upward.
- Clear vertical gap: 60 units.
- Step aspect ratio: 30:11.
- Corner radius is exactly half the step height, producing stable pill ends.

## Colors

| Token | Hex | Use |
|---|---|---|
| Deep space black | `#0D1117` | Primary tile and splash background; dark neutral on light surfaces |
| Deep gray-blue | `#1A1F28` | Supporting dark neutral |
| Technology green | `#22C55E` | Middle step and `ready` wordmark segment |
| Off-white | `#F1F3F5` | Top/bottom steps and `get` on dark surfaces |

Dark-surface order is off-white / green / off-white from top to bottom. Light-surface order is deep space black / green / deep space black. Monochrome artwork uses one solid color and transparent background.

## Wordmark spacing

The wordmark is always lowercase `getready`. It uses an installed system UI sans-serif at semibold weight; no font file is copied or embedded and no commercial glyph is converted to paths.

- Horizontal master canvas: 1600×400.
- Horizontal mark step size: 120×44, radius 22.
- Mark-to-word gap: 80 units from the mark visual bound at x=320 to `get` at x=400.
- `get` uses the surface-appropriate neutral; `ready` uses technology green.
- Vertical master canvas: 1000×1250, with the wordmark beginning below the mark at y=760.
- Splash master canvas: 1440×2560; canonical mark geometry is scaled by 1.44, followed by the lowercase wordmark and centered tagline.
- Primary tagline: `一步一个脚印，持续前进`.

The generator fails if its approved system font families are unavailable and records the actual resolved families in its output manifest.

## Android-specific geometry

Adaptive foregrounds use a 108×108 viewport. The canonical mark maps to `x = 21.6…86.4`, placing it inside the adaptive safe zone. The dark tile is supplied only by the adaptive background layer and is never baked into the foreground or monochrome layer.

The notification icon uses a separate 24×24 optical master because status-bar artwork needs a larger relative silhouette:

| Step | X | Y | Width | Height | Radius |
|---|---:|---:|---:|---:|---:|
| Top | 12 | 6 | 9 | 3 | 1.5 |
| Middle | 7.5 | 10.5 | 9 | 3 | 1.5 |
| Bottom | 3 | 15 | 9 | 3 | 1.5 |

It is one solid white alpha mask with no tile, green, gradient, shadow, or wordmark.

## Minimum sizes

- Icon-only mark: 24 px minimum when rendered with the documented safe area.
- Notification mark: 24 px native viewport.
- Horizontal wordmark: 160 px wide minimum for routine UI use.
- Vertical logo: 96 px wide minimum.
- Launcher production masters: render from the 1000-unit vector; never upscale a small raster.

At 32 px and 24 px, preserve the exact step count, order, and capsule proportions; do not introduce outlines or merge steps to compensate for size.

## Prohibited distortions

Do not:

- crop production artwork from the reference board;
- alter the three equal step dimensions or their 150/170 rise cadence;
- rotate, skew, stretch, compress, mirror, or reorder the mark;
- recolor individual steps outside the approved dark, light, or monochrome systems;
- place the wordmark inside launcher icons or notification icons;
- bake a rounded-square tile into an adaptive foreground;
- add strokes, thin outlines, blur, gradients, shadows, textures, or embedded rasters to master SVGs;
- change lowercase `getready`, split it with visible spacing, or recolor `get` green;
- reduce the launcher safe area below the documented mask-resilient bounds.
