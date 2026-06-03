---

## 5. Security Architecture

### 5.1 Authentication

**v1 MVP: No authentication layer.** SimpleWineApp is a single-user personal-use application deployed in the user's own environment (local machine, home server, or private VPS). No user accounts, sessions, or tokens exist in v1.

**Rationale:**
- A personal app accessed only by the owner on their own network has no meaningful multi-user threat vector
- Adding auth complexity would increase the barrier to self-hosting without providing value
- PRD explicitly defers authentication to Phase 2+ ("Single-user app in v1 — no auth layer required in MVP")

**Phase 2 auth path (documented for future reference):**
- JWT sessions via Next.js middleware (`next-auth` / `lucia-auth`)
- Or HTTP Basic Auth at the reverse proxy layer (Nginx/Caddy) for minimal friction
- API routes annotated with middleware hooks to be un-commented when auth is added

---

### 5.2 Authorization

No role-based or attribute-based authorization in v1. All API routes are accessible without a token. The access model is:

```
User (sole owner) → Full access to all endpoints
```

When Phase 2 auth is added, all API routes will require a valid session. The single-user constraint means all data is owned by the authenticated user — no resource-level ownership checks are needed in v1 (only one "account" exists).

---

### 5.3 Input Validation & Injection Prevention

All API inputs are validated with **Zod** schemas before any database operation. Validation occurs at the API route handler, before reaching the query layer.

**Validation strategy:**

| Layer | Mechanism |
|-------|-----------|
| HTTP request body | Zod schema parse — rejects unknown fields, enforces types and constraints |
| Query parameters | Zod schema coerce — type-coerce strings to integers/numbers; validate enum values |
| String fields | Max length enforced by Zod before reaching DB |
| Enum fields | Zod enum validation; only exact values accepted |
| Date fields | Zod string().regex() + refine() for ISO 8601; future-date check in business logic |
| Cross-field rules | Zod `.superRefine()` for window start ≤ end, rating range, etc. |

**SQL injection prevention:**
All database queries use **parameterized queries** exclusively via `node-postgres` (`pg`). No string concatenation into SQL. Example:

```typescript
// Correct — parameterized
const result = await db.query(
  'SELECT * FROM wines WHERE wine_id = $1',
  [wineId]
);

// Never — string interpolation
// const result = await db.query(`SELECT * FROM wines WHERE wine_id = '${wineId}'`);
```

**HTML/script injection:**
All user-supplied text fields are stored as plain text. The API does not accept or return HTML. The React frontend escapes all text content by default (React's built-in XSS protection). No `dangerouslySetInnerHTML` is used.

---

### 5.4 Data Protection

**Privacy by design (PRD §8 Non-Functional Requirements):**

| Requirement | Implementation |
|-------------|---------------|
| No third-party analytics | No analytics script loaded; no telemetry calls in application code |
| No CDN font loading | All fonts bundled as WOFF2 files; served from `/public/fonts/` |
| No external API calls from client | All network requests go to same-origin `/api/v1` only |
| No third-party CDN for USWDS | USWDS installed as npm package; assets served from app bundle |
| Data residency | All data stays in user's PostgreSQL instance; no cloud sync |

**HTTPS:**
Required for production deployment. Enforced at the reverse proxy layer (Nginx/Caddy with TLS). Next.js itself runs over HTTP behind the proxy on the loopback interface only.

**Database access:**
PostgreSQL listens on loopback (`127.0.0.1:5432`) only. No external database port exposure. The application connects using environment variable `DATABASE_URL` — never hardcoded credentials.

**Environment secrets:**
```
DATABASE_URL      # Connection string (never committed to source control)
```
Use `.env.local` for development (`.gitignore`'d). Use host environment variables or a secrets manager for production.

---

### 5.5 Content Security Policy (CSP)

Configure via Next.js `headers()` in `next.config.ts`:

```
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'nonce-{RANDOM}';
  style-src 'self' 'unsafe-inline';  ← USWDS inline styles require this; tighten post-MVP
  font-src 'self';                    ← Self-hosted fonts only; no CDN
  img-src 'self' data:;
  connect-src 'self';                 ← API calls to same origin only
  frame-ancestors 'none';
  form-action 'self';
```

**Rationale for `unsafe-inline` on style-src:** USWDS applies some inline styles via JavaScript. This can be eliminated post-MVP by extracting USWDS to a fully static CSS bundle.

---

### 5.6 HTTP Security Headers

All responses include security headers via Next.js middleware or `next.config.ts`:

| Header | Value |
|--------|-------|
| `X-Content-Type-Options` | `nosniff` |
| `X-Frame-Options` | `DENY` |
| `Referrer-Policy` | `no-referrer` |
| `Permissions-Policy` | `camera=(), microphone=(), geolocation=()` |
| `Strict-Transport-Security` | `max-age=63072000; includeSubDomains` (set at reverse proxy) |

---

### 5.7 Data Integrity Rules

These constraints protect data integrity at the application and database layers:

| Rule | Enforcement Layer |
|------|------------------|
| `quantity` cannot go below 0 | Application (disabled − button at 0) + DB CHECK constraint |
| Required fields enforced on write | Zod validation + DB NOT NULL |
| Enum values validated | Zod enum + DB CHECK constraint |
| Vintage year 1900–(currentYear+1) | Zod refine() in application layer |
| Purchase date not in future | Application validation (Zod refine) |
| Event date not in future | Application validation + DB CHECK (CURRENT_DATE) |
| Drinking window start ≤ end | Application (Zod superRefine) + DB CHECK constraint |
| Cascade deletes (wine → events, notes) | DB ON DELETE CASCADE |
| Location delete → flag wines | Application logic (SET NULL + location_unknown = TRUE) |
| `latest_rating` cache consistency | Application logic: refresh on every tasting_note write |

---
