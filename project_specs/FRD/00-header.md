# Functional Requirements Document
## SimpleWineApp — Personal Wine Collection Manager

**Project:** SimpleWineApp
**FRD Version:** 1.0
**PRD Reference:** PRD-SimpleWineApp.md v1.0
**Date:** 2026-06-03
**Status:** Draft
**Author:** Pivota Spec FRD Generator

---

## Scope

This document specifies the detailed functional behavior of all MVP features (F0–F6) for SimpleWineApp. It covers inputs, outputs, validation rules, error states, API surface, and database schema for each feature. This FRD is the authoritative reference for implementation — developers should be able to build any feature from this document without requiring additional clarification on functional behavior.

Out of scope for this FRD: Phase 2+ features (food pairing, CSV import/export, notifications, valuation tracking, cellar map), Phase 3+ features (label scanning, AI entry, external wine database integration), and Phase 4 features (shared household accounts). All UI must implement USWDS component patterns with the TechSur brand overlay.

---

## How to Read This Document

- **Feature chunks** (`F00`–`F06`) each cover one PRD feature end-to-end.
- **Cross-feature chunks** (`Y0`–`Y3`) consolidate schema, API, errors, and integrations.
- Per-feature API and schema sections reference the canonical `Y1-api.md` and `Y0-schema.md` for full specs.
- Feature IDs in cross-references use format `F{nn} §{Section}` (e.g., `F00 §Process step 3`).
- All field names in code format (e.g., `wine_name`) match the API request/response bodies and database column names.
- HTTP status codes follow RFC 9110.
- All timestamps are ISO 8601 UTC.

---

## Conventions

| Convention | Meaning |
|-----------|---------|
| **Required** | Field must be present and non-empty to save a record |
| **Optional** | Field may be omitted; stored as NULL or empty string |
| `snake_case` | API field names and database column names |
| `PascalCase` | Entity/model names |
| `UPPER_CASE` | Error codes and enum values |
| `[A–Z, a–z]` | Validation character class notation |
| ≥, ≤, <, > | Numeric boundary (inclusive unless noted) |

---

## Shared Terminology

| Term | Definition |
|------|-----------|
| **Wine Record** | A single entry in the cellar representing one wine (producer + label + vintage). A wine record may have many bottles (quantity). |
| **Bottle Event** | A logged action against one bottle unit: Consumed, Gifted, or Opened. Decrements quantity (Consumed, Gifted) or sets a status flag (Opened). |
| **Drinking Window** | The date range (start year – end year) during which a wine is expected to be at or near peak quality. |
| **Readiness Status** | Calculated label derived from the drinking window and current year: Drink Now, Hold, Approaching Peak, Past Window, or No Window Set. |
| **Storage Location** | A user-defined named physical location where bottles are stored (e.g., "Wine Fridge – Top Shelf"). |
| **Tasting Note** | A dated personal record of a wine tasting event, including sensory descriptors and a personal rating. |
| **Collection** | The full set of wine records owned by the user with quantity > 0. |
| **Cellar Empty** | Status applied to a wine record whose quantity has reached zero. |
| **Personal Rating** | User's numeric quality assessment of a wine. Default scale: 1–5 stars. Alternate: 1–100 points (user-selectable in settings). |
| **USWDS** | U.S. Web Design System — the UI component and accessibility foundation. |
| **TechSur Brand** | Design overlay applied on top of USWDS: Gold/Black/Bone palette, Montserrat/Fraunces/Open Sans/JetBrains Mono typography. |

---

## Brand & Design Token Reference

| Token | Value | Usage |
|-------|-------|-------|
| `--color-gold-400` | `#FBCA5C` | Primary accent, CTAs, Drink Now badge, primary buttons |
| `--color-gold-500` | `#E6B040` | Serif accent on light backgrounds |
| `--color-gold-600` | `#B0832A` | Gold text on light backgrounds (contrast-safe) |
| `--color-canvas-dark` | `#0A0A0A` | Hero areas, nav background (dark variant) |
| `--color-bone` | `#FAFAF7` | Light canvas, page background |
| `--color-paper` | `#F5F5F2` | Alt card surface |
| `--color-ink` | `#1A1A1A` | Body text on light |
| `--color-gray-400` | `#A8A59B` | Muted labels, secondary text |
| `--font-display` | Montserrat 900 | Section headings, tight tracking |
| `--font-accent` | Fraunces 400–600 italic | Accent words, emphasis |
| `--font-body` | Open Sans 400/600/700 | Body copy, lead paragraphs |
| `--font-mono` | JetBrains Mono 400–500 | Labels, badges, eyebrows — UPPERCASE |
| `--font-button` | Montserrat 700 | Buttons — UPPERCASE, +1px tracking |
| `--radius-button` | 2px | Button border radius |

> **Accessibility rules:** Gold 400 (`#FBCA5C`) text must NOT appear on Bone (`#FAFAF7`) backgrounds — use Gold 600 instead. Gold must remain ≤10% of any given view. All readiness status badges must include a text label (color alone is never the sole differentiator).

---

## Table of Contents

| Section | File | Feature |
|---------|------|---------|
| F00 | `F00-wine-inventory-crud.md` | Wine Inventory CRUD |
| F01 | `F01-quantity-bottle-status.md` | Quantity & Bottle Status Tracking |
| F02 | `F02-storage-locations.md` | Storage Location Management |
| F03 | `F03-search-filter.md` | Search & Filter |
| F04 | `F04-tasting-notes-ratings.md` | Tasting Notes & Personal Ratings |
| F05 | `F05-drinking-window.md` | Drinking Window Management |
| F06 | `F06-collection-dashboard.md` | Collection Dashboard & Insights |
| Y0 | `Y0-schema.md` | Database Schema (full DDL) |
| Y1 | `Y1-api.md` | REST API Endpoints |
| Y2 | `Y2-errors.md` | Cross-Feature Error Catalog |
| Y3 | `Y3-integrations.md` | External Integration Points |

---
