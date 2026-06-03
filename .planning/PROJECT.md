# SimpleWineApp — Personal Wine Collection Manager

## What This Is

A personal wine collection management web application for wine enthusiasts who want a better way to
organize, understand, and enjoy their private cellar. Users can track bottles, manage storage locations,
record tasting notes, monitor drinking windows, and get simple insights into their collection — all through
a clean, mobile-friendly interface built to USWDS standards with the TechSur brand design system applied.

## Core Value

The user can always answer three questions in seconds: What wine do I have? Where is it stored? What should I drink next?

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] User can add, view, edit, and delete wine records (inventory CRUD)
- [ ] User can track bottle quantity, storage location, vintage, producer, region, grape, and drinking window per wine
- [ ] User can search and filter the collection by type, producer, region, vintage, grape, and drinking readiness
- [ ] User can mark bottles as consumed, gifted, or opened and log tasting notes with personal ratings
- [ ] User can view a dashboard showing total bottles, wines ready to drink, and basic collection insights
- [ ] UI follows USWDS standards and applies TechSur brand (gold/black palette, Montserrat/Open Sans/JetBrains Mono typography)
- [ ] Application is mobile-friendly and responsive

### Out of Scope

- Label scanning / AI-assisted bottle entry — deferred to Phase 3 per business vision
- Food pairing suggestions and occasion-based recommendations — Phase 2 future scope
- Shared household accounts — Phase 4 future scope
- Import/export from spreadsheets — low-priority future scope
- Restaurant/retail inventory or commercial compliance — explicitly excluded

## Context

- **Business vision document** provided: `project_specs/ref_docs/Wine Collection Software Business Vision.pdf`
- **Brand guide** provided: `project_specs/ref_docs/TechSur-Brand-Guide 1.pdf`
- **UI constraint**: Must use USWDS component library as the structural foundation
- **Brand overlay**: TechSur palette (Gold #FBCA5C primary accent, Black #0A0A0A canvas, Bone #FAFAF7 light surface, Ink #1A1A1A body text) applied on top of USWDS tokens
- **Typography**: Montserrat 900 (headings), Fraunces italic (accent), Open Sans (body), JetBrains Mono (labels/eyebrows)
- **Target users**: Casual Collectors, Enthusiasts, Home Entertainers, Serious Collectors, Family Household Users
- **MVP success criteria**: User can add wines quickly, find wines easily, track quantity, know what is ready to drink, record tasting notes, and use the app instead of a spreadsheet

## Constraints

- **UI Framework**: USWDS — all components must use or extend USWDS design tokens and component patterns
- **Brand**: TechSur brand guide colors, typography, and component patterns must be applied over USWDS baseline
- **Scope**: Personal-use MVP first; no commercial or multi-tenant features in v1
- **Mobile-first**: UI must be fully functional on phone-sized screens
- **Complexity ceiling**: Keep feature count focused — overbuilding is an explicit risk identified in business vision

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| USWDS as UI foundation | Explicit user requirement; provides accessibility and gov-grade design baseline | — Pending |
| TechSur brand over USWDS | Brand guide provided; gold/black/bone palette and typography overrides USWDS defaults | — Pending |
| Personal-use MVP first | Business vision recommends proving personal workflow before commercializing | — Pending |
| spec-express mode | Full spec doc generation pipeline to be used for planning | — Pending |

---
*Last updated: 2026-06-03 after initialization*
