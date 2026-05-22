---
name: Courtside Elite
colors:
  surface: '#fcf9f8'
  surface-dim: '#dcd9d9'
  surface-bright: '#fcf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f2'
  surface-container: '#f0eded'
  surface-container-high: '#eae7e7'
  surface-container-highest: '#e5e2e1'
  on-surface: '#1c1b1b'
  on-surface-variant: '#404943'
  inverse-surface: '#313030'
  inverse-on-surface: '#f3f0ef'
  outline: '#707973'
  outline-variant: '#bfc9c1'
  surface-tint: '#2c694e'
  primary: '#0f5238'
  on-primary: '#ffffff'
  primary-container: '#2d6a4f'
  on-primary-container: '#a8e7c5'
  inverse-primary: '#95d4b3'
  secondary: '#4c5c92'
  on-secondary: '#ffffff'
  secondary-container: '#b2c1ff'
  on-secondary-container: '#3e4e84'
  tertiary: '#802c00'
  on-tertiary: '#ffffff'
  tertiary-container: '#a73c00'
  on-tertiary-container: '#ffcfbe'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b1f0ce'
  primary-fixed-dim: '#95d4b3'
  on-primary-fixed: '#002114'
  on-primary-fixed-variant: '#0e5138'
  secondary-fixed: '#dce1ff'
  secondary-fixed-dim: '#b5c4ff'
  on-secondary-fixed: '#02174b'
  on-secondary-fixed-variant: '#344479'
  tertiary-fixed: '#ffdbce'
  tertiary-fixed-dim: '#ffb598'
  on-tertiary-fixed: '#370e00'
  on-tertiary-fixed-variant: '#7e2c00'
  background: '#fcf9f8'
  on-background: '#1c1b1b'
  surface-variant: '#e5e2e1'
  emerald-accent: '#40916C'
  surface-glass: rgba(255, 255, 255, 0.7)
  deep-navy: '#02275C'
typography:
  display-lg:
    fontFamily: Sora
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Sora
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Sora
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Sora
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Sora
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-lg:
    fontFamily: Sora
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Sora
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  headline-lg-mobile:
    fontFamily: Sora
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-padding: 24px
  stack-gap: 16px
  section-margin: 40px
  gutter: 16px
---

## Brand & Style

The design system is engineered for a premium padel experience, targeting a sophisticated athletic demographic that values both performance and lifestyle. The brand personality is "Refined Energy"—it moves away from the chaotic intensity of traditional sports apps toward a calm, organized, and high-end aesthetic.

The chosen style is **Modern Corporate with Glassmorphic Accents**. It utilizes expansive white space (or deep tonal space in dark mode) to provide "room to breathe," ensuring that high-action photography and player statistics remain the focal point. Subtle translucency and frosted-glass layers are used to create depth without clutter, mimicking the high-end materials of modern padel rackets and court architecture.

## Colors

The palette is anchored by a sophisticated **Sports Green** (#2D6A4F), which replaces the typical neon lime with a more organic, prestigious hue that evokes the premium turf of professional courts. This is paired with a **Deep Navy** derived from the FIP heritage to maintain a sense of authority and global sport standards.

**Color Usage:**
- **Primary Green:** Use for primary actions, success states, and key brand highlights.
- **Secondary Navy:** Use for headers, navigation backgrounds, and primary text to ground the interface.
- **Tertiary Orange:** Reserved exclusively for live match indicators, urgent alerts, and specific "Call to Action" buttons that require high visibility.
- **Adaptive Surfaces:** In light mode, use soft grays and white for background layers. In dark mode, utilize the `#191919` neutral as the base with slightly lighter tonal overlays for containers.

## Typography

The design system exclusively utilizes **Sora** to achieve a clean, high-contrast, and geometric look. Its wide stance and technical details provide an "engineered" feel suitable for sports performance metrics.

**Scalability & Hierarchy:**
- **High-Contrast Scale:** Use a significant jump between labels and headlines to create clear information architecture.
- **Case Styling:** Use `Label-LG` in uppercase with increased letter spacing for category headers and small metadata to differentiate from body text.
- **Numerical Data:** Leverage Sora's geometric numerals for scoreboards and player stats, ensuring they are bolded for immediate readability.

## Layout & Spacing

This design system follows a **Fluid Grid** model with generous interior margins to evoke a high-end editorial feel. 

- **Responsive Strategy:** A 12-column grid is used for desktop (max-width 1280px), transitioning to a 4-column grid for mobile.
- **Whitespace:** Emphasize vertical rhythm by using `section-margin` between different content blocks (e.g., "Upcoming Matches" vs "Top Players").
- **Consistency:** All spacing must be a multiple of the `base` 8px unit to maintain a mathematical balance across the UI.

## Elevation & Depth

Visual hierarchy is conveyed through **Glassmorphism** and **Ambient Shadows**. Instead of heavy black shadows, the design system uses tinted, diffused shadows that take on the hue of the background surface.

- **Tonal Layers:** Surfaces are stacked using subtle lightness shifts. In dark mode, the "lowest" surface is `#191919`, while cards sit on a `#252525` surface.
- **Glassmorphism:** Apply a `backdrop-filter: blur(12px)` to sticky navigation bars and modal overlays. Use a 1px semi-transparent white border on glass elements to simulate the edge of a lens.
- **Soft Depth:** Use a "Medium" elevation for active cards: `0px 10px 30px rgba(0, 0, 0, 0.08)` in light mode.

## Shapes

The shape language is consistently "Rounded," utilizing a **12px base radius** for all primary containers and buttons. This strikes a balance between the precision of professional sports and the approachability of a lifestyle app.

- **Standard Elements:** Buttons, Input Fields, and Cards use the 12px radius (`0.75rem`).
- **Large Elements:** Featured promo banners or large modal containers should use `rounded-xl` (1.5rem / 24px) to emphasize their container status.
- **Interactive States:** Maintain the radius on focus states and hover effects to ensure a unified silhouette.

## Components

### Buttons
- **Primary:** Solid `primary_color` (Green) with white text. 12px roundedness. No border.
- **Secondary:** Semi-transparent Navy or outlined Green for less critical actions.
- **Ghost:** Use for "View All" or navigation links, using `label-lg` typography.

### Cards
- **Scoreboard Cards:** Use a subtle glass effect or white background with a 1px `E0E0E0` border. High-contrast Sora bold for scores.
- **Player Profiles:** Utilize large imagery clipped with a 12px radius, with names overlaid using a subtle gradient scrim for legibility.

### Input Fields
- Understated styling: A light gray fill with a 12px corner radius. On focus, the border transitions to the primary sports green with a soft outer glow.

### Chips & Badges
- **Live Indicator:** Tertiary Orange background with white text. Use a pulsing animation for "Live" matches.
- **Category Chips:** Small, pill-shaped (32px radius) with a low-opacity Green background and dark Green text.

### Selection Controls
- Checkboxes and Radios should use the primary Green when checked. Use the 12px logic: checkboxes should have a slight 4px corner radius rather than being sharp or perfectly circular.