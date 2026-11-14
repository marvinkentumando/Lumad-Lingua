# LUMAD LINGUA - Comprehensive Brand Identity & Design System
**Version 2.0 | Flutter Mobile Application**

---

## 1. Brand Overview & Philosophy
**Lumad Lingua** is a digital language documentation and gamified learning platform dedicated to the **Mansaka** indigenous language of Mindanao, Philippines. 
* **Design Philosophy:** Bridges ancient ancestral wisdom with modern mobile learning. The visual language blends earthy forest tones and sacred gold accents with clean, friendly, modern UI components (Material 3).

---

## 2. Color Palette

### Primary Scale (Forest Greens)
*Inspired by the lush ancestral rainforests of Mindanao.*
* `forest900`: `#030A04` (Deepest shade / Dark text / Dark theme background)
* `forest800`: `#061209`
* `forest700`: `#0D1E0D` (Deep Forest)
* `forest600`: `#14241A` (Dark Canopy)
* `forest500`: `#1E3A22` (**Forest Floor / Primary Light Theme Button & Element color**)
* `forest400`: `#2A5230`
* `forest300`: `#3D7045`
* `forest200`: `#65A870`
* `forest100`: `#A8D4AE`
* `forest50`: `#E8F4EA`

### Accent Scale (Ancestral Gold)
*Representing tribal regalia, oral tradition, and sacred artifacts.*
* `gold900`: `#4A2E00`
* `gold800`: `#7A4F00`
* `gold700`: `#B88500`
* `gold600`: `#D4A000`
* `gold500`: `#FFC200` (**Primary Accent CTA & Dark Theme Primary Color**)
* `gold400`: `#FFD03A`
* `gold300`: `#FFE080`
* `gold200`: `#FFF0B3`
* `gold100`: `#FFF8DE`
* `gold50`: `#FFFDF5`

### Neutrals & Parchment (Cream Theme)
* `creamBg`: `#FEF8ED` (Warm parchment background)
* `creamBorder`: `#E0CFA8` (Soft border separator)
* `creamShadow`: `#B8A070` (Elevation shadow tone)
* `creamText`: `#1A0E05` (High-contrast dark brown text)
* `creamText2`: `#7A5C3A` (Secondary descriptive brown text)
* `creamText3`: `#A8906E` (Subtle hint / muted text)

### Semantic & Special Colors
* `semanticGreen`: `#3DAF5C` (Correct answer, success, completion, passing grade)
* `semanticRed`: `#F04848` (Error, incorrect answer, danger, deletion, alerts)
* `semanticBlue`: `#3B91E0` (Information, selection, active states)
* `semanticWarning`: `#FF9800` (Warnings, cautions)
* `terracotta`: `#C84E1A` (Earthy highlight tone)
* `forestDarkCard`: `#0F1E11` (Dark mode card surface)

---

## 3. Typography

* **Display & Headings** (`GoogleFonts.fredoka`):
  * Friendly, rounded, playful yet authoritative geometric sans-serif for headings, banners, and stats.
  * `display`: 48px, w600
  * `displayBold`: 48px, w700
  * `h1ExtraBold` / `h1`: 32px, w700 / w600
  * `h2ExtraBold` / `h2`: 24px, w700 / w600
  * `h3`: 18px, w600

* **Body & Labels** (`GoogleFonts.nunito`):
  * Clean, highly readable, warm sans-serif for comfortable long-form reading and UI labels.
  * `bodyLarge`: 16px, w500
  * `body`: 14px, w400
  * `label`: 12px, w700 (Letter spacing: 1.2)
  * `labelBold`: 12px, w800
  * `caption`: 11px, w500

* **Code / Monospace** (`GoogleFonts.dmMono`):
  * `mono`: 13px

---

## 4. Radii & Shapes (`AppRadius`)
*Standardized border radii for consistent UI hierarchy:*
* `card` (Containers & Cards): **`20.0`**
* `modal` (Modals, Dialogs & Bottom Sheets): **`28.0`**
* `button` (Standard Buttons & Text Inputs): **`16.0`**
* `chip` (Chips, Badges & Small Pills): **`12.0`**
* `small` (Small Indicators & Tags): **`8.0`**

---

## 5. Buttons & Interactive Elements (`BrandButton`)
* **Types (`BrandButtonType`)**:
  * `primary`: Main action button with 3D tactile bottom shadow, press animation scale (`0.95`), and theme-adapted fill (`forest500` light / `gold500` dark).
  * `secondary`: Outlined button with custom border and transparent/subtle background.
  * `success` / `danger`: Colored action buttons using `semanticGreen` or `semanticRed`.
  * `small` / `text`: Compact pill buttons or flat text buttons.
* **Micro-Interactions**:
  * Built-in haptic feedback (`HapticFeedback.lightImpact()`) on press.
  * 500ms tap debouncing to prevent double-submissions.
