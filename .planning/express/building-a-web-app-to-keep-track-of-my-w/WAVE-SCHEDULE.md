# Wave Schedule — SimpleWineApp MVP v1.0

**Generated:** 2026-06-03  
**Source docs:** PRD-SimpleWineApp.md v1.0, RTM-SimpleWineApp.md v1.0  
**Total PRD features:** 7 (F0–F6) | **All covered**

---

```yaml
wave: 1
domain: database
depends_on: []
features: [F0, F1, F2, F4, F5]
objective: "Create all database tables (wines, storage_locations, bottle_events, tasting_notes, user_settings) with exact DDL, indexes, and constraints per TechArch; includes latest_rating denormalization columns (ADR-008) and drink_window columns needed by readiness calculation (ADR-007)."
estimated_plans: 1
---
wave: 2
domain: backend
depends_on: [1]
features: [F0, F1, F2, F4, F5, F6]
objective: "Implement all 22 REST API endpoints at /api/v1 (wines CRUD, bottle events, quantity patch, storage locations CRUD, tasting notes CRUD, settings, dashboard/stats); implement pure-function business logic modules (readiness.ts, rating.ts, location.ts, filterWines.ts, sortWines.ts, wines.ts Zod schemas); readiness_status calculated at response time — never stored (ADR-007)."
estimated_plans: 3
---
wave: 3
domain: frontend
depends_on: [2]
features: [F0, F1, F2, F3, F4, F5, F6]
objective: "Build all React component groups over USWDS foundations with TechSur brand overlay (Gold/Black/Bone palette, Montserrat/Fraunces/Open Sans/JetBrains Mono typography): Navigation Shell, Wine List & Cards, Wine Forms, Wine Detail, Tasting Notes, Storage Locations page, Search & Filter panel with Fuse.js client-side engine, Dashboard with all insight cards; mobile-first responsive layout at 375px+; WCAG 2.1 AA compliance."
estimated_plans: 4
---
wave: 4
domain: integration
depends_on: [1, 2, 3]
features: [F0, F1, F2, F3, F4, F5, F6]
objective: "End-to-end verification of all 5 key user journeys (Add a Bottle, Find a Bottle, Choose a Wine Tonight, Open a Bottle, Review the Collection); Service Worker offline read/search (progressive enhancement); design token file mapping TechSur overrides to USWDS tokens; E2E test suite covering all 31 user stories (US-0.1–US-6.5)."
estimated_plans: 1
```

---

## WAVE SCHEDULE

| Wave | Domain | Plans | Features | Objective |
|------|--------|-------|----------|-----------|
| 1 | database | 1 | F0, F1, F2, F4, F5 | Create all 5 DB tables (`wines`, `storage_locations`, `bottle_events`, `tasting_notes`, `user_settings`) with DDL, indexes, constraints, and denormalized `latest_rating` columns |
| 2 | backend | 3 | F0, F1, F2, F4, F5, F6 | All 22 REST endpoints + 6 business logic modules (readiness, rating, location, filter engine, sort, Zod validation); readiness calculated at response time, never stored |
| 3 | frontend | 4 | F0, F1, F2, F3, F4, F5, F6 | All React component groups (Navigation, Wine List/Cards, Forms, Detail, Tasting Notes, Locations, Search/Filter, Dashboard) over USWDS+TechSur; mobile-first 375px+; WCAG 2.1 AA |
| 4 | integration | 1 | F0, F1, F2, F3, F4, F5, F6 | End-to-end user journey verification, Service Worker offline support, design token mapping, full E2E test suite for all 31 user stories |

**Total features:** 7 (F0–F6) | **Covered:** 7 | **Uncovered:** 0

---

### Wave Rationale

**Wave 1 — Database only (1 plan)**  
All tables needed upfront. Five tables: `wines` (core record + quantity + is_open + latest_rating + location_unknown + drink_window cols), `storage_locations`, `bottle_events`, `tasting_notes`, `user_settings`. Wave 1 has no dependencies and is the required foundation for all backend work. F3 (Search & Filter) is a pure client-side/API concern with no dedicated table — it operates over `wines` and `tasting_notes` via JOIN — so no separate DB plan is needed for F3; it is covered by the `wines` + `tasting_notes` tables in this wave.

**Wave 2 — Backend API (3 plans)**  
Split into three plans to stay within the 2–3 task / ~50% context budget:
- **Plan 2-01:** Wines CRUD endpoints + Zod validation + business logic modules (readiness.ts, rating.ts, location.ts)
- **Plan 2-02:** Bottle events endpoints + quantity PATCH + storage locations CRUD + settings endpoints
- **Plan 2-03:** Tasting notes endpoints + dashboard endpoints (GET /dashboard, GET /dashboard/stats) + filter/sort utility functions

**Wave 3 — Frontend (4 plans)**  
Split into four plans by feature domain to manage complexity and context:
- **Plan 3-01:** Project setup — Next.js App Router scaffold, USWDS install, TechSur design tokens CSS file, font self-hosting (WOFF2), Navigation Shell
- **Plan 3-02:** Wine List page (F0 list + F3 search/filter + F5 readiness badges + F1 quantity pill) — heaviest component group
- **Plan 3-03:** Wine Detail page + Wine Forms (Add/Edit) + Storage Locations page (F0 detail/forms, F1 events, F2 locations, F4 tasting notes UI)
- **Plan 3-04:** Dashboard page — all insight cards (F6 stats bar, Drink Now shelf, breakdowns, recently added/consumed, highest rated)

**Wave 4 — Integration (1 plan)**  
End-to-end validation across all layers: journey testing, Service Worker registration, design token audit, full E2E test coverage.
