---

## 7. Integration Points

### 7.1 Summary

SimpleWineApp v1 is deliberately minimal in external dependencies. Per the PRD privacy requirement: *"No user data sent to third-party analytics or external services in v1."* All external dependencies are either bundled into the application or served from the user's own infrastructure.

| Integration | Type | Status | Delivery |
|-------------|------|--------|---------|
| USWDS | UI design system | Required | Bundled via npm (no CDN) |
| Montserrat | Font | Required | Self-hosted WOFF2 in `/public/fonts/` |
| Fraunces | Font | Required | Self-hosted WOFF2 in `/public/fonts/` |
| Open Sans | Font | Required | Self-hosted WOFF2 in `/public/fonts/` |
| JetBrains Mono | Font | Required | Self-hosted WOFF2 in `/public/fonts/` |
| PostgreSQL | Database | Required (primary) | User's own instance (local or Docker) |
| SQLite | Database | Required (alt) | Embedded via better-sqlite3 |
| Node.js runtime | Server | Required | User's own server / PaaS |
| Service Worker (Workbox) | Offline cache | Optional (progressive) | Bundled |

---

### 7.2 USWDS Integration

| Property | Specification |
|----------|--------------|
| Source | npm package `@uswds/uswds` |
| Version | Latest stable (pin exact version in package.json) |
| Delivery | Bundled with app via Next.js CSS import chain — NOT loaded from CDN |
| CSS import | `@import '@uswds/uswds/scss/uswds';` in `styles/globals.css` |
| Token override | TechSur brand tokens in `styles/techsur-tokens.css` applied after USWDS |
| Component usage | USWDS HTML markup patterns + CSS classes; no USWDS JavaScript components required (React components replace JS behavior) |
| Accessibility | USWDS provides WCAG 2.1 AA-compliant markup patterns; all custom components must match or exceed this baseline |

---

### 7.3 Font Delivery

All four font families are self-hosted to comply with the privacy requirement (no CDN requests that expose user IP addresses).

**Delivery process:**
1. Download WOFF2 (and WOFF fallback) files from the open-source repositories
2. Place in `/public/fonts/` directory
3. Declare via `@font-face` in `styles/fonts.css`
4. Import `fonts.css` in `app/layout.tsx`

**Font licenses:** All four families are released under the SIL Open Font License (OFL). Verify license compliance at project start.

**Font loading strategy:**
- `font-display: swap` to prevent invisible text during font load
- Preload critical fonts (Montserrat 700/900, Open Sans 400) in `<head>` via Next.js `<link rel="preload">`
- JetBrains Mono loaded asynchronously (label/badge use only; not render-blocking)

---

### 7.4 Database Integration

#### PostgreSQL (Primary)

| Property | Specification |
|----------|--------------|
| Driver | `node-postgres` (`pg`) npm package |
| Connection | Pool via `new Pool({ connectionString: process.env.DATABASE_URL })` |
| Pool size | Default (10 connections) — single-user app, effectively 1 concurrent user |
| Connection string | Set via `DATABASE_URL` environment variable |
| Migration tool | `node-pg-migrate` — migrations in `db/migrations/` |
| Local dev | `docker-compose.yml` with `postgres:15` image for local development |

```yaml
# docker-compose.yml (development)
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: simplewineapp
      POSTGRES_USER: wine
      POSTGRES_PASSWORD: localdev
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
volumes:
  pgdata:
```

#### SQLite (Alternative)

| Property | Specification |
|----------|--------------|
| Driver | `better-sqlite3` npm package |
| File location | `./data/simplewineapp.db` (configurable via env var) |
| UUID generation | `crypto.randomUUID()` in application layer (SQLite has no `gen_random_uuid()`) |
| DDL adaptations | Remove `TIMESTAMPTZ` → `TEXT` (ISO 8601 strings); `NUMERIC` → `REAL`; functional index on `LOWER()` → enforce in app layer |
| Selection | Active driver selected via `DATABASE_DRIVER=postgres` or `DATABASE_DRIVER=sqlite` env var |

---

### 7.5 Offline Support (Service Worker)

| Property | Specification |
|----------|--------------|
| Library | Workbox (via `next-pwa` npm package) |
| Scope | Progressive enhancement — read-only offline; no offline write in v1 |
| Cache strategy | `StaleWhileRevalidate` for wine list data; `CacheFirst` for static assets |
| Cached resources | Static assets (JS, CSS, fonts, icons) + wine list API response |
| Cache invalidation | On next successful network request, stale cache replaced |
| Registration | Service worker registered in `app/layout.tsx` (production only) |

---

### 7.6 Deferred / Explicitly Excluded Integrations

The following integrations are explicitly excluded from v1 and must not be added without a PRD revision:

| Integration | Phase | Reason |
|-------------|-------|--------|
| External wine database (Wine Searcher, Vivino) | Phase 3 | External data dependency; cost; complexity |
| Label scanning / OCR | Phase 3 | Native camera API + ML service; significant UX complexity |
| AI-assisted bottle entry | Phase 3 | LLM API cost, latency, dependency on label scanning |
| Push / drinking window alerts | Phase 2 | Notification permission flow; deferred after base workflow proven |
| CSV / Excel import | Phase 2 | Non-trivial parsing; deferred after core CRUD proven |
| PDF / spreadsheet export | Phase 2 | Low-priority future scope |
| Third-party analytics (GA, Mixpanel, etc.) | Excluded | Explicitly prohibited by PRD privacy requirement |
| OAuth / SAML authentication | Phase 2+ | Single-user app; no auth in v1 |
| Shared household accounts | Phase 4 | Multi-user architecture change |
| Wine valuation APIs | Phase 2 | User-entered value sufficient for v1 |
| Cellar map visualization | Phase 2 | Named location text sufficient for v1 |

---

## 8. Non-Functional Requirements — Implementation Notes

| Requirement | Target | Implementation |
|-------------|--------|---------------|
| Wine list render time | ≤ 300ms (500 records, mid-range mobile) | React Query caches full wine array; client-side filter in JS; no server round-trip |
| Search / filter update | ≤ 100ms | Client-side Fuse.js + pure filter function; 100ms debounce on search input |
| Dashboard API | ≤ 300ms (500 records) | Single optimized SQL query with aggregations; `GET /api/v1/dashboard` |
| WCAG 2.1 AA | All components | USWDS provides compliant baseline; readiness badges always include text label |
| Responsive | 375px, 768px, 1024px, 1280px | USWDS grid + CSS breakpoints; mobile-first; filter panel: drawer ↔ sidebar |
| Quantity floor | Never below 0 | − button `disabled` at 0; PATCH /quantity API validates `adjustment = -1` when qty = 0 |
| Offline read | Wine list + search functional offline | Service Worker caches wine list response; Fuse.js runs on cached data |
| Browser support | Chrome, Firefox, Safari, Edge (latest 2) | Next.js target: `browserslist` defaults; WOFF2 with WOFF fallback |
| Data destruction | Confirm before delete | `ConfirmationModal` required for delete wine, delete location actions |
| Touch targets | Min 44×44px | Applied via USWDS touch-target utility class on all interactive elements |

---

## 9. Architecture Decision Log

| ID | Decision | Alternatives Considered | Rationale |
|----|----------|------------------------|-----------|
| ADR-001 | Next.js 14 App Router as the framework | Vite + Express (separate API), Remix, SvelteKit | Next.js provides SSR (needed for server-side readiness calculation), unified deployment, and strong TypeScript ecosystem. Vite+Express adds ops complexity for no benefit in single-user context. |
| ADR-002 | PostgreSQL as primary database | SQLite only, MySQL, Supabase | FRD DDL is PostgreSQL-native. PostgreSQL's CHECK constraints and functional indexes are cleaner. SQLite retained as a portable alternative with minor DDL adaptation. |
| ADR-003 | Raw SQL via node-postgres (no ORM) | Prisma, Drizzle ORM, Sequelize | Collection of 5 simple tables with known query patterns. Raw SQL gives full control, zero ORM abstraction cost, and aligns with FRD DDL directly. Can migrate to Drizzle later if complexity grows. |
| ADR-004 | Client-side filtering with Fuse.js | Server-side filtering per request | ≤500 records NFR target means in-memory filtering is faster than a server round-trip. React Query caches the full list; filter runs locally. Server-side filter params provided as a future-proof fallback. |
| ADR-005 | Self-hosted fonts (WOFF2) | Google Fonts CDN | PRD §8 explicitly prohibits sending user data to external services. Google Fonts CDN would log user IPs. All four OFL-licensed fonts bundled locally. |
| ADR-006 | No authentication in v1 | Basic Auth at proxy, next-auth | Single-user personal-use app on user's own infrastructure. Auth adds complexity with no meaningful security benefit for this threat model. Phase 2 path documented. |
| ADR-007 | Readiness status calculated at response time | Stored/cached in DB column, background job | FRD F05 requires recalculation on every render using CURRENT_DATE. Pure function is trivial to compute; caching would introduce staleness risk. No scheduled job needed. |
| ADR-008 | latest_rating denormalized on `wines` table | JOIN to tasting_notes on every list query | Wine list renders per-card rating without a JOIN. Maintained by app logic after every tasting_note write. Performance trade-off is correct for this read-heavy, write-occasional pattern. |

---

*TechArch generated by Pivota Spec TechArch Generator · SimpleWineApp v1.0 MVP · 2026-06-03*
