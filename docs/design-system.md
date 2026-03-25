# Swatch Design System

## Overview

This document outlines the design system for Swatch, ensuring consistency across all UI elements and future iterations.

---

## Colors (App Chrome)

> Note: These colors are for the app's UI chrome, not the color picker itself (which is user-driven).

| Role | Color | Hex |
|------|-------|-----|
| Background | Warm off-white | `#f8f7f5` |
| Surface | Pure white | `#ffffff` |
| Surface Secondary | Light warm gray | `#f2f1ef` |
| Border | Subtle divider | `#e4e2df` |
| Text Primary | Near black | `#1a1a1a` |
| Text Secondary | Medium gray | `#6b6b6b` |
| Text Tertiary | Light gray | `#9a9a9a` |
| Accent | Periwinkle blue | `#5a7df5` |
| Accent Hover | Darker periwinkle | `#4a6de5` |
| Success | Soft green | `#3a9a5a` |
| Warning | Warm amber | `#d4a020` |
| Danger | Soft red | `#c44a4a` |

---

## Typography

All text uses **SF Pro** (system font). Do not import custom fonts.

| Role | Style | Size | Weight |
|------|-------|------|--------|
| Display | SF Pro Display | 20pt | Semibold |
| Headline | SF Pro Text | 16pt | Semibold |
| Body | SF Pro Text | 13pt | Regular |
| Caption | SF Pro Text | 11pt | Regular |
| Mono (color codes) | SF Mono | 12pt | Regular |

### SwiftUI Usage

```swift
Text("Heading")
    .font(.headline)  // 16pt semibold

Text("Body text")
    .font(.body)  // 13pt regular

Text("Caption")
    .font(.caption)  // 11pt regular

Text("#FF6B6B")
    .font(.system(size: 12, design: .monospaced))
```

---

## Spacing (8pt Grid)

| Token | Value |
|-------|-------|
| XS | 4pt |
| S | 8pt |
| M | 16pt |
| L | 24pt |
| XL | 32pt |

---

## Corner Radius

| Element | Radius |
|---------|--------|
| Small elements (swatches) | 6pt |
| Cards/sheets | 12pt |
| Buttons | 8pt |
| Input fields | 6pt |

---

## Shadows

### Popover Shadow
```swift
.shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
```

### Card Shadow
```swift
.shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
```

### Button Press Shadow
```swift
.shadow(color: .black.opacity(0.06), radius: 2, x: 0, y: 1)
```

---

## Motion

### Duration
- Default: **200ms**
- Larger transitions: **300ms**

### Easing
- Most animations: `easeInOut`
- Bouncy feedback: `spring(response: 0.3, dampingFraction: 0.7)`

### Reduce Motion
Always respect `accessibilityReduceMotion`:
```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion
```

---

## Component Patterns

### Copy Button
- SF Symbol: `doc.on.doc`
- Tooltip: "Copy [format] to clipboard"
- Size: 20×20pt minimum
- States: default (secondary color), hover (primary), pressed (accent)

### Color Swatch Button
- Minimum size: 44×44pt (accessibility)
- Shows hex on hover via tooltip
- Border: 1pt white at 20% opacity
- Corner radius: 6pt

### Section Headers
```swift
Text("SECTION NAME")
    .font(.caption)
    .foregroundColor(.secondary)
    .tracking(0.05)  // 5% letter spacing
```

### Dividers
- Height: 1pt
- Color: `#e4e2df`
- Vertical margin: 16pt

---

## SF Symbols Usage

| Purpose | Symbol Name |
|---------|-------------|
| Eyedropper/picker | `eye.dropper` |
| Palette | `square.grid.3x3` |
| Copy | `doc.on.doc` |
| Settings | `gearshape` |
| Add | `plus` |
| Delete | `trash` |
| Export | `square.and.arrow.up` |
| History | `clock` |
| Checkmark | `checkmark.circle.fill` |
| Warning | `exclamationmark.triangle` |

---

## Menu Bar Icon

- Size: 18×18pt template image
- Design: Small droplet or circular swatch
- Template-compatible (black/white, no color)
- Optional: Live color overlay when popover is open

---

## App Icon

- Master size: 1024×1024px
- Concept: Stylized color palette with depth effect
- Background: Warm neutral (`#faf9f7`) or soft gradient
- Foreground: Overlapping color swatches or elegant droplet

### Required Sizes
- 16×16, 32×32, 64×64, 128×128, 256×256, 512×512, 1024×1024
- Each size at 1x and 2x (except 1024)

---

## Dark Mode

All colors adapt automatically via NSColor system colors. Use `Color(nsColor: Theme.textSecondary)` for theming rather than hardcoded values.

---

## Accessibility

- Minimum touch target: 44×44pt
- Color contrast: WCAG AA minimum (4.5:1 for normal text)
- All interactive elements have accessibility labels
- Keyboard navigation support (see R7)
- Reduce motion support (see R7)
