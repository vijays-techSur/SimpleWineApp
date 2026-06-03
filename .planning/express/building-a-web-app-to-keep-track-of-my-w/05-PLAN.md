---
phase: 05-frontend-setup
plan: 05
type: execute
wave: 5
depends_on: [2, 3, 4]
files_modified:
  - package.json
  - next.config.ts
  - tsconfig.json
  - .env.local.example
  - styles/globals.css
  - styles/fonts.css
  - styles/techsur-tokens.css
  - public/fonts/montserrat-700.woff2
  - public/fonts/montserrat-900.woff2
  - public/fonts/fraunces-400-italic.woff2
  - public/fonts/fraunces-600-italic.woff2
  - public/fonts/open-sans-400.woff2
  - public/fonts/open-sans-600.woff2
  - public/fonts/open-sans-700.woff2
  - public/fonts/jetbrains-mono-400.woff2
  - public/fonts/jetbrains-mono-500.woff2
  - app/layout.tsx
  - app/globals.css
  - components/navigation/AppHeader.tsx
  - components/navigation/AppNav.tsx
  - components/navigation/MobileBottomNav.tsx
  - components/navigation/FloatingAddButton.tsx
  - components/navigation/index.ts
  - types/index.ts
autonomous: true

features:
  implements: ["F0", "F1", "F2", "F3", "F4", "F5", "F6"]
  depends_on: ["F0", "F1", "F2", "F4", "F5", "F6"]
  enables: ["F0", "F1", "F2", "F3", "F4", "F5", "F6"]

must_haves:
  truths:
    - "Next.js 14 App Router project scaffolds and dev server starts without errors"
    - "USWDS npm package installed and CSS imports correctly via globals.css"
    - "All 15 TechSur brand tokens defined as CSS custom properties (exact values from TechArch §6.4)"
    - "All USWDS theme token overrides applied (--theme-font-type-san, --theme-color-primary, etc.)"
    - "All 4 font families self-hosted as WOFF2 files with @font-face declarations in fonts.css"
    - "Root layout (app/layout.tsx) imports fonts.css, techsur-tokens.css, USWDS CSS, and mounts NavigationShell"
    - "MobileBottomNav renders bottom tabs (Dashboard | Cellar | Settings) + Gold FAB on screens <768px"
    - "AppHeader renders horizontal nav (Dashboard | My Cellar | Settings) + '+ Add Wine' button on screens ≥768px"
    - "Shared TypeScript interfaces (WineRecord, TastingNote, StorageLocation, etc.) exported from types/index.ts"
  artifacts:
    - path: "styles/techsur-tokens.css"
      provides: "All 15 TechSur brand tokens + USWDS theme overrides"
      contains: "--color-gold-400"
    - path: "styles/fonts.css"
      provides: "@font-face declarations for Montserrat, Fraunces, Open Sans, JetBrains Mono"
      contains: "@font-face"
    - path: "app/layout.tsx"
      provides: "Root layout with navigation shell and CSS imports"
      exports: ["default"]
    - path: "components/navigation/AppHeader.tsx"
      provides: "Desktop navigation header component"
      exports: ["AppHeader"]
    - path: "components/navigation/MobileBottomNav.tsx"
      provides: "Mobile bottom tab bar + FAB component"
      exports: ["MobileBottomNav"]
    - path: "types/index.ts"
      provides: "Shared TypeScript interfaces for all wave 3 components"
      exports: ["WineRecord", "TastingNote", "StorageLocation", "BottleEvent", "DashboardResponse", "ReadinessStatus", "WineSortKey", "FilterState"]
  key_links:
    - from: "app/layout.tsx"
      to: "styles/fonts.css"
      via: "import '../styles/fonts.css'"
      pattern: "fonts\\.css"
    - from: "app/layout.tsx"
      to: "styles/techsur-tokens.css"
      via: "import '../styles/techsur-tokens.css'"
      pattern: "techsur-tokens\\.css"
    - from: "app/layout.tsx"
      to: "components/navigation"
      via: "import { AppHeader, MobileBottomNav, FloatingAddButton }"
      pattern: "components/navigation"
    - from: "components/navigation/AppHeader.tsx"
      to: "app/wines/page.tsx"
      via: "next/link href='/wines'"
      pattern: "href.*wines"

integration_contracts:
  requires:
    - from_plan: "02"
      artifact: "app/api/v1/wines/route.ts"
      exports: ["GET", "POST"]
      verify: "grep -n 'export.*GET\\|export.*POST' app/api/v1/wines/route.ts && echo CONTRACT_OK"
    - from_plan: "03"
      artifact: "app/api/v1/locations/route.ts"
      exports: ["GET", "POST"]
      verify: "grep -n 'export.*GET\\|export.*POST' app/api/v1/locations/route.ts && echo CONTRACT_OK"
    - from_plan: "04"
      artifact: "app/api/v1/dashboard/route.ts"
      exports: ["GET"]
      verify: "grep -n 'export.*GET' app/api/v1/dashboard/route.ts && echo CONTRACT_OK"
    - from_plan: "04"
      artifact: "lib/filter/filterWines.ts"
      exports: ["filterWines", "FilterState"]
      verify: "grep -n 'export.*filterWines\\|export.*FilterState' lib/filter/filterWines.ts && echo CONTRACT_OK"
  provides:
    - artifact: "types/index.ts"
      exports: ["WineRecord", "TastingNote", "StorageLocation", "BottleEvent", "DashboardResponse", "ReadinessStatus", "WineSortKey", "FilterState", "WineType", "BottleSize", "RatingScale", "WouldBuyAgain", "DashboardStats", "DrinkNowCard"]
      shape: |
        // All shared TypeScript interfaces consumed by wave 3 component plans (06, 07, 08)
        export type WineType = 'RED' | 'WHITE' | 'ROSE' | 'SPARKLING' | 'DESSERT' | 'FORTIFIED'
        export type ReadinessStatus = 'DRINK_NOW' | 'APPROACHING_PEAK' | 'HOLD' | 'PAST_WINDOW' | 'NO_WINDOW_SET'
        export interface WineRecord { wine_id: string; wine_name: string; producer: string; vintage_year: number; wine_type: WineType; quantity: number; readiness_status: ReadinessStatus; storage_location_name: string | null; latest_rating: number | null; ... }
        export interface TastingNote { note_id: string; wine_id: string; date_tasted: string; personal_rating: number | null; rating_scale: RatingScale | null; ... }
        export interface StorageLocation { location_id: string; location_name: string; bottle_count?: number; created_at: string; updated_at: string; }
        export interface DashboardResponse { stats: DashboardStats; drink_now_shelf: DrinkNowCard[]; breakdown_by_type: BreakdownByTypeRow[]; breakdown_by_region: BreakdownByRegionRow[]; breakdown_by_decade: BreakdownByDecadeRow[]; recently_added: RecentlyAddedItem[]; recently_consumed: RecentlyConsumedItem[]; highest_rated: HighestRatedItem[]; }
      verify: "grep -n 'export.*WineRecord\\|export.*TastingNote\\|export.*StorageLocation\\|export.*DashboardResponse' types/index.ts && echo CONTRACT_OK"
    - artifact: "styles/techsur-tokens.css"
      exports: ["--color-gold-400", "--color-canvas-dark", "--color-bone", "--color-ink", "--font-display", "--font-body", "--font-mono", "--radius-button"]
      shape: |
        :root {
          --color-gold-400: #FBCA5C;
          --color-gold-500: #E6B040;
          --color-gold-600: #B0832A;
          --color-canvas-dark: #0A0A0A;
          --color-bone: #FAFAF7;
          --color-paper: #F5F5F2;
          --color-ink: #1A1A1A;
          --color-gray-400: #A8A59B;
          --color-drink-now: #FBCA5C;
          --color-approaching-peak: #F5A623;
          --color-hold: #D4D1C9;
          --color-past-window: #E8E6E1;
          --font-display: 'Montserrat', system-ui, sans-serif;
          --font-accent: 'Fraunces', Georgia, serif;
          --font-body: 'Open Sans', system-ui, sans-serif;
          --font-mono: 'JetBrains Mono', 'Courier New', monospace;
          --radius-button: 2px;
        }
      verify: "grep -n 'color-gold-400.*FBCA5C' styles/techsur-tokens.css && grep -n 'color-canvas-dark.*0A0A0A' styles/techsur-tokens.css && grep -n 'radius-button.*2px' styles/techsur-tokens.css && echo CONTRACT_OK"
    - artifact: "app/layout.tsx"
      exports: ["default"]
      shape: |
        // Root layout importing all styles and mounting navigation shell
        // Children wrapped in <QueryClientProvider> for React Query (wave 3 pages)
        export default function RootLayout({ children }: { children: React.ReactNode })
      verify: "grep -n 'export default.*RootLayout\\|export default function RootLayout' app/layout.tsx && grep -n 'techsur-tokens\\|fonts.css' app/layout.tsx && echo CONTRACT_OK"
    - artifact: "components/navigation/MobileBottomNav.tsx"
      exports: ["MobileBottomNav"]
      shape: |
        // Renders bottom tab bar at <768px: Dashboard | Cellar | Settings tabs + Gold FAB
        export function MobileBottomNav(): JSX.Element
      verify: "grep -n 'export.*MobileBottomNav\\|export function MobileBottomNav' components/navigation/MobileBottomNav.tsx && echo CONTRACT_OK"
    - artifact: "components/navigation/AppHeader.tsx"
      exports: ["AppHeader"]
      shape: |
        // Desktop header with horizontal nav + '+ Add Wine' button at >=768px
        export function AppHeader(): JSX.Element
      verify: "grep -n 'export.*AppHeader\\|export function AppHeader' components/navigation/AppHeader.tsx && echo CONTRACT_OK"
---

<objective>
Bootstrap the entire Next.js 14 App Router frontend project: install and configure USWDS, apply all TechSur design tokens (exact values from TechArch §6.4), self-host all four font families as WOFF2 files, create the Navigation Shell (desktop header + mobile bottom tabs + FAB), export all shared TypeScript interfaces, and set up the root layout. This plan is the prerequisite for all wave 3 component plans.

Purpose: Every subsequent frontend plan (wine list, detail/forms, dashboard) depends on: (1) the CSS token layer being present, (2) fonts loading from /public/fonts/, (3) types/index.ts exports for type-safe component props, and (4) the layout.tsx shell that wraps all pages.
Output: Working Next.js project with USWDS + TechSur brand layer, self-hosted fonts, navigation shell, and shared types. `npm run dev` must start without errors.
</objective>

<feature_dependencies>
Implements: F0–F6: Foundation for all features — USWDS component base + TechSur brand overlay enable every UI component across all features; Navigation Shell enables all page navigation
Depends on: Wave 2 (02–04) backend API endpoints (already planned) — frontend will call these in later plans
Enables: F0: Wine List/Detail/Forms, F1: Quantity controls UI, F2: Storage Locations UI, F3: Search & Filter panel, F4: Tasting Notes UI, F5: Readiness badge components, F6: Dashboard page components
</feature_dependencies>

<execution_context>
@/app/workspaces/.pivota-home/opencode-xdg/opencode/pivota_spec-framework/workflows/execute-plan.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/express/building-a-web-app-to-keep-track-of-my-w/WAVE-SCHEDULE.md
@project_specs/TechArch-SimpleWineApp.md
@project_specs/UX-Mockup-SimpleWineApp.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Project scaffold, USWDS install, TechSur design tokens, font self-hosting</name>
  <files>
    package.json
    next.config.ts
    tsconfig.json
    .env.local.example
    styles/globals.css
    styles/fonts.css
    styles/techsur-tokens.css
    public/fonts/montserrat-700.woff2
    public/fonts/montserrat-900.woff2
    public/fonts/fraunces-400-italic.woff2
    public/fonts/fraunces-600-italic.woff2
    public/fonts/open-sans-400.woff2
    public/fonts/open-sans-600.woff2
    public/fonts/open-sans-700.woff2
    public/fonts/jetbrains-mono-400.woff2
    public/fonts/jetbrains-mono-500.woff2
    types/index.ts
  </files>
  <action>
**Step 1: Create/update package.json**

Check if package.json exists. If a Next.js project already exists, add only the missing frontend dependencies. If no package.json exists yet, create one. Required dependencies per TechArch §6.2:

```json
{
  "name": "simple-wine-app",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "migrate": "ts-node db/migrate.ts"
  },
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "typescript": "^5.0.0",
    "@uswds/uswds": "^3.0.0",
    "zod": "^3.0.0",
    "@tanstack/react-query": "^5.0.0",
    "fuse.js": "^7.0.0",
    "pg": "^8.0.0"
  },
  "devDependencies": {
    "@types/pg": "^8.0.0",
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "@types/node": "^20.0.0",
    "eslint": "^8.0.0",
    "eslint-config-next": "^14.0.0",
    "ts-node": "^10.9.0"
  }
}
```

If package.json already exists, add only: `@uswds/uswds`, `@tanstack/react-query`, `fuse.js` to dependencies if not already present.

After writing package.json:
```bash
npm install
```

---

**Step 2: next.config.ts**

```typescript
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  reactStrictMode: true,
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          { key: 'X-Content-Type-Options', value: 'nosniff' },
          { key: 'X-Frame-Options', value: 'DENY' },
          { key: 'Referrer-Policy', value: 'no-referrer' },
          { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
        ],
      },
    ];
  },
};

export default nextConfig;
```

---

**Step 3: tsconfig.json** (only if not already present)

```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

---

**Step 4: .env.local.example**

```bash
# Copy to .env.local and fill in your values
DATABASE_URL=postgresql://wine:localdev@localhost:5432/simplewineapp
NODE_ENV=development
NEXT_PUBLIC_APP_VERSION=1.0.0
```

---

**Step 5: styles/techsur-tokens.css**

COPY VERBATIM from TechArch §6.4. Do not alter any hex value or token name:

```css
/* TechSur Brand Design Tokens — Applied over USWDS baseline */
/* Source: TechArch-SimpleWineApp.md §6.4 */
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

/* USWDS token overrides — Apply TechSur brand over USWDS defaults */
/* Source: TechArch-SimpleWineApp.md §6.4 */
:root {
  --theme-font-type-sans: 'Open Sans', system-ui, sans-serif;
  --theme-font-type-serif: 'Fraunces', Georgia, serif;
  --theme-font-type-mono: 'JetBrains Mono', 'Courier New', monospace;
  --theme-color-primary: #FBCA5C;
  --theme-color-primary-dark: #E6B040;
}

/* Base body typography */
body {
  background-color: var(--color-bone);
  color: var(--color-ink);
  font-family: var(--font-body);
}

/* Button base style overrides per TechSur brand */
.usa-button {
  border-radius: var(--radius-button);
  font-family: var(--font-display);
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.01em;
}

/* Primary CTA: Gold fill, Black text */
.usa-button--primary,
.usa-button:not([class*='--']) {
  background-color: var(--color-gold-400);
  color: var(--color-canvas-dark);
  border-color: var(--color-gold-400);
}
.usa-button--primary:hover,
.usa-button:not([class*='--']):hover {
  background-color: var(--color-gold-500);
  border-color: var(--color-gold-500);
}

/* Navigation: Black canvas background */
.usa-header {
  background-color: var(--color-canvas-dark);
}
.usa-nav__link,
.usa-nav__link:visited {
  color: var(--color-bone);
  font-family: var(--font-body);
}
.usa-nav__link:hover {
  color: var(--color-gold-400);
}

/* Readiness badge helpers */
.badge-drink-now {
  background-color: var(--color-drink-now);
  color: var(--color-canvas-dark);
  font-family: var(--font-mono);
  text-transform: uppercase;
  font-size: 0.75rem;
  letter-spacing: 0.05em;
  padding: 2px 8px;
  border-radius: 2px;
}
.badge-approaching-peak {
  background-color: var(--color-approaching-peak);
  color: var(--color-canvas-dark);
  font-family: var(--font-mono);
  text-transform: uppercase;
  font-size: 0.75rem;
  letter-spacing: 0.05em;
  padding: 2px 8px;
  border-radius: 2px;
}
.badge-hold {
  background-color: var(--color-hold);
  color: var(--color-ink);
  font-family: var(--font-mono);
  text-transform: uppercase;
  font-size: 0.75rem;
  letter-spacing: 0.05em;
  padding: 2px 8px;
  border-radius: 2px;
}
.badge-past-window {
  background-color: var(--color-past-window);
  color: var(--color-gray-400);
  font-family: var(--font-mono);
  text-transform: uppercase;
  font-size: 0.75rem;
  letter-spacing: 0.05em;
  padding: 2px 8px;
  border-radius: 2px;
}
.badge-no-window {
  background-color: transparent;
  color: var(--color-gray-400);
  font-family: var(--font-mono);
  text-transform: uppercase;
  font-size: 0.75rem;
  letter-spacing: 0.05em;
  padding: 2px 8px;
  border-radius: 2px;
  border: 1px solid var(--color-gray-400);
}
```

---

**Step 6: styles/fonts.css**

Per TechArch §6.3 and §7.3. All four font families, self-hosted from `/public/fonts/`. Use `font-display: swap`. Per TechArch §7.3, all fonts are OFL-licensed (Montserrat, Fraunces, Open Sans, JetBrains Mono).

```css
/* Self-hosted font declarations per TechArch §6.3 and ADR-005 */
/* All fonts served from /public/fonts/ — no CDN requests */

/* Montserrat — Display / Headings / Buttons */
@font-face {
  font-family: 'Montserrat';
  src: url('/fonts/montserrat-700.woff2') format('woff2');
  font-weight: 700;
  font-style: normal;
  font-display: swap;
}
@font-face {
  font-family: 'Montserrat';
  src: url('/fonts/montserrat-900.woff2') format('woff2');
  font-weight: 900;
  font-style: normal;
  font-display: swap;
}

/* Fraunces — Serif Accent / Italic emphasis */
@font-face {
  font-family: 'Fraunces';
  src: url('/fonts/fraunces-400-italic.woff2') format('woff2');
  font-weight: 400;
  font-style: italic;
  font-display: swap;
}
@font-face {
  font-family: 'Fraunces';
  src: url('/fonts/fraunces-600-italic.woff2') format('woff2');
  font-weight: 600;
  font-style: italic;
  font-display: swap;
}

/* Open Sans — Body / Form labels / UI text */
@font-face {
  font-family: 'Open Sans';
  src: url('/fonts/open-sans-400.woff2') format('woff2');
  font-weight: 400;
  font-style: normal;
  font-display: swap;
}
@font-face {
  font-family: 'Open Sans';
  src: url('/fonts/open-sans-600.woff2') format('woff2');
  font-weight: 600;
  font-style: normal;
  font-display: swap;
}
@font-face {
  font-family: 'Open Sans';
  src: url('/fonts/open-sans-700.woff2') format('woff2');
  font-weight: 700;
  font-style: normal;
  font-display: swap;
}

/* JetBrains Mono — Labels / Badges / Eyebrows (UPPERCASE) */
@font-face {
  font-family: 'JetBrains Mono';
  src: url('/fonts/jetbrains-mono-400.woff2') format('woff2');
  font-weight: 400;
  font-style: normal;
  font-display: swap;
}
@font-face {
  font-family: 'JetBrains Mono';
  src: url('/fonts/jetbrains-mono-500.woff2') format('woff2');
  font-weight: 500;
  font-style: normal;
  font-display: swap;
}
```

---

**Step 7: styles/globals.css**

```css
/* USWDS base styles — installed via npm, no CDN */
/* Per TechArch §7.2: @import from node_modules, bundled by Next.js webpack */
@import '@uswds/uswds/css/uswds.min.css';

/* TechSur fonts — loaded before tokens so font-face declarations resolve */
@import './fonts.css';

/* TechSur brand tokens — overrides USWDS defaults */
@import './techsur-tokens.css';

/* Reset / baseline */
*, *::before, *::after {
  box-sizing: border-box;
}

html {
  scroll-behavior: smooth;
}
```

---

**Step 8: Download WOFF2 font files**

Download WOFF2 files for each font family from their official open-source repositories. Place in `/public/fonts/`. The fonts are OFL-licensed.

```bash
# Create public/fonts directory
mkdir -p public/fonts

# Download Montserrat WOFF2 files from Google Fonts static CDN
# (Download only — no runtime CDN calls; these are bundled into /public/fonts)
curl -sL "https://fonts.gstatic.com/s/montserrat/v29/JTUHjIg1_i6t8kCHKm4532VJOt5-QNFgpCuM70w-Y3tcoqK5.woff2" -o public/fonts/montserrat-700.woff2
curl -sL "https://fonts.gstatic.com/s/montserrat/v29/JTUHjIg1_i6t8kCHKm4532VJOt5-QNFgpCtr70w-Y3tcoqK5.woff2" -o public/fonts/montserrat-900.woff2

# Open Sans WOFF2
curl -sL "https://fonts.gstatic.com/s/opensans/v40/memSYaGs126MiZpBA-UvWbX2vVnXBbObj2OVZyOOSr4dVJWUgsjZ0C40.woff2" -o public/fonts/open-sans-400.woff2
curl -sL "https://fonts.gstatic.com/s/opensans/v40/memSYaGs126MiZpBA-UvWbX2vVnXBbObj2OVZyOOSr4dVJWUgsjZ0B52.woff2" -o public/fonts/open-sans-600.woff2
curl -sL "https://fonts.gstatic.com/s/opensans/v40/memSYaGs126MiZpBA-UvWbX2vVnXBbObj2OVZyOOSr4dVJWUgsjZ0F52.woff2" -o public/fonts/open-sans-700.woff2

# JetBrains Mono WOFF2 (from GitHub releases)
curl -sL "https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/webfonts/JetBrainsMono-Regular.woff2" -o public/fonts/jetbrains-mono-400.woff2
curl -sL "https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/webfonts/JetBrainsMono-Medium.woff2" -o public/fonts/jetbrains-mono-500.woff2

# Fraunces WOFF2 (from GitHub releases — italic variants)
curl -sL "https://github.com/undercasetype/Fraunces/raw/main/fonts/ttf/Fraunces-Italic.ttf" -o /tmp/fraunces-400-italic.ttf
# If ttf downloaded, convert is optional — use a pre-built WOFF2 if available
# Fallback: use woff2_compress from Google or download from Google Fonts static CDN
curl -sL "https://fonts.gstatic.com/s/fraunces/v31/6NUu8FyLNQOQZAnv9ZwNjucMHVn85Ni7emAe9lKqZTnDpToK9cN21IA.woff2" -o public/fonts/fraunces-400-italic.woff2
curl -sL "https://fonts.gstatic.com/s/fraunces/v31/6NUu8FyLNQOQZAnv9ZwNjucMHVn85Ni7emAe9lKqZTnDpToK9cPb1IA.woff2" -o public/fonts/fraunces-600-italic.woff2
```

**If curl fails for any font URL** (URLs may shift over time), use these fallback steps:
1. Go to https://fonts.google.com and download Montserrat, Open Sans, Fraunces, JetBrains Mono as ZIP files
2. Extract the WOFF2 files matching the weights declared above
3. Rename and place in `/public/fonts/` using the filenames above

Verify all 9 WOFF2 files exist:
```bash
ls public/fonts/*.woff2 | sort
```

---

**Step 9: types/index.ts**

Export all shared TypeScript interfaces from TechArch §4.3. These are consumed by ALL wave 3 component plans. Copy types verbatim from TechArch — do not abbreviate or paraphrase.

```typescript
// types/index.ts
// Shared TypeScript interfaces for SimpleWineApp
// Source: TechArch-SimpleWineApp.md §4.3
// Consumed by all wave 3 React component plans

// ─── Enums and primitive types ─────────────────────────────────────────────────

export type WineType = 'RED' | 'WHITE' | 'ROSE' | 'SPARKLING' | 'DESSERT' | 'FORTIFIED';

export type BottleSize = '375ML' | '750ML' | '1500ML' | '3000ML';

export type ReadinessStatus =
  | 'DRINK_NOW'
  | 'APPROACHING_PEAK'
  | 'HOLD'
  | 'PAST_WINDOW'
  | 'NO_WINDOW_SET';

export type BottleEventType = 'CONSUMED' | 'GIFTED' | 'OPENED';

export type RatingScale = 'STARS_5' | 'POINTS_100';

export type WouldBuyAgain = 'YES' | 'NO' | 'MAYBE';

export type WineSortKey =
  | 'created_at_desc'
  | 'created_at_asc'
  | 'wine_name_asc'
  | 'wine_name_desc'
  | 'vintage_year_desc'
  | 'vintage_year_asc'
  | 'quantity_desc'
  | 'quantity_asc'
  | 'rating_desc'
  | 'rating_asc'
  | 'drink_window_end_asc'
  | 'drink_window_end_desc';

// ─── Wine Record ─────────────────────────────────────────────────────────────

export interface WineRecord {
  wine_id: string;                       // UUID
  wine_name: string;                     // max 200 chars
  producer: string;                      // max 200 chars
  vintage_year: number;                  // 1900–2200
  wine_type: WineType;
  grape_variety: string | null;          // max 200 chars
  country: string | null;                // max 100 chars
  region: string | null;                 // max 100 chars
  appellation: string | null;            // max 100 chars
  bottle_size: BottleSize;               // default '750ML'
  quantity: number;                      // >= 0
  is_open: boolean;
  storage_location_id: string | null;    // UUID FK
  storage_location_name: string | null;  // denormalized for display
  location_unknown: boolean;
  purchase_date: string | null;          // 'YYYY-MM-DD'
  purchase_source: string | null;        // max 200 chars
  purchase_price: number | null;         // >= 0, 2dp
  estimated_value: number | null;        // >= 0, 2dp
  drink_window_start: number | null;     // 1900–2200
  drink_window_end: number | null;       // 1900–2200
  readiness_status: ReadinessStatus;     // calculated at response time — never cached
  notes: string | null;                  // max 5000 chars
  latest_rating: number | null;          // denormalized cache
  latest_rating_scale: RatingScale | null;
  latest_rating_date: string | null;     // 'YYYY-MM-DD'
  created_at: string;                    // ISO 8601 UTC
  updated_at: string;                    // ISO 8601 UTC
}

export interface CreateWineRequest {
  wine_name: string;
  producer: string;
  vintage_year: number;
  wine_type: WineType;
  quantity: number;
  storage_location_id: string;
  grape_variety?: string;
  country?: string;
  region?: string;
  appellation?: string;
  bottle_size?: BottleSize;
  purchase_date?: string;
  purchase_source?: string;
  purchase_price?: number;
  estimated_value?: number;
  drink_window_start?: number;
  drink_window_end?: number;
  notes?: string;
}

export type UpdateWineRequest = CreateWineRequest;
export type PatchWineRequest = Partial<CreateWineRequest>;

export interface WineListResponse {
  data: WineRecord[];
  meta: {
    total: number;
    filtered: number;
  };
}

// ─── Storage Location ─────────────────────────────────────────────────────────

export interface StorageLocation {
  location_id: string;
  location_name: string;
  bottle_count?: number;
  created_at: string;
  updated_at: string;
}

export interface LocationRequest {
  location_name: string;
}

export interface LocationListResponse {
  data: StorageLocation[];
}

export interface DeleteLocationResponse {
  deleted_location_id: string;
  affected_wines_count: number;
}

// ─── Bottle Events ─────────────────────────────────────────────────────────────

export interface BottleEvent {
  event_id: string;
  wine_id: string;
  event_type: BottleEventType;
  event_date: string;
  notes: string | null;
  recipient: string | null;
  tasting_note_id: string | null;
  created_at: string;
}

export interface CreateBottleEventRequest {
  event_type: BottleEventType;
  event_date: string;
  notes?: string;
  recipient?: string;
}

export interface BottleEventListResponse {
  data: BottleEvent[];
}

export interface QuantityAdjustRequest {
  adjustment: 1 | -1;
}

export interface QuantityAdjustResponse {
  wine_id: string;
  quantity: number;
}

// ─── Tasting Notes ─────────────────────────────────────────────────────────────

export interface TastingNote {
  note_id: string;
  wine_id: string;
  bottle_event_id: string | null;
  date_tasted: string;
  appearance: string | null;
  aroma: string | null;
  flavor: string | null;
  finish: string | null;
  personal_rating: number | null;
  rating_scale: RatingScale | null;
  would_buy_again: WouldBuyAgain | null;
  occasion: string | null;
  guest_feedback: string | null;
  created_at: string;
  updated_at: string;
}

export interface CreateTastingNoteRequest {
  date_tasted: string;
  appearance?: string;
  aroma?: string;
  flavor?: string;
  finish?: string;
  personal_rating?: number;
  rating_scale?: RatingScale;
  would_buy_again?: WouldBuyAgain;
  occasion?: string;
  guest_feedback?: string;
  bottle_event_id?: string;
}

export type UpdateTastingNoteRequest = CreateTastingNoteRequest;

export interface TastingNoteListResponse {
  data: TastingNote[];
}

// ─── Dashboard ────────────────────────────────────────────────────────────────

export interface DashboardStats {
  total_bottles: number;
  total_wine_records: number;
  drink_now_count: number;
  approaching_peak_count: number;
}

export interface DrinkNowCard {
  wine_id: string;
  wine_name: string;
  producer: string;
  vintage_year: number;
  wine_type: WineType;
  quantity: number;
  storage_location_name: string | null;
  drink_window_end: number | null;
  readiness_status: 'DRINK_NOW';
}

export interface BreakdownByTypeRow {
  wine_type: WineType;
  bottle_count: number;
  percentage: number;
}

export interface BreakdownByRegionRow {
  label: string;
  bottle_count: number;
  percentage: number;
}

export interface BreakdownByDecadeRow {
  decade: string;
  bottle_count: number;
}

export interface RecentlyAddedItem {
  wine_id: string;
  wine_name: string;
  producer: string;
  vintage_year: number;
  wine_type: WineType;
  created_at: string;
}

export interface RecentlyConsumedItem {
  event_id: string;
  wine_id: string;
  wine_name: string;
  producer: string;
  vintage_year: number;
  event_date: string;
}

export interface HighestRatedItem {
  wine_id: string;
  wine_name: string;
  producer: string;
  vintage_year: number;
  latest_rating: number;
  latest_rating_scale: RatingScale;
  latest_rating_date: string;
}

export interface DashboardResponse {
  stats: DashboardStats;
  drink_now_shelf: DrinkNowCard[];
  breakdown_by_type: BreakdownByTypeRow[];
  breakdown_by_region: BreakdownByRegionRow[];
  breakdown_by_decade: BreakdownByDecadeRow[];
  recently_added: RecentlyAddedItem[];
  recently_consumed: RecentlyConsumedItem[];
  highest_rated: HighestRatedItem[];
}

// ─── Settings ──────────────────────────────────────────────────────────────────

export interface RatingScaleResponse {
  rating_scale: RatingScale;
}

export interface UpdateRatingScaleRequest {
  rating_scale: RatingScale;
}

// ─── Client-side filter state ──────────────────────────────────────────────────

export interface FilterState {
  wine_type?: WineType[];
  producer?: string;
  country?: string;
  region?: string;
  vintage_from?: number;
  vintage_to?: number;
  grape_variety?: string;
  storage_location_id?: string; // UUID or 'UNKNOWN'
  readiness?: ReadinessStatus[];
  rating_min?: number;
  rating_max?: number;
}

// ─── API Error ─────────────────────────────────────────────────────────────────

export interface ApiErrorDetail {
  field: string;
  message: string;
}

export interface ApiError {
  error: {
    code: string;
    message: string;
    field?: string;
    details?: ApiErrorDetail[];
  };
}
```
  </action>
  <verify>
grep -n 'color-gold-400.*FBCA5C' styles/techsur-tokens.css && grep -n 'color-canvas-dark.*0A0A0A' styles/techsur-tokens.css && grep -n 'radius-button.*2px' styles/techsur-tokens.css && grep -n 'theme-color-primary.*FBCA5C' styles/techsur-tokens.css && grep -n '@font-face' styles/fonts.css && grep -n 'Montserrat\|Fraunces\|Open Sans\|JetBrains Mono' styles/fonts.css && ls public/fonts/*.woff2 2>/dev/null | wc -l && grep -n 'export.*WineRecord\|export interface WineRecord' types/index.ts && grep -n 'export.*DashboardResponse\|export interface DashboardResponse' types/index.ts && grep -n 'export.*FilterState\|export interface FilterState' types/index.ts && echo CONTRACT_OK
  </verify>
  <done>
- styles/techsur-tokens.css: All 15 brand tokens present with exact hex values from TechArch §6.4 (--color-gold-400: #FBCA5C, --color-canvas-dark: #0A0A0A, --color-bone: #FAFAF7, --color-paper: #F5F5F2, --color-ink: #1A1A1A, --color-gray-400: #A8A59B, --color-gold-500, --color-gold-600, --color-drink-now, --color-approaching-peak, --color-hold, --color-past-window, --font-display, --font-accent, --font-body, --font-mono, --radius-button: 2px)
- styles/techsur-tokens.css: USWDS theme token overrides present (--theme-font-type-sans, --theme-font-type-serif, --theme-font-type-mono, --theme-color-primary, --theme-color-primary-dark)
- styles/fonts.css: @font-face declarations for all 4 families × correct weights (Montserrat 700/900, Fraunces 400i/600i, Open Sans 400/600/700, JetBrains Mono 400/500)
- styles/globals.css: imports USWDS CSS, fonts.css, techsur-tokens.css in correct order
- public/fonts/: 9 WOFF2 files present (montserrat-700, montserrat-900, fraunces-400-italic, fraunces-600-italic, open-sans-400, open-sans-600, open-sans-700, jetbrains-mono-400, jetbrains-mono-500)
- types/index.ts: All shared interfaces exported (WineRecord, TastingNote, StorageLocation, BottleEvent, DashboardResponse, FilterState, all enums and response types)
- npm install completes with @uswds/uswds, @tanstack/react-query, fuse.js in node_modules
  </done>
</task>

<task type="auto">
  <name>Task 2: Root layout (app/layout.tsx) and Navigation Shell components</name>
  <files>
    app/layout.tsx
    app/globals.css
    components/navigation/AppHeader.tsx
    components/navigation/AppNav.tsx
    components/navigation/MobileBottomNav.tsx
    components/navigation/FloatingAddButton.tsx
    components/navigation/index.ts
  </files>
  <action>
Create the root layout and all 4 Navigation Shell components per TechArch §2.1 and UX-Mockup Navigation Structure.

From UX-Mockup:
- **Mobile (< 768px):** Bottom tab bar: [Dashboard] [Cellar] [Settings] + Gold FAB "+" floating above center
- **Desktop (≥ 768px):** usa-header with horizontal links: "SimpleWineApp" logo + "Dashboard | My Cellar | Settings" + "+ Add Wine" button top-right

---

**components/navigation/FloatingAddButton.tsx**

Gold FAB (#FBCA5C, 56px circle) fixed to bottom-right. Always visible on all screen sizes on mobile; hidden on desktop (desktop has "+ Add Wine" in header). Per UX-Mockup: "Gold circle button, 56px, `usa-button`"

```tsx
'use client';

import Link from 'next/link';

export function FloatingAddButton() {
  return (
    <Link
      href="/wines/new"
      aria-label="Add a new wine"
      style={{
        position: 'fixed',
        bottom: '80px', // above bottom nav bar on mobile
        right: '16px',
        width: '56px',
        height: '56px',
        borderRadius: '50%',
        backgroundColor: 'var(--color-gold-400)',
        color: 'var(--color-canvas-dark)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        fontSize: '28px',
        fontWeight: '700',
        textDecoration: 'none',
        boxShadow: '0 4px 12px rgba(0,0,0,0.3)',
        zIndex: 100,
      }}
      className="fab-add-wine"
    >
      +
    </Link>
  );
}
```

---

**components/navigation/MobileBottomNav.tsx**

Bottom tab bar for mobile (< 768px). Shown only on small screens via CSS `display: none` at ≥ 768px. Uses USWDS `usa-nav` patterns. Active tab detected via `usePathname`.

```tsx
'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

const tabs = [
  { href: '/', label: 'Dashboard', icon: '⊟' },
  { href: '/wines', label: 'Cellar', icon: '🍷' },
  { href: '/settings', label: 'Settings', icon: '⚙' },
];

export function MobileBottomNav() {
  const pathname = usePathname();

  return (
    <nav
      aria-label="Mobile navigation"
      style={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        height: '64px',
        backgroundColor: 'var(--color-canvas-dark)',
        display: 'flex',
        alignItems: 'stretch',
        zIndex: 90,
        borderTop: '1px solid rgba(255,255,255,0.1)',
      }}
      className="mobile-bottom-nav"
    >
      {tabs.map((tab) => {
        const isActive = tab.href === '/'
          ? pathname === '/'
          : pathname.startsWith(tab.href);
        return (
          <Link
            key={tab.href}
            href={tab.href}
            aria-label={tab.label}
            aria-current={isActive ? 'page' : undefined}
            style={{
              flex: 1,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              color: isActive ? 'var(--color-gold-400)' : 'var(--color-gray-400)',
              textDecoration: 'none',
              fontSize: '0.625rem',
              fontFamily: 'var(--font-mono)',
              textTransform: 'uppercase',
              letterSpacing: '0.05em',
              gap: '2px',
              minHeight: '44px',
              minWidth: '44px',
            }}
          >
            <span style={{ fontSize: '1.25rem' }}>{tab.icon}</span>
            <span>{tab.label}</span>
          </Link>
        );
      })}
    </nav>
  );
}
```

---

**components/navigation/AppNav.tsx**

Desktop horizontal navigation links. Used inside AppHeader. USWDS `usa-nav` pattern. Per UX-Mockup: "Dashboard | My Cellar | Settings" + "+ Add Wine" button.

```tsx
'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

const navLinks = [
  { href: '/', label: 'Dashboard' },
  { href: '/wines', label: 'My Cellar' },
  { href: '/settings', label: 'Settings' },
];

export function AppNav() {
  const pathname = usePathname();

  return (
    <nav aria-label="Primary navigation" className="usa-nav">
      <ul className="usa-nav__primary usa-accordion" style={{ listStyle: 'none', display: 'flex', gap: '0', margin: 0, padding: 0, alignItems: 'center' }}>
        {navLinks.map((link) => {
          const isActive = link.href === '/'
            ? pathname === '/'
            : pathname.startsWith(link.href);
          return (
            <li key={link.href} className="usa-nav__primary-item">
              <Link
                href={link.href}
                className="usa-nav__link"
                aria-current={isActive ? 'page' : undefined}
                style={{
                  color: isActive ? 'var(--color-gold-400)' : 'var(--color-bone)',
                  fontFamily: 'var(--font-body)',
                  textDecoration: 'none',
                  padding: '8px 16px',
                  display: 'block',
                  fontWeight: isActive ? 700 : 400,
                  borderBottom: isActive ? '2px solid var(--color-gold-400)' : '2px solid transparent',
                }}
              >
                {link.label}
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
```

---

**components/navigation/AppHeader.tsx**

Desktop site header. Uses USWDS `usa-header`. Black (#0A0A0A) background. Shows only at ≥ 768px via CSS.

```tsx
import Link from 'next/link';
import { AppNav } from './AppNav';

export function AppHeader() {
  return (
    <header
      className="usa-header"
      role="banner"
      style={{
        backgroundColor: 'var(--color-canvas-dark)',
        borderBottom: '1px solid rgba(255,255,255,0.1)',
        position: 'sticky',
        top: 0,
        zIndex: 80,
      }}
    >
      <div
        className="usa-nav-container"
        style={{
          maxWidth: '1280px',
          margin: '0 auto',
          padding: '0 16px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          height: '64px',
        }}
      >
        {/* Logo / App name */}
        <Link
          href="/"
          className="usa-logo"
          aria-label="SimpleWineApp home"
          style={{
            fontFamily: 'var(--font-display)',
            fontWeight: 900,
            fontSize: '1.25rem',
            color: 'var(--color-bone)',
            textDecoration: 'none',
            letterSpacing: '-0.02em',
          }}
        >
          SimpleWineApp
        </Link>

        {/* Primary nav */}
        <AppNav />

        {/* Primary CTA: + Add Wine */}
        <Link
          href="/wines/new"
          className="usa-button"
          style={{
            backgroundColor: 'var(--color-gold-400)',
            color: 'var(--color-canvas-dark)',
            borderRadius: 'var(--radius-button)',
            fontFamily: 'var(--font-display)',
            fontWeight: 700,
            textTransform: 'uppercase',
            letterSpacing: '0.01em',
            fontSize: '0.875rem',
            padding: '8px 16px',
            textDecoration: 'none',
            whiteSpace: 'nowrap',
            border: 'none',
          }}
        >
          + Add Wine
        </Link>
      </div>
    </header>
  );
}
```

---

**components/navigation/index.ts**

Barrel export for the navigation components:

```typescript
export { AppHeader } from './AppHeader';
export { AppNav } from './AppNav';
export { MobileBottomNav } from './MobileBottomNav';
export { FloatingAddButton } from './FloatingAddButton';
```

---

**app/globals.css** (minimal override if Next.js scaffolded its own globals.css)

```css
/* Import global styles — Next.js App Router entry point */
@import '../styles/globals.css';
```

If `app/globals.css` does not exist, create it with the content above. If it already exists with unrelated content from a previous scaffold, replace it.

---

**app/layout.tsx**

Root layout per TechArch §6.5. Imports all CSS (fonts, tokens, USWDS). Wraps all pages in `QueryClientProvider` for React Query. Mounts `AppHeader` (desktop) and `MobileBottomNav` (mobile) using CSS media queries for show/hide.

```tsx
import type { Metadata } from 'next';
import './globals.css';
import { AppHeader } from '@/components/navigation/AppHeader';
import { MobileBottomNav } from '@/components/navigation/MobileBottomNav';
import { FloatingAddButton } from '@/components/navigation/FloatingAddButton';
import ReactQueryProvider from '@/components/providers/ReactQueryProvider';

export const metadata: Metadata = {
  title: 'SimpleWineApp — My Cellar',
  description: 'Personal wine collection manager',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <head>
        {/* Preload critical fonts per TechArch §7.3 */}
        <link rel="preload" href="/fonts/montserrat-700.woff2" as="font" type="font/woff2" crossOrigin="anonymous" />
        <link rel="preload" href="/fonts/montserrat-900.woff2" as="font" type="font/woff2" crossOrigin="anonymous" />
        <link rel="preload" href="/fonts/open-sans-400.woff2" as="font" type="font/woff2" crossOrigin="anonymous" />
      </head>
      <body>
        {/* Desktop header — hidden on mobile via CSS */}
        <div className="desktop-nav-wrapper">
          <AppHeader />
        </div>

        {/* Main content */}
        <ReactQueryProvider>
          <main
            id="main-content"
            style={{
              minHeight: '100vh',
              paddingBottom: '80px', /* room for mobile bottom nav */
            }}
          >
            {children}
          </main>
        </ReactQueryProvider>

        {/* Mobile bottom navigation — hidden on desktop via CSS */}
        <div className="mobile-nav-wrapper">
          <MobileBottomNav />
          <FloatingAddButton />
        </div>
      </body>
    </html>
  );
}
```

Also create **components/providers/ReactQueryProvider.tsx** (required client component for React Query):

```tsx
'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useState } from 'react';

export default function ReactQueryProvider({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 60 * 1000, // 1 minute
            retry: 1,
          },
        },
      })
  );

  return (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
}
```

**Responsive show/hide CSS** — Add to `styles/techsur-tokens.css` (or `styles/globals.css`):

```css
/* Navigation responsive visibility */
.desktop-nav-wrapper {
  display: none;
}
.mobile-nav-wrapper {
  display: block;
}

@media (min-width: 768px) {
  .desktop-nav-wrapper {
    display: block;
  }
  .mobile-nav-wrapper {
    display: none;
  }
  /* Remove bottom padding on desktop — no bottom nav */
  main {
    padding-bottom: 0 !important;
  }
}
```

Append these media queries to `styles/techsur-tokens.css` at the end.
  </action>
  <verify>
grep -n 'export default.*RootLayout\|export default function RootLayout' app/layout.tsx && grep -n 'fonts/montserrat-700' app/layout.tsx && grep -n 'AppHeader\|MobileBottomNav\|FloatingAddButton' app/layout.tsx && grep -n 'export.*AppHeader\|export function AppHeader' components/navigation/AppHeader.tsx && grep -n 'export.*MobileBottomNav\|export function MobileBottomNav' components/navigation/MobileBottomNav.tsx && grep -n 'export.*FloatingAddButton\|export function FloatingAddButton' components/navigation/FloatingAddButton.tsx && grep -n 'export.*AppHeader\|export.*MobileBottomNav\|export.*FloatingAddButton' components/navigation/index.ts && grep -n 'QueryClientProvider\|ReactQueryProvider' app/layout.tsx && echo CONTRACT_OK
  </verify>
  <done>
- app/layout.tsx: exports default RootLayout; imports globals.css; preloads montserrat-700/900 and open-sans-400 fonts; mounts AppHeader (desktop), MobileBottomNav (mobile), FloatingAddButton; wraps children in ReactQueryProvider
- components/navigation/AppHeader.tsx: exports AppHeader; renders usa-header with Black canvas background, SimpleWineApp logo, AppNav horizontal links, "+ Add Wine" Gold CTA button
- components/navigation/AppNav.tsx: exports AppNav; renders 3 nav links (Dashboard, My Cellar, Settings) with active state highlighting via Gold underline
- components/navigation/MobileBottomNav.tsx: exports MobileBottomNav; renders 3 tab links with JetBrains Mono UPPERCASE labels; active tab in Gold; hidden at ≥768px
- components/navigation/FloatingAddButton.tsx: exports FloatingAddButton; Gold 56px circle fixed bottom-right; links to /wines/new
- components/navigation/index.ts: barrel exports all 4 navigation components
- components/providers/ReactQueryProvider.tsx: client component wrapping QueryClientProvider with 1-min staleTime
- styles/techsur-tokens.css: desktop-nav-wrapper/mobile-nav-wrapper responsive CSS added
- `npm run dev` starts without TypeScript errors (verify with: npx tsc --noEmit 2>&1 | head -20)
  </done>
</task>

</tasks>

<verification>
After both tasks complete, run these checks:

```bash
# 1. All TechSur brand tokens exact values
grep -n 'color-gold-400.*FBCA5C' styles/techsur-tokens.css
grep -n 'color-canvas-dark.*0A0A0A' styles/techsur-tokens.css
grep -n 'color-bone.*FAFAF7' styles/techsur-tokens.css
grep -n 'color-paper.*F5F5F2' styles/techsur-tokens.css
grep -n 'color-ink.*1A1A1A' styles/techsur-tokens.css
grep -n 'radius-button.*2px' styles/techsur-tokens.css

# 2. USWDS theme token overrides
grep -n 'theme-color-primary.*FBCA5C' styles/techsur-tokens.css
grep -n 'theme-font-type-sans' styles/techsur-tokens.css

# 3. Font file presence
ls public/fonts/*.woff2 | sort

# 4. @font-face declarations
grep -c '@font-face' styles/fonts.css

# 5. Shared TypeScript interfaces
grep -n 'export.*WineRecord\|export interface WineRecord' types/index.ts
grep -n 'export.*DashboardResponse' types/index.ts
grep -n 'export.*FilterState' types/index.ts
grep -n 'export.*ReadinessStatus' types/index.ts

# 6. Navigation components exported
grep -n 'AppHeader\|MobileBottomNav\|FloatingAddButton' components/navigation/index.ts

# 7. Root layout correctness
grep -n 'fonts/montserrat-700' app/layout.tsx
grep -n 'ReactQueryProvider' app/layout.tsx

# 8. TypeScript compilation
npx tsc --noEmit 2>&1 | head -30

# 9. Next.js dev server starts
# (Optional — requires DATABASE_URL in .env.local)
# npm run dev &amp; sleep 8 &amp;&amp; curl -s http://localhost:3000 | head -5
```
</verification>

<success_criteria>
- styles/techsur-tokens.css: all 15+ CSS custom properties present with EXACT values from TechArch §6.4 (no approximations; #FBCA5C not #fbca5c, not #FBC or similar)
- styles/techsur-tokens.css: USWDS override tokens (--theme-color-primary, --theme-font-type-sans, etc.) present
- styles/fonts.css: 9 @font-face rules covering Montserrat (700, 900), Fraunces (400i, 600i), Open Sans (400, 600, 700), JetBrains Mono (400, 500); all src pointing to /fonts/*.woff2; all font-display: swap
- public/fonts/: 9 WOFF2 files exist and are non-zero in size
- styles/globals.css: imports USWDS CSS, fonts.css, techsur-tokens.css in correct order
- types/index.ts: exports WineRecord, TastingNote, StorageLocation, BottleEvent, DashboardResponse, FilterState, and all enum types
- app/layout.tsx: imports globals.css; preloads critical fonts; mounts AppHeader + MobileBottomNav + FloatingAddButton; wraps in ReactQueryProvider
- Navigation shell: AppHeader renders on desktop (≥768px), MobileBottomNav renders on mobile (<768px) — controlled by CSS
- AppHeader: usa-header, Black #0A0A0A background, logo, 3 nav links, "+ Add Wine" Gold button
- MobileBottomNav: 3 tabs (Dashboard/Cellar/Settings), JetBrains Mono UPPERCASE labels, active tab Gold
- FloatingAddButton: Gold #FBCA5C, 56px circle, fixed position, links to /wines/new
- `npx tsc --noEmit` produces 0 errors on the new files
</success_criteria>

<output>
After completion, create `.planning/express/building-a-web-app-to-keep-track-of-my-w/05-SUMMARY.md` summarizing:
- USWDS package version installed
- All 15 TechSur brand tokens confirmed with exact hex values
- Font families and weights self-hosted as WOFF2
- Navigation shell components created (list each)
- types/index.ts exports list (used by wave 3 plans 06, 07, 08)
- Any deviations from TechArch specs (expected: none)
</output>
