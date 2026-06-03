# UX Mockup
## SimpleWineApp — Personal Wine Collection Manager

**Project:** SimpleWineApp
**Generated:** 2026-06-03
**Based on:** UserStories-SimpleWineApp.md, JOURNEYS-SimpleWineApp.md, PRD-SimpleWineApp.md, FRD-SimpleWineApp.md
**UI Foundation:** USWDS components + TechSur brand overlay

---

## Overview

SimpleWineApp's UX is built around a single promise: answer the three core questions in seconds — *What wine do I have? Where is it stored? What should I drink next?* Every screen has one clear purpose. Navigation is direct. Data entry is fast. Discovery is immediate.

### Design Principles

1. **Speed over completeness** — required fields are the minimum; optional fields are always available but never blocking
2. **Location always visible** — storage location appears on every list card, not buried in detail views (Cross-Journey Pattern CP-01)
3. **Filter persistence** — changing one filter never clears others; chips are individually dismissible (CP-02)
4. **Tiered post-consume flow** — quick occasion note first, full tasting note second; serves all personas (CP-03)
5. **Drink Now shelf is typed** — horizontal type pills on the shelf so filtering never requires navigation (CP-04)
6. **Cellar Empty stays visible** — zero-quantity wines remain de-emphasized in the list, not hidden (CP-05)

### TechSur + USWDS Token Mapping

| Token | Value | Usage in App |
|-------|-------|-------------|
| `--color-gold-400` | `#FBCA5C` | Primary CTA buttons, Drink Now badge, FAB |
| `--color-gold-600` | `#B0832A` | Gold text on Bone backgrounds (contrast-safe) |
| `--color-canvas-dark` | `#0A0A0A` | App header/nav background, hero bands |
| `--color-bone` | `#FAFAF7` | Page background, card surfaces |
| `--color-paper` | `#F5F5F2` | Alt card surface, filter panel bg |
| `--color-ink` | `#1A1A1A` | Body text, primary labels |
| `--color-gray-400` | `#A8A59B` | Muted labels, Cellar Empty text, secondary info |
| `--font-display` | Montserrat 900 | Screen headings, section titles |
| `--font-accent` | Fraunces italic | Wine name on detail hero, accent emphasis |
| `--font-body` | Open Sans 400/600/700 | All body copy, form labels, descriptions |
| `--font-mono` | JetBrains Mono UPPERCASE | Badges, type labels, quantity pills, eyebrows |
| `--font-button` | Montserrat 700 UPPERCASE | All button text, +1px tracking |
| `--radius-button` | 2px | All button border radius |

### Readiness Status Badge Colors

| Status | Badge Color | Text | WCAG Note |
|--------|------------|------|-----------|
| DRINK NOW | Gold `#FBCA5C` bg / Black text | "DRINK NOW" | Text label required — color not sole differentiator |
| APPROACHING PEAK | Amber `#F5A623` bg / Black text | "APPROACHING" | Text label required |
| HOLD | Gray `#A8A59B` bg / Ink text | "HOLD" | Text label required |
| PAST WINDOW | Muted `#D0CEC8` bg / Gray text | "PAST WINDOW" | Text label required |
| NO WINDOW SET | Paper `#F5F5F2` bg / Gray text | "NO WINDOW" | Text label required |

### Screen Inventory

| Screen | Purpose | User Stories |
|--------|---------|-------------|
| Dashboard | Landing view — stats, Drink Now shelf, insights | US-6.1–6.5 |
| Collection List | Browse, search, filter all wines | US-0.2, US-3.1–3.3, US-4.6, US-5.2 |
| Wine Detail | Full record, actions, tasting notes, event log | US-0.3, US-1.1–1.4, US-4.3, US-5.2 |
| Add / Edit Wine Form | Create or update wine record | US-0.1, US-0.4, US-0.6, US-5.1, US-2.4 |
| Tasting Note Form | Capture tasting experience and rating | US-4.1, US-4.2, US-4.4 |
| Storage Locations | Manage named cellar locations | US-2.1–2.3 |
| Settings | Rating scale, app preferences | US-4.5 |

### Navigation Structure

```
┌──────────────────────────────────────────┐
│  NAV (usa-header / usa-nav)              │
│  Dashboard | My Cellar | Settings        │
│  [+ Add Wine] ← primary CTA             │
└──────────────────────────────────────────┘
        │           │           │
   Dashboard   Collection    Settings
                  List       (Storage
                              Locations,
                              Rating Scale)
        │
   Wine Detail ── Add Tasting Note
        │
   Edit Wine Form
        │
   Bottle Event Dialog (Consume / Gift / Open)
```

**Mobile Navigation:** Bottom tab bar (Dashboard · Cellar · Settings) + Gold FAB "+" floating above center tab

**Desktop Navigation:** `usa-header` with horizontal nav links; "+ Add Wine" button in top-right of header

---
