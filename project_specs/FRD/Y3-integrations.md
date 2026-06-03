---

## Y3: External Integration Points

**Scope:** All external system dependencies, third-party services, and external data sources for SimpleWineApp v1 MVP.

---

### Summary

SimpleWineApp v1 is deliberately minimal in external dependencies. The single-user personal-use MVP has **no required external integrations** — all data is user-entered and stored locally or in a self-controlled data store. This is a design principle from the PRD: *"No user data sent to third-party analytics or external services in v1."*

The integrations documented here are:
1. **Required infrastructure dependencies** (hosting, data store, browser APIs)
2. **UI/asset dependencies** (fonts, design system)
3. **Explicitly deferred integrations** (documented to prevent scope creep)

---

### §1 — Required Infrastructure

#### §1.1 — Data Storage

| Property | Specification |
|----------|--------------|
| **Type** | Persistent relational data store |
| **Preferred** | PostgreSQL (see `Y0-schema.md` for DDL) |
| **Alternative** | SQLite (for local desktop/offline deployment), IndexedDB (browser-local PWA variant) |
| **Architecture** | TBD in TechArch; schema is storage-engine-agnostic except where PostgreSQL-specific syntax is noted |
| **Data residency** | User's own infrastructure or a self-hosted instance; no third-party SaaS database in v1 |
| **Backup** | Application does not manage backups in v1; responsibility falls to the infrastructure layer |

#### §1.2 — Web Hosting / Deployment

| Property | Specification |
|----------|--------------|
| **Type** | Static web host + API server (or unified server-rendered app) |
| **Target** | Any standard web hosting environment capable of running the chosen application stack |
| **CDN** | Optional; no CDN-specific dependencies in the application code |
| **HTTPS** | Required for production deployment; enforced by hosting layer |

---

### §2 — UI & Asset Dependencies

#### §2.1 — USWDS (U.S. Web Design System)

| Property | Specification |
|----------|--------------|
| **Source** | [https://designsystem.digital.gov](https://designsystem.digital.gov) |
| **Version** | Latest stable release at project start (pin version in package.json) |
| **Delivery** | Bundled with the application; NOT loaded from CDN (privacy and offline requirement) |
| **Usage** | CSS design tokens, component markup patterns, grid system, form components, accessibility patterns |
| **Customization** | TechSur brand tokens override USWDS default tokens via a CSS override layer (see `00-header.md §Brand & Design Token Reference`) |

#### §2.2 — Google Fonts (Typography)

| Property | Specification |
|----------|--------------|
| **Fonts required** | Montserrat (weights 700, 900), Fraunces (weights 400–600, italic), Open Sans (weights 400, 600, 700), JetBrains Mono (weights 400, 500) |
| **Delivery** | Self-hosted font files bundled with application (NOT loaded from Google Fonts CDN — privacy requirement: no user data sent to external services) |
| **Fallback stack** | Montserrat → system-ui → sans-serif; JetBrains Mono → Courier New → monospace |
| **Format** | WOFF2 (primary), WOFF (fallback) |
| **License** | Verify open font licenses for all four families at project start (all are OFL as of this writing) |

---

### §3 — Browser & Device APIs

#### §3.1 — Browser Storage (Offline Support)

| Property | Specification |
|----------|--------------|
| **Requirement** | Core wine list read and search functional offline (progressive enhancement) |
| **Mechanism** | Service Worker + Cache API (for static assets and wine list data) or localStorage/IndexedDB for wine data cache |
| **Scope** | Read-only offline in v1 — no offline write required |
| **Implementation** | TBD in TechArch; service worker registration is application-layer concern |

#### §3.2 — Date & Time

| Property | Specification |
|----------|--------------|
| **Source** | System clock (`Date` object or server-side `NOW()`) |
| **Timezone handling** | All stored timestamps in UTC; drinking window comparison uses UTC calendar year; display dates may render in user's local timezone |
| **No external NTP** | Application trusts the host system clock; no external time-sync service |

---

### §4 — Explicitly Deferred Integrations (Out of Scope for v1)

The following integrations are explicitly excluded from v1 and must not be added without a new PRD revision and approval:

| Integration | Phase | Reason Deferred |
|-------------|-------|----------------|
| External wine database (Wine Searcher, Vivino, Wine API) | Phase 3 | Adds complexity, potential costs, external data dependency; personal entry is proven first |
| Label scanning / OCR (camera + ML) | Phase 3 | Requires native device APIs, third-party ML service, significant UX complexity |
| AI-assisted bottle entry | Phase 3 | Depends on label scanning or external wine database; LLM API cost and latency management out of MVP scope |
| Push notifications / alerts | Phase 2 | Drinking window alerts require notification permission; deferred after MVP proves base workflow |
| CSV / Excel import | Phase 2 | Non-trivial parsing and error handling; deferred until core CRUD is proven |
| PDF / spreadsheet export | Phase 2 | Low-priority future scope |
| Third-party analytics (Google Analytics, Mixpanel, etc.) | Not in v1 | Explicitly prohibited: "No user data sent to third-party analytics or external services in v1" (PRD §8 Non-Functional Requirements) |
| Authentication providers (OAuth, SAML, Azure AD) | Phase 2+ | Single-user app in v1; no auth layer required |
| Shared household accounts | Phase 4 | Multi-user architecture change; deferred per PRD |
| Wine valuation APIs | Phase 2 | Estimated value is user-entered in v1 |
| Cellar / storage map visualization | Phase 2 | 2D/3D visualization deferred; storage by name is sufficient for v1 |

---

### §5 — Privacy & Data Sovereignty

Per PRD §8 (Non-Functional Requirements):

- **No telemetry:** The application must not send any user data to third-party analytics, crash reporting, or monitoring services in v1. Server-side error logging is acceptable if it is self-hosted and does not transmit to external endpoints.
- **No CDN font loading:** Fonts must be self-hosted to prevent Google Fonts / CDN from logging user IP addresses.
- **No external API calls from the client:** All application functionality in v1 must be fulfilled from the application's own backend. No client-side API calls to external wine databases, pricing services, or any third-party endpoint.
- **Data residency:** User wine data must remain within the user's chosen deployment environment (local or self-hosted cloud). No mandatory cloud sync to external services.

---

*Y3 integrations catalog · SimpleWineApp v1.0 MVP · 2026-06-03*
