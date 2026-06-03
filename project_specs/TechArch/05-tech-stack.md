---

## 6. Technology Stack

### 6.1 Full Stack Table

| Layer | Technology | Version | Purpose |
|-------|------------|---------|---------|
| **Framework** | Next.js | 14.x+ (App Router) | Full-stack React framework; UI + API routes in one process |
| **Language** | TypeScript | 5.x | Type-safe development across frontend and backend |
| **UI Framework** | React | 18.x | Component model for interactive UI |
| **Design System** | USWDS | Latest stable | Accessible component patterns, design tokens, grid system |
| **Brand Layer** | Custom CSS (CSS custom properties) | — | TechSur brand tokens as CSS override layer on USWDS |
| **Database (primary)** | PostgreSQL | 15+ | Relational data store; full FRD DDL support |
| **Database (alt)** | SQLite | 3.x (via better-sqlite3) | Portable local deployment alternative |
| **DB Client** | node-postgres (pg) | 8.x | PostgreSQL driver with connection pool |
| **DB Client (alt)** | better-sqlite3 | 9.x | Synchronous SQLite driver |
| **Validation** | Zod | 3.x | Runtime schema validation + TypeScript inference |
| **Server State** | TanStack Query (React Query) | 5.x | Client-side data fetching, caching, background sync |
| **Client Filter** | Fuse.js | 7.x | Fuzzy full-text search for client-side wine list filtering |
| **Migrations** | node-pg-migrate | 6.x | Version-controlled schema migrations |
| **HTTP Client** | fetch (native) | — | Browser native; no extra library needed |
| **Styling** | CSS Modules + USWDS | — | Scoped component styles + USWDS design tokens |
| **Service Worker** | Workbox (via next-pwa) | 6.x | Offline read cache (progressive enhancement) |
| **Runtime** | Node.js | 20 LTS | Server runtime for Next.js |
| **Package Manager** | npm | 10.x | Dependency management |

### 6.2 Key NPM Dependencies

```json
{
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "typescript": "^5.0.0",
    "@uswds/uswds": "^3.0.0",
    "zod": "^3.0.0",
    "@tanstack/react-query": "^5.0.0",
    "fuse.js": "^7.0.0",
    "pg": "^8.0.0",
    "better-sqlite3": "^9.0.0"
  },
  "devDependencies": {
    "@types/pg": "^8.0.0",
    "@types/better-sqlite3": "^7.0.0",
    "@types/react": "^18.0.0",
    "@types/node": "^20.0.0",
    "node-pg-migrate": "^6.0.0",
    "eslint": "^8.0.0",
    "eslint-config-next": "^14.0.0"
  }
}
```

### 6.3 Fonts

Self-hosted as WOFF2 files in `/public/fonts/`. Declared in root CSS via `@font-face`. No CDN loading.

| Font Family | Weights Loaded | Usage |
|-------------|---------------|-------|
| Montserrat | 700, 900 | Headings, buttons, eyebrows |
| Fraunces | 400, 600 (italic) | Serif accent, emphasis |
| Open Sans | 400, 600, 700 | Body copy, form labels, UI text |
| JetBrains Mono | 400, 500 | Labels, badges, eyebrows (UPPERCASE) |

**CSS font-face declarations** (in `styles/fonts.css`, imported in root layout):
```css
@font-face {
  font-family: 'Montserrat';
  src: url('/fonts/montserrat-700.woff2') format('woff2'),
       url('/fonts/montserrat-700.woff') format('woff');
  font-weight: 700;
  font-style: normal;
  font-display: swap;
}
/* ... additional weights and families */
```

### 6.4 TechSur Brand Tokens (CSS Custom Properties)

Defined in `styles/techsur-tokens.css`, imported after USWDS base styles:

```css
:root {
  /* Color palette */
  --color-gold-400: #FBCA5C;   /* Primary accent: CTAs, Drink Now badge, primary buttons */
  --color-gold-500: #E6B040;   /* Serif accent on light backgrounds */
  --color-gold-600: #B0832A;   /* Gold text on light bg (contrast-safe) */
  --color-canvas-dark: #0A0A0A; /* Hero areas, nav background (dark) */
  --color-bone: #FAFAF7;        /* Light canvas, page background */
  --color-paper: #F5F5F2;       /* Alt card surface */
  --color-ink: #1A1A1A;         /* Body text on light */
  --color-gray-400: #A8A59B;    /* Muted labels, secondary text */

  /* Readiness status badge colors */
  --color-drink-now: #FBCA5C;          /* Gold 400 */
  --color-approaching-peak: #F5A623;   /* Amber */
  --color-hold: #D4D1C9;               /* Gray 300 */
  --color-past-window: #E8E6E1;        /* Gray 200 */

  /* Typography */
  --font-display: 'Montserrat', system-ui, sans-serif;
  --font-accent: 'Fraunces', Georgia, serif;
  --font-body: 'Open Sans', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', 'Courier New', monospace;

  /* Button */
  --radius-button: 2px;
}
```

**USWDS token overrides** (in same or adjacent file):
```css
/* Override USWDS font family tokens */
:root {
  --theme-font-type-sans: 'Open Sans', system-ui, sans-serif;
  --theme-font-type-serif: 'Fraunces', Georgia, serif;
  --theme-font-type-mono: 'JetBrains Mono', 'Courier New', monospace;
  --theme-color-primary: #FBCA5C;
  --theme-color-primary-dark: #E6B040;
}
```

### 6.5 Project Directory Structure

```
simplewineapp/
├── app/                          ← Next.js App Router pages + API routes
│   ├── layout.tsx
│   ├── page.tsx                  ← Dashboard
│   ├── wines/
│   ├── locations/
│   ├── settings/
│   └── api/v1/
├── components/                   ← Reusable React components
│   ├── wine/
│   ├── dashboard/
│   ├── filter/
│   ├── tasting-notes/
│   ├── locations/
│   └── shared/
├── lib/                          ← Server-side business logic + DB
│   ├── db.ts
│   ├── validation/
│   ├── queries/
│   └── business/
├── styles/                       ← Global CSS
│   ├── globals.css
│   ├── fonts.css
│   └── techsur-tokens.css
├── public/
│   ├── fonts/                    ← Self-hosted WOFF2 font files
│   └── icons/
├── db/
│   └── migrations/               ← node-pg-migrate migration files
├── types/                        ← Shared TypeScript interfaces (index.ts)
├── .env.local                    ← Local dev secrets (gitignored)
├── next.config.ts
├── tsconfig.json
└── package.json
```

---
