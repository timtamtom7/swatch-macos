# Swatch — Onboarding Screens

Swatch ships as a menu bar app. Onboarding is brief — the app lives in the status bar and opens as a popover. The goal of onboarding is to orient the user in the first 3–5 seconds of first launch, not to overwhelm.

---

## Screen 1 — Welcome / Menu Bar Activation

**Trigger:** First launch (no saved state detected)

**Layout:** Centered illustration above a single-line instruction. No navigation chrome.

**Illustration concept:**
A line-art drawing of a MacBook screen with the macOS menu bar highlighted. A small Swatch icon (eyedropper + color drop) is "clicked" and a color popover blooms downward, revealing a mini color wheel. A subtle arrow points to the menu bar area.

**Visual style:**
- Line art, `#6E6E73` strokes on `#F5F5F7` background
- The Swatch icon uses the app's accent blue `#007AFF` for the color drop element
- Soft drop shadow beneath the popover to imply depth

**Text:**
> "Swatch lives in your menu bar."
> "Click the icon to pick colors from anywhere on screen."

**CTA:** Single "Got it" button, `#007AFF` fill, 36pt height, 8pt corner radius.

---

## Screen 2 — Pick Your First Color

**Trigger:** After dismissing Screen 1

**Layout:** Same popover frame (320×400pt). The Picker tab is active.

**Illustration concept:**
The popover's eyedropper cursor is shown hovering over a colorful abstract gradient (a smooth 3-stop gradient: purple → blue → teal). The cursor has a small circular preview ring beneath it showing the exact color under the pointer.

**Visual style:**
- The abstract gradient fills roughly 40% of the illustration area
- Eyedropper cursor rendered in dark gray `#3A3A3C` with a 2pt white outline for visibility on any background
- The preview ring is 24pt diameter, outlined in white, filled with the target color
- Background: `#FAFAFA` (light) / `#1C1C1E` (dark) — adapts to system appearance

**Text:**
> "Click anywhere on screen to sample a color."
> "Press ⌘⇧C to copy the hex code instantly."

**Interactive hint:** A small pulsing ring animation on the eyedropper icon in the tab bar, indicating "you're on the right tab."

---

## Screen 3 — Save and Organize Palettes

**Trigger:** First time navigating to Palettes tab (or second screen if user skips around)

**Layout:** Palettes view with sample palettes shown.

**Illustration concept:**
A simplified flat mockup of the Palettes tab. Three palette cards are shown: the first with 5 color swatches (one highlighted with a checkmark), the second and third with 3 swatches each. A dashed-line "+" card is shown at the end representing "create new." A small label reads "Your palettes live here."

**Visual style:**
- Flat cards with 8pt corner radius, 1pt `#E0E0E3` border, `#FFFFFF` fill on light / `#2C2C2E` on dark
- Color swatches are 28pt circles, no border
- The highlighted swatch has a `#007AFF` checkmark badge (SF Symbol `checkmark.circle.fill`)
- The "+" card uses a dashed `#E0E0E3` border with a centered `plus` SF Symbol in `#6E6E73`

**Text:**
> "Save colors to palettes. Organize by project or mood."
> "Right-click any color to copy it in RGB, HSB, or Hex."

---

## Screen 4 — Harmony & Contrast Tools

**Trigger:** First time visiting Harmony or Contrast tab

**Layout:** Split conceptual illustration showing both tools side by side.

**Illustration concept (left panel — Harmony):**
A color wheel with 5 dots evenly spaced representing complementary colors. Thin lines connect each dot to its complement on the opposite side. A single base color dot is highlighted in `#AF52DE` (violet accent).

**Illustration concept (right panel — Contrast):**
A simplified WCAG contrast checker: two overlapping rounded rectangles (one white, one near-black) with a "AA ✓" badge between them. A small contrast ratio label "7.4:1" sits below.

**Visual style:**
- Both panels share the same background and border treatment
- Color wheel uses `#E0E0E3` for the wheel ring, dots in their respective colors
- Contrast rectangles use `#FFFFFF` and `#1A1A1A` with a `#30D158` AA badge

**Text:**
> "Generate harmonious palettes automatically."
> "Check contrast ratios for accessibility compliance."

---

## Screen 5 — Widget & Keyboard Shortcuts

**Trigger:** First time opening Settings, or banner prompt on first launch

**Layout:** Settings-like illustration showing the widget gallery and a keyboard shortcut reference card.

**Illustration concept:**
Left: macOS widget gallery preview showing the three Swatch widget sizes (small, medium, large) placed on a stylized home screen grid.

Right: A keyboard shortcut reference card — a clean list of 4–5 shortcuts with their bindings, styled like a Notion callout box with a `#007AFF` left border.

**Visual style:**
- Widget previews use the same flat card style as Screen 3
- Shortcut card: white fill, `#E0E0E3` border, 8pt corner radius
- Each row: `[icon] Shortcut description   ⌘⇧C` right-aligned in SF Mono

**Text:**
> "Add the Swatch widget to your desktop for instant access."
> "⌘⇧C — Pick color and copy hex  |  ⌘⇧V — Open last picked color"

**CTA:** "Open System Settings → Widgets" link-style button in `#007AFF`.
