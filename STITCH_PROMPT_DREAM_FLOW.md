# Stitch Design Prompt — Dream Analysis & Save Flow
## App: Hypnos Dream Journal

---

## Context & Visual Identity

Design 3 mobile screens (iOS/Android) for a **dream journal app** called **Hypnos Dream Journal**.

**Visual style:**
- Dark mode only. Background: deep dark navy/indigo (`#0D0F1A`)
- Glassmorphism cards: semi-transparent surfaces with subtle blur, thin border with low-opacity accent color
- Accent colors: purple/violet (`accentSecondary`) for AI/Morfeo elements, cyan/teal (`accentPrimary`) for primary actions
- Typography: primary text white, secondary text medium-opacity white. Use a serif italic font (Lora) for dream content/AI summaries
- Visual motif: a glowing animated orb called **Morpheus Orb** — a soft pulsing sphere with inner light, used to represent the AI assistant Morfeo
- Pill-shaped buttons (StadiumBorder), rounded cards (radius 16–20px)

---

## Screen 1 — "Analyze Dream" (Step 2 of dream creation wizard)

**App bar:** Title centered: `"Analyze dream"` — back arrow icon on the left (disabled while loading)

### Idle state (default)

**Top area — Dream snippet preview card:**
A small glass card showing the dream that was just written. Shows the dream title and a truncated preview of the description text. Subtle, compact. Just for context.

**Main card — Morfeo (AI):**
Large expanded glass card with a violet/purple gradient tint. Contains:
- Row at top: **Morpheus Orb** (56px animated orb) + text column:
  - Title: `"Morfeo"` in violet/accent color, bold, 18px
  - Subtitle: `"AI dream interpreter"` in secondary text, 12px
- Body text (14px, secondary color, 1.5 line height):
  - If user recorded audio: `"I will transcribe your recordings and analyze key emotions, places, and themes from your dream."`
  - If no audio: `"I will analyze key emotions, places, and themes from your dream and return a useful summary."`
- If user has audio recordings: show a small badge/chip at the bottom of the card showing `"2 recordings"` (count chip)
- Spacer
- **Primary CTA button** (full width, violet/accent, pill): `"Analyze with Morpheus"`
- **Secondary text button** (full width, no fill, subtle): `"Save without analysis"`

### Loading state (replaces entire body)
Centered column:
- If Morfeo flow: the **Morpheus Orb** (156px, large, pulsing)
- If direct save: a circular container with a save icon
- Status label below orb (bold, 18px, white): cycling through these messages:
  - `"Uploading recordings..."`
  - `"Morpheus is listening..."` (transcription)
  - `"Morpheus is interpreting your dream..."` (analysis)
  - `"Saving to your journal..."`
- A thin linear progress bar (260px wide, violet/accent) below the label

### Error state
Centered column:
- Error icon (red, 48px)
- Error message in secondary text
- Outlined pill button: `"Retry"`

### Dialog — Morfeo warning (when AI steps fail)
Dark modal dialog with violet border glow:
- Morpheus Orb (64px) centered at top
- Title (white, bold, 20px): e.g., `"Morpheus could not analyze"` / `"Insufficient information"` / `"Morpheus could not transcribe"`
- Message (secondary text, 13px): explanation of what happened
- Full-width pill button (violet): `"Understood"`

### Dialog — Save warning (non-AI errors)
Same structure but with cyan/primary accent and a warning icon instead of orb.

---

## Screen 2 — "Morpheus Result" (Full AI analysis, shown after Morfeo flow)

**App bar:** Title centered: `"Morpheus result"` — **no back button** (this is a one-way step)

**Hero card (glass, violet border):**
- Morpheus Orb (centered, medium size) with a sparkle badge
- Subtitle below orb: `"Review the full analysis before deciding how to publish your dream."`
- Two metric chips in a row: **Sentiment** (e.g., `"Anxious"`) and **Category** (e.g., `"Nightmare"`) — each with a small icon and violet/cyan accent badge style

**Scrollable content cards (glass cards, stacked):**

1. **Summary card** — Icon: book/auto_stories — Title: `"Summary"` — Body: AI-generated italic serif text describing the dream meaning

2. **Psychological note card** — Icon: psychology — Title: `"Psychological note"` — Body: plain text, Morfeo's psychological interpretation

3. **Sentiment + Category row** — Two equal-width metric cards side by side:
   - `"Sentiment"` card — heart icon — violet accent — shows value like `"Anxious"`
   - `"Category"` card — grid icon — cyan accent — shows value like `"Nightmare"`

4. **Emotions list card** — Icon: mood — Title: `"Emotions"` — Wrap of pill chips in purple/violet: e.g., `"Fear"` `"Confusion"` `"Relief"`

5. **Characters list card** — Icon: groups — Title: `"Characters"` — Wrap of neutral chips: e.g., `"Unknown figure"` `"Family member"`

6. **Places list card** — Icon: place — Title: `"Places"` — Wrap of chips: e.g., `"Forest"` `"Old house"`

7. **Themes list card** — Icon: interests — Title: `"Themes"` — Wrap of cyan/teal chips: e.g., `"Pursuit"` `"Loss of control"` `"Water"`

**Bottom bar (pinned, blurred background):**
- Full-width pill button (cyan/primary, 54px height): `"Continue to publishing"` — leading arrow icon

---

## Screen 3 — "Dream Saved!" (Step 3, publish & share)

**No app bar.** Scrollable screen with a pinned bottom button.

### Success header (centered)
- **Morpheus Orb** (124px) with a small badge in the bottom-right corner:
  - Violet badge with sparkle icon (if AI analysis was done)
  - Cyan badge with checkmark icon (if saved without analysis)
- Title below orb: `"Dream saved!"` (white, bold, 24px)
- Subtitle: dream title in secondary text (smaller, 15px, max 2 lines)

### Morfeo analysis preview card (only shown if AI was done)
Glass card with violet border glow. Shows a compact version of the analysis:
- Header row: sparkle icon + label `"MORPHEUS INTERPRETATION"` (violet, 10px caps) + category badge (pill, violet)
- AI summary in italic serif text (14px)
- Section: `"EMOTIONS"` label + emotion chips (purple pills)
- Section: `"THEMES"` label + theme chips (cyan pills)
- Psychological note in a subtle inner box (violet tinted, italic, 13px)

### Publish card (glass)
Row layout:
- Left: globe/public icon (secondary color)
- Center column:
  - Title: `"Publish dream"` (white, bold, 16px)
  - Subtitle: dynamic text:
    - If toggle off: `"Visible only to you"`
    - If toggle on + profile public: `"Visible to everyone"`
    - If toggle on + profile followers: `"Visible to followers"`
- Right: **Switch toggle** (violet accent when active) / loading spinner while saving

### Share card (glass)
- Section label: `"SHARE"` (secondary, 11px caps)
- Two share tiles side by side:
  - **WhatsApp tile**: green chat icon + label `"WhatsApp"`
  - **More tile**: share icon + label `"More"` (cyan accent)
  - Each tile: rounded card, icon on top, label below, tap effect

### Bottom CTA (pinned)
Full-width pill button (cyan/primary, 54px, with a glow shadow below):
`"Go to journal"`

### Snackbar (error state — Morfeo failed but dream was saved)
Floating dark snackbar with red border:
- Warning icon (red)
- Title: `"Morpheus could not analyze the dream"` (red tint, bold, 13px)
- Subtitle: error detail (secondary, 11px, max 2 lines)

---

## Flow Summary

```
[Dream Form] → [Analyze Dream screen]
                    ├── "Analyze with Morpheus" → [Loading: upload → transcribe → analyze → save] → [Morpheus Result screen] → [Dream Saved screen]
                    └── "Save without analysis" → [Loading: upload → save] → [Dream Saved screen]
```

---

## Additional Notes for Stitch

- All 3 screens share the same dark background color
- The Morpheus Orb is the visual anchor of the AI identity — it should appear prominently in loading states and headers
- Cards use a consistent glass treatment: `background: white 4-6% opacity`, `border: accent color 25-35% opacity`, `borderRadius: 16px`
- Chips/tags use `background: accent 10% opacity`, `border: accent 30% opacity`, pill shape
- Empty states (no AI data) show `"No data"` in secondary text with no chip
- The flow is linear — users cannot go back from screen 3
