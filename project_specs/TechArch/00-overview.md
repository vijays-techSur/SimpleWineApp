# Technical Architecture Document
## SimpleWineApp — Personal Wine Collection Manager

**Project:** SimpleWineApp
**TechArch Version:** 1.0
**PRD Reference:** PRD-SimpleWineApp.md v1.0
**FRD Reference:** FRD-SimpleWineApp.md v1.0
**Date:** 2026-06-03
**Status:** Draft
**Author:** Pivota Spec TechArch Generator

---

## 1. Architectural Overview

### 1.1 Architecture Pattern

SimpleWineApp is a **full-stack web application** following a **layered monolith** pattern with a clear client/server separation. The architecture prioritizes simplicity, fast iteration, and data sovereignty — the defining constraints of a single-user personal-use MVP.

**Pattern:** Next.js Full-Stack Monolith (App Router)
- Frontend: React (via Next.js App Router) with USWDS + TechSur brand overlay
- Backend: Next.js API Routes (serverless-compatible) serving REST endpoints at `/api/v1`
- Database: PostgreSQL (primary) with SQLite as a portable alternative for local/self-hosted deployments
- All data remains within the user's own deployment environment — no external SaaS data dependencies

**Rationale for Next.js:**
- Unified codebase reduces operational complexity for a single-developer/personal-use project
- App Router enables server-side rendering for readiness status calculation at request time (required by F05)
- API routes provide a clean REST surface without a separate server process
- First-class TypeScript support for type-safe API boundaries
- Strong ecosystem compatibility with USWDS (vanilla CSS + JS design system)
- Excellent static export and self-hosting options satisfy the data sovereignty requirement

**Why not a SPA + separate API server?**  
Adds deployment complexity (two processes, CORS configuration, separate hosting) with no benefit for a single-user app. Next.js API routes eliminate this overhead.

**Why PostgreSQL (primary)?**  
The FRD DDL uses PostgreSQL-specific syntax (`gen_random_uuid()`, `TIMESTAMPTZ`, functional indexes on `LOWER()`). PostgreSQL provides the CHECK constraints, cascade rules, and index types required. SQLite is supported as a portable fallback for local-only deployments (minor DDL adaptation needed for UUID generation and some constraints).

---

### 1.2 System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Browser (Client)                             │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                    Next.js App Router                        │   │
│  │                                                              │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │   │
│  │  │  Dashboard  │  │  Wine List  │  │  Wine Detail / Form │  │   │
│  │  │   (F06)     │  │  + Filter   │  │  + Tasting Notes    │  │   │
│  │  │             │  │   (F03)     │  │  + Bottle Events    │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘  │   │
│  │                                                              │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │   │
│  │  │  Storage    │  │  Settings   │  │  Client-Side Filter │  │   │
│  │  │  Locations  │  │  (F04.6)    │  │  Engine (F03)       │  │   │
│  │  │   (F02)     │  │             │  │                     │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘  │   │
│  │                                                              │   │
│  │  ┌──────────────────────────────────────────────────────┐   │   │
│  │  │           USWDS + TechSur Brand CSS Layer            │   │   │
│  │  │   Self-hosted fonts (Montserrat, Fraunces, Open      │   │   │
│  │  │   Sans, JetBrains Mono) · Mobile-first responsive    │   │   │
│  │  └──────────────────────────────────────────────────────┘   │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                     │
│           Service Worker (offline read cache — progressive)         │
└────────────────────────────┬────────────────────────────────────────┘
                             │ HTTPS / HTTP (same origin)
                             │ JSON (application/json)
┌────────────────────────────▼────────────────────────────────────────┐
│                     Next.js API Routes (/api/v1)                    │
│                      (Node.js runtime)                              │
│                                                                     │
│  ┌────────────┐ ┌──────────────┐ ┌────────────┐ ┌───────────────┐  │
│  │  /wines    │ │  /locations  │ │ /dashboard │ │  /settings    │  │
│  │  (F00/F01) │ │    (F02)     │ │   (F06)    │ │  (F04 scale)  │  │
│  └────────────┘ └──────────────┘ └────────────┘ └───────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │           Business Logic Layer                               │   │
│  │  · Validation (Zod schemas)                                  │   │
│  │  · Readiness status calculation (F05 algorithm)              │   │
│  │  · latest_rating denormalization (F04 post-write)            │   │
│  │  · location_unknown flag management (F02 delete cascade)     │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │           Data Access Layer (node-postgres / pg)             │   │
│  │                 Parameterized SQL queries                    │   │
│  └──────────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────────┘
                             │ TCP (local network or loopback)
┌────────────────────────────▼────────────────────────────────────────┐
│                        PostgreSQL                                   │
│                                                                     │
│   wines · storage_locations · bottle_events                         │
│   tasting_notes · user_settings                                     │
│                                                                     │
│   (SQLite alternative: better-sqlite3 driver, adapted DDL)          │
└─────────────────────────────────────────────────────────────────────┘
```

---

### 1.3 Deployment Topology

SimpleWineApp is designed for **self-hosted single-user deployment**. The application is a unified Next.js process that handles both the web UI and the REST API.

```
┌─────────────────────────────────────────────┐
│               Deployment Host               │
│         (VPS, home server, or local)        │
│                                             │
│  ┌────────────────────────────────────────┐ │
│  │     Next.js process (npm start)        │ │
│  │     PORT 3000 (or env-configured)      │ │
│  └────────────────────────────────────────┘ │
│                                             │
│  ┌────────────────────────────────────────┐ │
│  │  PostgreSQL (local or Docker)          │ │
│  │  Port 5432 (loopback only)             │ │
│  └────────────────────────────────────────┘ │
│                                             │
│  ┌────────────────────────────────────────┐ │
│  │  Reverse proxy: Nginx / Caddy          │ │
│  │  · HTTPS termination                   │ │
│  │  · Proxy → Next.js :3000               │ │
│  └────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

**Alternatively:** The app can be deployed to any Node.js-compatible PaaS (Railway, Fly.io, Render, DigitalOcean App Platform) with a managed PostgreSQL add-on, provided the user controls the database and no data is transmitted to third-party analytics.

**Environment variables:**
```
DATABASE_URL=postgresql://user:pass@localhost:5432/simplewineapp
NODE_ENV=production
NEXT_PUBLIC_APP_VERSION=1.0.0
```

---

### 1.4 Key Architectural Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Framework | Next.js 14+ (App Router) | Unified full-stack, SSR for readiness calculation, TypeScript-first |
| Language | TypeScript | Type safety across API boundaries; reduces runtime errors |
| Database (primary) | PostgreSQL 15+ | FRD DDL is PostgreSQL-native; supports all required constraints |
| Database (alt) | SQLite via better-sqlite3 | Portable local deployment; simpler ops for single-user |
| ORM/Query | Raw SQL via node-postgres (pg) | Full control of query shape; no ORM abstraction overhead for simple queries |
| Validation | Zod | Runtime schema validation for all API inputs; TypeScript inference |
| State management | React Query (TanStack Query) | Server state, caching, background refetch for wine list |
| Client-side filter | In-memory JS (Fuse.js for text) | ≤500 records target; no server round-trip; instant search (F03 NFR) |
| Font delivery | Self-hosted WOFF2 | Privacy requirement — no CDN calls to Google Fonts |
| USWDS delivery | npm bundle (no CDN) | Privacy + offline requirements |
| Offline read | Service Worker + Cache API | Progressive enhancement; read-only offline (F03 NFR) |
| Auth | None (v1) | Single-user personal-use; no auth required in MVP |
| UUID generation | `crypto.randomUUID()` (app layer) | Portable; no DB-specific extension required beyond `gen_random_uuid()` |

---
