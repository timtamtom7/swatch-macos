# Swatch — Brand Guide

## App Overview

Swatch is a native macOS color picker and palette manager living in the menu bar. It offers an eyedropper tool, saved palettes, color harmony calculations, and contrast checking — with a widget extension for quick access.

---

## Icon Concept

**Primary icon:** A stylized eyedropper tip releasing a circular color drop. The drop holds a subtle spectrum gradient inside to hint at the color-picking nature. The eyedropper body is rendered in a neutral dark gray so the released color drop becomes the focal point.

**Alternative compositions:**
- A color wheel with an eyedropper cursor overlay
- Three overlapping translucent color circles (CMYK-style) that converge to form a fourth

**Design principles:** Minimal, flat, no heavy gradients in the icon container. The color drop should feel liquid and fresh. All icon variants work on both light and dark macOS appearances.

**Do NOT:** Use a rainbow fill on the entire icon — it fights with any user-chosen accent color that the app might adopt. Keep the icon body neutral and let the "output" color be the star.

---

## Color Palette

| Role | Name | Hex | Usage |
|------|------|-----|-------|
| Background | Chalk White | `#FAFAFA` | Main popover/app background (light mode) |
| Background Alt | Deep Ink | `#1C1C1E` | Main popover/app background (dark mode) |
| Surface | Light Gray | `#F5F5F7` | Cards, panels, tab content area |
| Surface Alt | Soft Black | `#2C2C2E` | Cards in dark mode |
| Border | Silver | `#E0E0E3` | Dividers, outlines |
| Text Primary | Near Black | `#1A1A1A` | Headings, primary labels |
| Text Secondary | Cool Gray | `#6E6E73` | Captions, secondary info |
| Accent | Adaptive | `#007AFF` | Interactive elements, selected states |
| Accent Alt | Violet | `#AF52DE` | Harmony/gradient accents |
| Success | Mint | `#30D158` | Confirmation states |
| Danger | Coral Red | `#FF453A` | Destructive actions, errors |

> **Note:** Swatch is color-agnostic by nature — the app's UI should never compete with the colors being picked. Neutral base palette ensures content (user colors) is always the hero.

---

## Typography

**Font family:** SF Pro (system font)

| Element | Weight | Size |
|---------|--------|------|
| Window Title | Semibold | 13pt |
| Section Header | Medium | 12pt |
| Body / Labels | Regular | 12pt |
| Captions / Hints | Regular | 10pt |
| Color Hex Code | SF Mono | 12pt |

**Guidelines:**
- Hex codes, RGB/HSB values always rendered in `SF Mono` to preserve alignment and readability
- No custom fonts — Swatch ships on macOS system fonts only
- Line height: 1.4× for body, 1.2× for compact labels

---

## Visual Motif

**Core motif: The color drop.**
- Use a single liquid color drop as the primary visual accent throughout the app
- Spectrum gradient (rainbow arc) as a subtle background element in the Harmony tab
- Contrast matrix rendered as a clean checkerboard grid (light/dark squares) to evoke accessibility tooling

**Icon library references:** SF Symbols primarily. Custom illustrations (for onboarding) should lean into:
- Soft rounded shapes (no sharp geometric corners)
- Translucent fills with subtle inner shadows to mimic depth
- A limited palette (3–4 colors per illustration) matching the brand colors

**Patterns:** Never use distracting background patterns. The canvas should feel clean — like a Figma artboard or Xcode canvas.

---

## Size Behavior

| Context | Width | Height | Notes |
|---------|-------|--------|-------|
| Menu bar popover | 320pt | 400pt | Eyedropper, Picker, Palettes tabs |
| Settings window | 480pt | 360pt | Preferences, integrations |
| Widget (small) | 158pt | 158pt | Single color swatch + copy action |
| Widget (medium) | 338pt | 158pt | Recent 4 colors + quick pick |
| Widget (large) | 338pt | 354pt | Full palette preview + pick |

**Adaptive:** All popover content scrolls within the fixed frame. No dynamic resizing of the popover window at runtime.
