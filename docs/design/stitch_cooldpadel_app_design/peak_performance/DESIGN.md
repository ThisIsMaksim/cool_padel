---
name: Peak Performance
colors:
  surface: '#0f1513'
  surface-dim: '#0f1513'
  surface-bright: '#343a38'
  surface-container-lowest: '#0a0f0e'
  surface-container-low: '#171d1b'
  surface-container: '#1b211f'
  surface-container-high: '#252b29'
  surface-container-highest: '#303634'
  on-surface: '#dee4e0'
  on-surface-variant: '#bacbbd'
  inverse-surface: '#dee4e0'
  inverse-on-surface: '#2c3230'
  outline: '#859588'
  outline-variant: '#3c4a40'
  surface-tint: '#31e193'
  primary: '#43ed9e'
  on-primary: '#003920'
  primary-container: '#00d084'
  on-primary-container: '#005331'
  inverse-primary: '#006d43'
  secondary: '#c8c6c5'
  on-secondary: '#313030'
  secondary-container: '#4a4949'
  on-secondary-container: '#bab8b7'
  tertiary: '#d4d1d1'
  on-tertiary: '#303030'
  tertiary-container: '#b8b6b6'
  on-tertiary-container: '#484747'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#59fead'
  primary-fixed-dim: '#31e193'
  on-primary-fixed: '#002111'
  on-primary-fixed-variant: '#005231'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1c1b1b'
  on-secondary-fixed-variant: '#474646'
  tertiary-fixed: '#e5e2e1'
  tertiary-fixed-dim: '#c8c6c5'
  on-tertiary-fixed: '#1b1c1c'
  on-tertiary-fixed-variant: '#474746'
  background: '#0f1513'
  on-background: '#dee4e0'
  surface-variant: '#303634'
typography:
  display:
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
  headline-lg-mobile:
    fontFamily: Sora
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-md:
    fontFamily: Sora
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-caps:
    fontFamily: Sora
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.08em
  data-mono:
    fontFamily: Sora
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 24px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 32px
  card-padding: 20px
---

## Brand & Style

This design system is built for high-performance monitoring and wellness tracking. It evokes a sense of precision, elite athleticism, and technical mastery. The aesthetic is rooted in a **Modern Glassmorphic** style—balancing deep, immersive dark surfaces with translucent layers that signify depth and data hierarchy.

The target audience consists of data-driven individuals who value clarity and immediate feedback. The emotional response should be one of focus and motivation, achieved through a "dark-mode-first" interface that reduces eye strain while allowing vibrant semantic accents to pop with high-intensity contrast.

## Colors

The palette is anchored by **Recovery Green (#00D084)**, used sparingly for primary actions and positive metrics. The background utilizes a **Deep Charcoal (#121212)** to maintain true-black depth while allowing for subtle surface layering.

- **Primary:** Vitality and positive performance.
- **Surface 0:** Deep Charcoal for the lowest layout layer.
- **Surface 1:** A slightly lighter charcoal (#1A1A1A) for card backgrounds.
- **Glass:** 20% white overlay with high backdrop-blur (30px+) for navigation and modal overlays.
- **Semantic Red:** #FF4B4B for strain or negative trends.

## Typography

We use **Sora** exclusively to maintain a technical, clean, and futuristic feel. Its geometric construction ensures high legibility on small screens and wearable devices.

Key typographic rules:
- **Tabular Numbers:** All numerical data must use `font-variant-numeric: tabular-nums` to ensure metrics line up vertically in lists and dashboards.
- **Visual Hierarchy:** Use `label-caps` for section headers and metadata to provide a distinct stylistic break from body copy.
- **Display Type:** Reserved for hero metrics (e.g., Daily Strain score or Heart Rate).

## Layout & Spacing

The layout follows an **8px grid system** (with 4px sub-increments) to ensure mathematical harmony. 

- **Fluid Grid:** Content should adapt to screen width with a standard 12-column structure on desktop and a single column on mobile.
- **Margins:** 16px on mobile devices provides a compact, athletic feel without feeling cramped.
- **Density:** Elements are spaced tightly to allow for high data density, reflecting the technical nature of performance tracking.

## Elevation & Depth

Depth is communicated through **translucency rather than traditional drop shadows.** 

- **Level 0 (Base):** Solid #121212.
- **Level 1 (Cards):** Solid #1A1A1A with a 1px stroke (#FFFFFF10) to define boundaries against the dark background.
- **Level 2 (Glass Surfaces):** Semi-transparent layers (e.g., #FFFFFF08) with a 40px backdrop-blur effect. This is used for bottom navigation bars and floating action menus.
- **Interaction Glow:** Active states or high-performance metrics may emit a subtle outer glow using the primary green at 20% opacity.

## Shapes

The shape language is modern and approachable but retains a structural edge. 

- **Base Radius:** 0.5rem (8px) for small components like inputs and small buttons.
- **Card Radius:** 1rem (16px) for main content containers.
- **Action Elements:** The primary action button and specific metric pills use **Pill-shaped** (fully rounded) geometry to distinguish them from structural layout elements.

## Components

### Bottom Navigation
The navigation bar is a floating glassmorphic element. It features a heavy backdrop blur and a 1px top border. The center of the bar houses a **prominent circular action button** in Recovery Green, which sits slightly elevated above the nav bar's top edge.

### Cards
Cards are high-contrast containers. They use a dark surface (#1A1A1A) and a very subtle 1px border (#FFFFFF15). Padding is generous (20px) to allow data visualizations to breathe.

### Buttons
- **Primary:** Recovery Green background with black text. Pill-shaped.
- **Secondary:** Ghost style with a 1px white-alpha border and white text.
- **Data Chips:** Small, semi-transparent grey pills used to categorize metrics or timeframes (e.g., "7D", "30D").

### Input Fields
Inputs are dark-filled with no background (transparent) but defined by a bottom border or a subtle recessed stroke. Focus states highlight the border in Recovery Green.

### Data Progress Rings
Circular progress indicators use a thick stroke. The "track" is dark charcoal, and the "progress" is the Recovery Green, often featuring a subtle glow to indicate goal completion.