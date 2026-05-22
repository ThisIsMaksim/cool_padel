---
name: Kinetic Court
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#444933'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#747a60'
  outline-variant: '#c4c9ac'
  surface-tint: '#506600'
  primary: '#506600'
  on-primary: '#ffffff'
  primary-container: '#ccff00'
  on-primary-container: '#5b7300'
  inverse-primary: '#abd600'
  secondary: '#585e6f'
  on-secondary: '#ffffff'
  secondary-container: '#dadff3'
  on-secondary-container: '#5d6273'
  tertiary: '#525e7f'
  on-tertiary: '#ffffff'
  tertiary-container: '#e8ecff'
  on-tertiary-container: '#5e6a8c'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#c3f400'
  primary-fixed-dim: '#abd600'
  on-primary-fixed: '#161e00'
  on-primary-fixed-variant: '#3c4d00'
  secondary-fixed: '#dde2f6'
  secondary-fixed-dim: '#c1c6d9'
  on-secondary-fixed: '#151b29'
  on-secondary-fixed-variant: '#414756'
  tertiary-fixed: '#dae2ff'
  tertiary-fixed-dim: '#bac6ec'
  on-tertiary-fixed: '#0d1a38'
  on-tertiary-fixed-variant: '#3a4666'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  headline-xl:
    fontFamily: Sora
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Sora
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Sora
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  headline-md:
    fontFamily: Sora
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-lg:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Hanken Grotesk
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 40px
  xl: 64px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 48px
---

## Brand & Style

The design system is built for the high-octane environment of padel tennis. It captures the velocity and agility of the sport through a "Kinetic Modernism" style—fusing the precision of corporate SaaS with the raw energy of performance athletics.

The visual language emphasizes motion and accessibility. It targets an active community ranging from casual hobbyists to competitive athletes. The UI should feel immediate, responsive, and motivating. Large, purposeful whitespace is utilized to frame high-action sports photography, while vibrant color accents guide the user toward their next match or tournament.

## Colors

The palette is driven by the iconic high-visibility "Electric Lime" of a padel ball. This primary color is reserved strictly for calls to action, progress indicators, and interactive highlights. 

To ensure professional readability, this is balanced against "Deep Charcoal Navy," which provides the necessary weight and contrast for navigation and typography. A "Crisp White" background maintains a clean, modern aesthetic, while a secondary navy is used for depth in cards and containers.

## Typography

The typography strategy uses **Sora** for headlines to convey a technical yet bold geometric energy. Its wide stance and heavy weights give tournament names and scores an authoritative, broadcast-style presence.

For body content and stats, **Hanken Grotesk** is used for its exceptional legibility and contemporary proportions. Labels and data points often utilize uppercase styling with slight letter spacing to mimic the look of athletic jerseys and professional sports scoreboards.

## Layout & Spacing

The layout follows a 12-column fluid grid for desktop and a 4-column grid for mobile. Spacing is based on an 8px rhythmic scale to maintain mathematical consistency. 

The design system prioritizes "breathability" in the vertical axis to prevent the app from feeling cluttered with data. On mobile, margins are generous (20px) to ensure touch targets for buttons and interactive cards are easily accessible during physical activity or on the go.

## Elevation & Depth

Visual hierarchy is established through "Ambient Depth." Instead of heavy shadows, this design system utilizes very soft, diffused shadows (0% spread, high blur) to lift cards slightly off the white background. 

Layers are further defined through tonal changes:
- **Level 0:** Base White background.
- **Level 1:** Light Grey (#F8F9FA) for secondary content sections.
- **Level 2:** Elevated White cards with subtle 5% opacity navy shadows.
- **Active State:** The Electric Lime color is used to "backlight" certain elements, creating a subtle neon glow effect when a game is live or a match is confirmed.

## Shapes

The shape language is "Softly Technical." A consistent 0.5rem (8px) radius is applied to standard UI components to make the interface feel approachable and modern. 

Buttons and specific game-status tags may utilize "pill" shapes (Level 3) to differentiate them from static content cards. Icon containers use a soft-square approach (Level 2) to maintain a cohesive structural grid.

## Components

### Buttons
Primary buttons use the Electric Lime background with Deep Charcoal Navy text for maximum contrast. They feature a slight lift on hover and a "pressed" state that darkens the lime slightly.

### Interactive Game Cards
Cards are the core of the experience. They use a white background, Level 2 elevation, and a 1px soft border. Team names are set in Headline-MD, with the match time highlighted in a small, pill-shaped secondary color badge.

### Rankings & Lists
Rankings utilize a "clean row" approach. Player avatars are circular, while rank numbers use the Sora font in a bold weight. Alternating row colors (white and #F8F9FA) help legibility in long tournament tables.

### Input Fields
Fields use a 2px stroke. When focused, the stroke transitions to the primary Electric Lime color, providing a clear visual cue for the user.

### Actionable Chips
Used for filtering game types (e.g., "Singles," "Doubles," "Competitive"). Chips use a transparent background with a navy border, flipping to a solid navy background when active.