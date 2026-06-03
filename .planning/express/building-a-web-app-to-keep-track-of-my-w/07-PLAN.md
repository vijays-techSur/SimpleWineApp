---
phase: 03-frontend-detail-forms
plan: 07
type: execute
wave: 7
depends_on: [2, 3, 4]
files_modified:
  - app/wines/[wine_id]/page.tsx
  - components/wine-detail/WineDetailHero.tsx
  - components/wine-detail/WineDetailSections.tsx
  - components/wine-detail/BottleEventSheet.tsx
  - components/wine-detail/ConsumeEventDialog.tsx
  - components/wine-detail/GiftEventDialog.tsx
  - components/wine-detail/OpenEventDialog.tsx
  - components/wine-detail/BottleHistorySection.tsx
  - components/wine-detail/TastingNoteCard.tsx
  - components/wine-detail/TastingNoteHistory.tsx
  - components/wine-detail/DeleteWineModal.tsx
  - app/wines/new/page.tsx
  - app/wines/[wine_id]/edit/page.tsx
  - components/wine-form/WineForm.tsx
  - components/wine-form/CreateLocationModal.tsx
  - app/locations/page.tsx
  - components/locations/LocationRow.tsx
  - components/locations/DeleteLocationModal.tsx
  - app/wines/[wine_id]/tasting-notes/new/page.tsx
  - app/wines/[wine_id]/tasting-notes/[note_id]/edit/page.tsx
  - components/tasting-note/TastingNoteForm.tsx
  - components/tasting-note/RatingWidget.tsx
  - components/tasting-note/WouldBuyAgainToggle.tsx
  - lib/hooks/useWineDetail.ts
  - lib/hooks/useLocations.ts
  - lib/hooks/useTastingNotes.ts
autonomous: true

features:
  implements: ["F0", "F1", "F2", "F4"]
  depends_on: ["F0", "F1", "F2", "F4"]
  enables: ["F6"]

must_haves:
  truths:
    - "Wine Detail page shows hero band with wine name (Fraunces italic), type/readiness/open badges, quantity +/- controls, storage location"
    - "Wine Detail action row has Edit, Open/Consume Bottle, Add Tasting Note, and Delete buttons"
    - "Open/Consume Bottle opens action sheet with Consumed/Gifted/Opened options; each option opens its dialog"
    - "Consumed dialog decrements quantity, optionally navigates to Tasting Note form if toggle ON (CP-03)"
    - "Wine Detail shows all field sections: Identity, Provenance & Purchase, Storage, Drinking Window, Notes"
    - "Tasting Notes section on Wine Detail shows note cards (rating, date, would-buy-again, occasion, flavor preview, expand toggle, Edit/Delete)"
    - "Bottle History section shows reverse-chronological events with type icon, date, notes; Consumed events link to tasting note"
    - "Add Wine form shows all 18+ fields in 5 grouped sections (Required, Optional, Purchase, Drinking Window, Notes)"
    - "Storage Location dropdown on Add/Edit form triggers inline CreateLocationModal; new location auto-selected"
    - "Edit Wine form pre-fills all current values; save returns to Wine Detail with toast"
    - "Storage Locations page lists all locations with bottle counts; Location Unknown synthetic entry at top if any"
    - "Storage Locations page delete confirmation modal shows affected wine count; calls DELETE /api/v1/locations/:id"
    - "Tasting Note form has star picker (5-star) or 100-pt numeric input per user preference; Would Buy Again toggle (Yes/Maybe/No)"
    - "Tasting Note form date defaults to today; validates not-future; saves and returns to Wine Detail"
  artifacts:
    - path: "app/wines/[wine_id]/page.tsx"
      provides: "Wine Detail route page — fetches wine, tasting notes, events"
      exports: ["default"]
    - path: "components/wine-detail/WineDetailHero.tsx"
      provides: "Black hero band with wine name, badges, qty controls, location, action row"
      exports: ["WineDetailHero"]
    - path: "components/wine-form/WineForm.tsx"
      provides: "Add/Edit wine form with all 18+ fields, grouped sections, inline location modal"
      exports: ["WineForm"]
    - path: "components/wine-form/CreateLocationModal.tsx"
      provides: "Inline modal for creating a new storage location from within WineForm"
      exports: ["CreateLocationModal"]
    - path: "app/locations/page.tsx"
      provides: "Storage Locations management page"
      exports: ["default"]
    - path: "components/tasting-note/TastingNoteForm.tsx"
      provides: "Tasting Note form with RatingWidget, WouldBuyAgainToggle, all sensory fields"
      exports: ["TastingNoteForm"]
    - path: "components/tasting-note/RatingWidget.tsx"
      provides: "Star picker (5-star) or numeric input (100-pt) per user rating_scale setting"
      exports: ["RatingWidget"]
    - path: "components/tasting-note/WouldBuyAgainToggle.tsx"
      provides: "usa-button-group toggle: Yes / Maybe / No"
      exports: ["WouldBuyAgainToggle"]
  key_links:
    - from: "app/wines/[wine_id]/page.tsx"
      to: "/api/v1/wines/:wine_id"
      via: "fetch in server component or useWineDetail hook"
      pattern: "api/v1/wines"
    - from: "components/wine-detail/WineDetailHero.tsx"
      to: "/api/v1/wines/:wine_id/quantity"
      via: "PATCH on +/- button click"
      pattern: "quantity"
    - from: "components/wine-detail/BottleEventSheet.tsx"
      to: "/api/v1/wines/:wine_id/events"
      via: "POST on confirm"
      pattern: "events"
    - from: "components/wine-form/WineForm.tsx"
      to: "/api/v1/wines (POST) or /api/v1/wines/:id (PUT)"
      via: "submit handler"
      pattern: "api/v1/wines"
    - from: "components/wine-form/CreateLocationModal.tsx"
      to: "/api/v1/locations"
      via: "POST on Add Location submit"
      pattern: "api/v1/locations"
    - from: "app/locations/page.tsx"
      to: "/api/v1/locations and /api/v1/locations/:id"
      via: "useLocations hook"
      pattern: "api/v1/locations"
    - from: "components/tasting-note/TastingNoteForm.tsx"
      to: "/api/v1/wines/:wine_id/tasting-notes"
      via: "POST or PUT on save"
      pattern: "tasting-notes"

integration_contracts:
  requires:
    - from_plan: "2"
      artifact: "app/api/v1/wines/[wine_id]/route.ts"
      exports: ["GET", "PUT", "DELETE"]
      verify: "grep -n 'export async function GET\\|export async function PUT\\|export async function DELETE' app/api/v1/wines/\\[wine_id\\]/route.ts && echo CONTRACT_OK"
    - from_plan: "2"
      artifact: "app/api/v1/wines/route.ts"
      exports: ["POST"]
      verify: "grep -n 'export async function POST' app/api/v1/wines/route.ts && echo CONTRACT_OK"
    - from_plan: "2"
      artifact: "lib/business/readiness.ts"
      exports: ["calculateReadinessStatus", "ReadinessStatus"]
      verify: "grep -n 'export function calculateReadinessStatus\\|export.*ReadinessStatus' lib/business/readiness.ts && echo CONTRACT_OK"
    - from_plan: "3"
      artifact: "app/api/v1/wines/[wine_id]/events/route.ts"
      exports: ["POST", "GET"]
      verify: "grep -n 'export async function POST\\|export async function GET' app/api/v1/wines/\\[wine_id\\]/events/route.ts && echo CONTRACT_OK"
    - from_plan: "3"
      artifact: "app/api/v1/wines/[wine_id]/quantity/route.ts"
      exports: ["PATCH"]
      verify: "grep -n 'export async function PATCH' app/api/v1/wines/\\[wine_id\\]/quantity/route.ts && echo CONTRACT_OK"
    - from_plan: "3"
      artifact: "app/api/v1/locations/route.ts"
      exports: ["GET", "POST"]
      verify: "grep -n 'export async function GET\\|export async function POST' app/api/v1/locations/route.ts && echo CONTRACT_OK"
    - from_plan: "3"
      artifact: "app/api/v1/locations/[location_id]/route.ts"
      exports: ["PUT", "DELETE"]
      verify: "grep -n 'export async function PUT\\|export async function DELETE' app/api/v1/locations/\\[location_id\\]/route.ts && echo CONTRACT_OK"
    - from_plan: "4"
      artifact: "app/api/v1/wines/[wine_id]/tasting-notes/route.ts"
      exports: ["GET", "POST"]
      verify: "grep -n 'export async function GET\\|export async function POST' app/api/v1/wines/\\[wine_id\\]/tasting-notes/route.ts && echo CONTRACT_OK"
    - from_plan: "4"
      artifact: "app/api/v1/settings/rating-scale/route.ts"
      exports: ["GET", "PUT"]
      verify: "grep -n 'export async function GET\\|export async function PUT' app/api/v1/settings/rating-scale/route.ts && echo CONTRACT_OK"
  provides:
    - artifact: "app/wines/[wine_id]/page.tsx"
      exports: ["default"]
      shape: |
        Wine Detail page — renders WineDetailHero, all field sections, TastingNoteHistory, BottleHistorySection
        Route: /wines/:wine_id
      verify: "test -f app/wines/\\[wine_id\\]/page.tsx && grep -n 'export default\\|WineDetailHero\\|TastingNoteHistory' app/wines/\\[wine_id\\]/page.tsx && echo CONTRACT_OK"
    - artifact: "app/wines/new/page.tsx"
      exports: ["default"]
      shape: |
        Add Wine form page — renders WineForm in add mode
        Route: /wines/new
      verify: "test -f app/wines/new/page.tsx && grep -n 'WineForm' app/wines/new/page.tsx && echo CONTRACT_OK"
    - artifact: "app/wines/[wine_id]/edit/page.tsx"
      exports: ["default"]
      shape: |
        Edit Wine form page — renders WineForm in edit mode, pre-filled
        Route: /wines/:wine_id/edit
      verify: "test -f app/wines/\\[wine_id\\]/edit/page.tsx && grep -n 'WineForm' app/wines/\\[wine_id\\]/edit/page.tsx && echo CONTRACT_OK"
    - artifact: "app/locations/page.tsx"
      exports: ["default"]
      shape: |
        Storage Locations management page — lists all locations with bottle counts, add/edit/delete
        Route: /locations
      verify: "test -f app/locations/page.tsx && grep -n 'LocationRow\\|AddLocation\\|DeleteLocationModal' app/locations/page.tsx && echo CONTRACT_OK"
    - artifact: "app/wines/[wine_id]/tasting-notes/new/page.tsx"
      exports: ["default"]
      shape: |
        Add Tasting Note page — renders TastingNoteForm in create mode
        Route: /wines/:wine_id/tasting-notes/new
      verify: "test -f app/wines/\\[wine_id\\]/tasting-notes/new/page.tsx && grep -n 'TastingNoteForm' app/wines/\\[wine_id\\]/tasting-notes/new/page.tsx && echo CONTRACT_OK"
    - artifact: "components/wine-detail/WineDetailHero.tsx"
      exports: ["WineDetailHero"]
      shape: |
        export interface WineDetailHeroProps { wine: WineRecord; onQuantityChange: () => void; onEditClick: () => void; onConsumeClick: () => void; onAddNoteClick: () => void; onDeleteClick: () => void; }
        export function WineDetailHero(props: WineDetailHeroProps): JSX.Element
      verify: "grep -n 'export.*WineDetailHero\\|export function WineDetailHero\\|export const WineDetailHero' components/wine-detail/WineDetailHero.tsx && echo CONTRACT_OK"
    - artifact: "components/wine-form/WineForm.tsx"
      exports: ["WineForm"]
      shape: |
        export interface WineFormProps { mode: 'add' | 'edit'; initialValues?: Partial<WineRecord>; onSuccess: (wine: WineRecord) => void; }
        export function WineForm(props: WineFormProps): JSX.Element
      verify: "grep -n 'export.*WineForm\\|export function WineForm\\|export const WineForm' components/wine-form/WineForm.tsx && echo CONTRACT_OK"
    - artifact: "components/tasting-note/TastingNoteForm.tsx"
      exports: ["TastingNoteForm"]
      shape: |
        export interface TastingNoteFormProps { wineId: string; bottleEventId?: string; initialValues?: Partial<TastingNoteInput>; onSuccess: () => void; }
        export function TastingNoteForm(props: TastingNoteFormProps): JSX.Element
      verify: "grep -n 'export.*TastingNoteForm\\|export function TastingNoteForm\\|export const TastingNoteForm' components/tasting-note/TastingNoteForm.tsx && echo CONTRACT_OK"
---

<objective>
Build the Wine Detail page (with hero band, quantity controls, action row, field sections, tasting note cards, bottle event log), Add Wine and Edit Wine forms (all 18+ fields, inline location creation modal per CP-01/CP-03), Storage Locations management page (list with counts, delete confirmation modal), and the Tasting Note form (star picker + 100-point scale, Would Buy Again toggle per UX-Mockup F04).

Purpose: This plan delivers the core write-path UI — creating, editing, and consuming wines — that transforms the app from read-only to a fully interactive cellar management tool. All F0/F1/F2/F4 user-facing interactions land here.
Output: 26 TypeScript/React files across 4 functional UI domains: Wine Detail, Wine Forms, Storage Locations, and Tasting Notes.
</objective>

<feature_dependencies>
Implements: F0: Wine Inventory CRUD (Wine Detail view, Add/Edit Wine Form, Delete confirmation modal), F1: Quantity & Bottle Status Tracking (quantity +/- controls, Open/Consume/Gift/Opened action sheet and dialogs, bottle event log on detail), F2: Storage Location Management (Storage Locations page, inline CreateLocationModal in WineForm, delete confirmation with affected wine count), F4: Tasting Notes & Personal Ratings (Tasting Note Form with RatingWidget star/100-pt, WouldBuyAgainToggle, TastingNoteCard on Wine Detail, linked note post-consume flow CP-03)
Depends on: Wave 2 plans (02–04): /api/v1/wines CRUD, /api/v1/wines/:id/events, /api/v1/wines/:id/quantity, /api/v1/locations CRUD, /api/v1/wines/:id/tasting-notes CRUD, /api/v1/settings/rating-scale, calculateReadinessStatus, ReadinessBadge component from wave 3 plan 05 (or 06), design tokens and Navigation Shell from wave 3 plan 05
Enables: F6: Dashboard (wave 8) can link to Wine Detail; wave 9 integration tests can exercise all write flows end-to-end
</feature_dependencies>

<execution_context>
@/app/workspaces/.pivota-home/opencode-xdg/opencode/pivota_spec-framework/workflows/execute-plan.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/express/building-a-web-app-to-keep-track-of-my-w/WAVE-SCHEDULE.md
@project_specs/UX-Mockup-SimpleWineApp.md
@project_specs/TechArch-SimpleWineApp.md
@.planning/express/building-a-web-app-to-keep-track-of-my-w/05-PLAN.md
@.planning/express/building-a-web-app-to-keep-track-of-my-w/06-PLAN.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Wine Detail page — hero band, quantity controls, action sheet/dialogs, field sections, tasting note cards, bottle history</name>
  <files>
    app/wines/[wine_id]/page.tsx
    components/wine-detail/WineDetailHero.tsx
    components/wine-detail/WineDetailSections.tsx
    components/wine-detail/BottleEventSheet.tsx
    components/wine-detail/ConsumeEventDialog.tsx
    components/wine-detail/GiftEventDialog.tsx
    components/wine-detail/OpenEventDialog.tsx
    components/wine-detail/BottleHistorySection.tsx
    components/wine-detail/TastingNoteCard.tsx
    components/wine-detail/TastingNoteHistory.tsx
    components/wine-detail/DeleteWineModal.tsx
    lib/hooks/useWineDetail.ts
  </files>
  <action>
Build the complete Wine Detail screen per UX-Mockup §Screen 02.

---

**lib/hooks/useWineDetail.ts** — Data fetching hook for wine detail page:

```typescript
'use client';
import { useState, useEffect } from 'react';

export function useWineDetail(wineId: string) {
  const [wine, setWine] = useState<WineRecord | null>(null);
  const [notes, setNotes] = useState<TastingNote[]>([]);
  const [events, setEvents] = useState<BottleEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const refresh = async () => {
    setLoading(true);
    setError(null);
    try {
      const [wineRes, notesRes, eventsRes] = await Promise.all([
        fetch(`/api/v1/wines/${wineId}`),
        fetch(`/api/v1/wines/${wineId}/tasting-notes`),
        fetch(`/api/v1/wines/${wineId}/events`),
      ]);
      if (!wineRes.ok) { setError('Unable to load wine details. Pull to refresh or try again.'); return; }
      const [wineData, notesData, eventsData] = await Promise.all([
        wineRes.json(), notesRes.json(), eventsRes.json(),
      ]);
      setWine(wineData);
      setNotes(notesData.data ?? []);
      setEvents(eventsData.data ?? []);
    } catch {
      setError('Unable to load wine details. Pull to refresh or try again.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { refresh(); }, [wineId]);
  return { wine, notes, events, loading, error, refresh };
}
```

---

**app/wines/[wine_id]/page.tsx** — Next.js App Router page. Use `'use client'` since it requires interactivity:

```typescript
'use client';
import { useParams, useRouter } from 'next/navigation';
import { useWineDetail } from '@/lib/hooks/useWineDetail';
import { WineDetailHero } from '@/components/wine-detail/WineDetailHero';
import { WineDetailSections } from '@/components/wine-detail/WineDetailSections';
import { TastingNoteHistory } from '@/components/wine-detail/TastingNoteHistory';
import { BottleHistorySection } from '@/components/wine-detail/BottleHistorySection';

export default function WineDetailPage() {
  const { wine_id } = useParams<{ wine_id: string }>();
  const router = useRouter();
  const { wine, notes, events, loading, error, refresh } = useWineDetail(wine_id);

  if (loading) return <div className="usa-section"><p>Loading...</p></div>;
  if (error || !wine) return (
    <div className="usa-section">
      <div className="usa-alert usa-alert--error">
        <div className="usa-alert__body">
          <p className="usa-alert__text">{error || 'Wine not found.'}</p>
        </div>
      </div>
    </div>
  );

  return (
    <main>
      {/* Breadcrumb */}
      <nav className="usa-breadcrumb" aria-label="Breadcrumbs">
        <ol className="usa-breadcrumb__list">
          <li className="usa-breadcrumb__list-item">
            <a href="/wines" className="usa-breadcrumb__link">My Cellar</a>
          </li>
          <li className="usa-breadcrumb__list-item usa-current" aria-current="page">
            {wine.wine_name}
          </li>
        </ol>
      </nav>

      {/* Hero + Actions */}
      <WineDetailHero
        wine={wine}
        onQuantityChange={refresh}
        onEditClick={() => router.push(`/wines/${wine_id}/edit`)}
        onAddNoteClick={() => router.push(`/wines/${wine_id}/tasting-notes/new`)}
        onDeleteSuccess={() => router.push('/wines')}
        onConsumeSuccess={(bottleEventId?: string) => {
          if (bottleEventId) {
            router.push(`/wines/${wine_id}/tasting-notes/new?bottle_event_id=${bottleEventId}`);
          } else {
            refresh();
          }
        }}
      />

      {/* Field sections */}
      <WineDetailSections wine={wine} />

      {/* Tasting Notes */}
      <TastingNoteHistory wineId={wine_id} notes={notes} onNotesChanged={refresh} />

      {/* Bottle History */}
      <BottleHistorySection wineId={wine_id} events={events} notes={notes} />
    </main>
  );
}
```

---

**components/wine-detail/WineDetailHero.tsx** — Black hero band per UX-Mockup §Screen 02. Contains:
- Wine name in Fraunces italic (`--font-accent`), large
- Type badge (JetBrains Mono UPPERCASE), Readiness badge (per `readiness_status`), OPEN badge (if `is_open`)
- Producer · Vintage (Open Sans)
- Qty controls: `−` button (disabled + `aria-disabled="true"` at qty=0), qty display, `+` button; clicking calls PATCH /api/v1/wines/:id/quantity
- Storage location pin (📍 icon + location name or "Location Unknown" warning)
- Latest rating display (stars or numeric per scale) + date
- Action row: [Edit] [Open / Consume Bottle] [Add Tasting Note] / [Delete ⚠]

Action buttons use USWDS patterns:
- Edit: `usa-button usa-button--outline`
- Open / Consume Bottle: `usa-button` Gold (`--color-gold-400` background, Black text)
- Add Tasting Note: `usa-button usa-button--outline`
- Delete: `usa-button usa-button--secondary` (destructive, Ink fill)

"Open / Consume Bottle" opens `BottleEventSheet` modal.
"Delete" opens `DeleteWineModal` confirmation.

Implement PATCH /api/v1/wines/:id/quantity for +/- buttons:
```typescript
const handleQuantityAdjust = async (adjustment: 1 | -1) => {
  await fetch(`/api/v1/wines/${wine.wine_id}/quantity`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ adjustment }),
  });
  onQuantityChange();
};
```

Inline `BottleEventSheet`, `DeleteWineModal` via state toggles (`showEventSheet`, `showDeleteModal`).

Hero band background: `background-color: var(--color-canvas-dark, #0A0A0A)`, text white.

---

**components/wine-detail/BottleEventSheet.tsx** — Action sheet (usa-modal bottom sheet on mobile) per UX-Mockup §Flow 02 and §Pattern 03:

- Three options as `usa-button` rows: Consumed, Gifted, Opened, plus Cancel
- Selecting "Consumed" opens `ConsumeEventDialog`
- Selecting "Gifted" opens `GiftEventDialog`
- Selecting "Opened" opens `OpenEventDialog`
- All dialogs are `usa-modal` pattern with focus trap and Escape to close

---

**components/wine-detail/ConsumeEventDialog.tsx** — Consume bottle dialog per UX-Mockup §Flow 02:

Fields:
- Date consumed (usa-date-picker, defaults to today, not future)
- Notes (optional textarea, max 500 chars)
- "Add Tasting Note?" toggle (usa-checkbox or toggle, defaults ON per CP-03)

On Confirm: POST /api/v1/wines/:wine_id/events with `{ event_type: 'CONSUMED', event_date, notes }`.

If quantity was 0 before confirming, show inline error: "No bottles remain in the cellar for this wine."

On success with toggle ON: call `onConsumeSuccess(event.event_id)` to navigate to tasting note form.
On success with toggle OFF: show toast "Bottle marked as consumed." and call `onConsumeSuccess(undefined)`.

---

**components/wine-detail/GiftEventDialog.tsx** — Gift bottle dialog:

Fields: Date gifted (today default), Recipient (optional, max 200 chars), Notes (optional, max 500 chars).
POST event_type: 'GIFTED'. On success: toast "Bottle marked as gifted." close dialog.

---

**components/wine-detail/OpenEventDialog.tsx** — Open bottle dialog:

Fields: Date opened (today default), Notes (optional, max 500 chars).
POST event_type: 'OPENED'. On success: toast showing OPEN badge appears; close dialog.

---

**components/wine-detail/DeleteWineModal.tsx** — Delete wine confirmation (usa-modal) per UX-Mockup §Flow 03:

```
"Delete [Wine Name]?
 This will permanently remove this wine and all associated tasting notes.
 This cannot be undone."
[Cancel]  [Delete]
```

Delete button: Ink `#1A1A1A` fill (not Gold). On confirm: DELETE /api/v1/wines/:wine_id. On success: toast "Wine record deleted." then call `onDeleteSuccess()`.

---

**components/wine-detail/WineDetailSections.tsx** — Field sections below hero per UX-Mockup §Screen 02 wireframe:

Render 5 sections using `usa-summary-list` pattern or definition-list pairs:
1. **IDENTITY** — Wine Name, Producer, Vintage, Wine Type, Grape Variety, Bottle Size
2. **PROVENANCE & PURCHASE** — Country, Region, Appellation, Purchase Date, Source, Price, Est. Value
3. **STORAGE** — Location Name (or "Location Unknown" warning), Quantity
4. **DRINKING WINDOW** — Start Year – End Year, Readiness Status badge
5. **NOTES** — Free-text notes field

Section headers: JetBrains Mono UPPERCASE, `--color-gray-400`. Use horizontal rule between sections.

If `location_unknown = true`: show warning banner below hero (⚠ Location Unknown — reassign this wine to a storage location).

---

**components/wine-detail/TastingNoteCard.tsx** — Collapsible tasting note card per UX-Mockup §Screen 04 §Tasting Note Card:

Collapsed state shows: rating (stars or numeric per scale), date tasted, Would Buy Again (🛒 YES/NO/MAYBE), Occasion, flavor preview (truncated ~80 chars), [Show full note ▾] expand toggle, [Edit] link, [Delete] link.

Expanded state adds: Appearance, Aroma, Palate/Flavor (full), Finish, Guest Feedback.

Delete: inline confirmation "Delete this tasting note? This cannot be undone." [Cancel] [Delete] — calls DELETE /api/v1/wines/:wine_id/tasting-notes/:note_id.

Edit: links to `/wines/:wine_id/tasting-notes/:note_id/edit`.

Rating display: if `rating_scale = 'STARS_5'`, render filled stars (Gold `#FBCA5C` ★) and empty stars (☆); if `POINTS_100`, render numeric badge. Show scale label if mixed scales present.

---

**components/wine-detail/TastingNoteHistory.tsx** — Tasting notes section wrapper:

Maps over `notes` array and renders `TastingNoteCard` for each. Empty state: "No tasting notes yet. Add one after your next bottle." Section header: "TASTING NOTES" (JetBrains Mono UPPERCASE).

---

**components/wine-detail/BottleHistorySection.tsx** — Bottle event log per UX-Mockup §Screen 02:

Maps over `events` array (already reverse-chronological from API). Each row shows: event icon (🍷 CONSUMED, 🎁 GIFTED, 🔓 OPENED), event type label, event date, optional notes or recipient. CONSUMED events with a linked tasting note show "View tasting note →" link.

Empty state: "No bottle events recorded yet." Section header: "BOTTLE HISTORY" (JetBrains Mono UPPERCASE).

Map `event_id` to a note: for CONSUMED events, check `notes` array for `bottle_event_id === event.event_id` to render the "View tasting note" link.
  </action>
  <verify>
```bash
test -f "app/wines/[wine_id]/page.tsx" && \
test -f components/wine-detail/WineDetailHero.tsx && \
test -f components/wine-detail/WineDetailSections.tsx && \
test -f components/wine-detail/BottleEventSheet.tsx && \
test -f components/wine-detail/ConsumeEventDialog.tsx && \
test -f components/wine-detail/GiftEventDialog.tsx && \
test -f components/wine-detail/OpenEventDialog.tsx && \
test -f components/wine-detail/BottleHistorySection.tsx && \
test -f components/wine-detail/TastingNoteCard.tsx && \
test -f components/wine-detail/TastingNoteHistory.tsx && \
test -f components/wine-detail/DeleteWineModal.tsx && \
test -f lib/hooks/useWineDetail.ts && \
grep -n 'export.*WineDetailHero\|export function WineDetailHero\|export const WineDetailHero' components/wine-detail/WineDetailHero.tsx && \
grep -n 'aria-disabled\|GREATEST\|quantity.*0\|adjustment' components/wine-detail/WineDetailHero.tsx && \
grep -n 'CONSUMED\|GIFTED\|OPENED' components/wine-detail/BottleEventSheet.tsx && \
grep -n 'Add Tasting Note\|toggle\|bottle_event_id' components/wine-detail/ConsumeEventDialog.tsx && \
echo "WINE_DETAIL_COMPONENTS_OK"
```
  </verify>
  <done>
- app/wines/[wine_id]/page.tsx renders WineDetailHero, WineDetailSections, TastingNoteHistory, BottleHistorySection
- WineDetailHero.tsx: Black hero band with Fraunces wine name, type/readiness/open badges, quantity +/- controls (− disabled with aria-disabled at qty=0), storage location pin, rating display, Edit/Consume/AddNote/Delete action row
- WineDetailHero.tsx: PATCH /api/v1/wines/:id/quantity called on +/- click with adjustment: 1 | -1
- BottleEventSheet.tsx: usa-modal action sheet with Consumed/Gifted/Opened/Cancel options
- ConsumeEventDialog.tsx: "Add Tasting Note?" toggle defaults ON (CP-03); on toggle ON navigates to tasting note form with bottle_event_id; on toggle OFF shows toast
- GiftEventDialog.tsx: recipient optional field, GIFTED event POST, success toast
- OpenEventDialog.tsx: OPENED event POST, is_open badge appears
- DeleteWineModal.tsx: usa-modal, Ink Delete button, cascade delete, redirects to /wines
- WineDetailSections.tsx: 5 field sections (Identity, Provenance, Storage, Drinking Window, Notes)
- TastingNoteCard.tsx: collapsed/expanded states, rating display (star or 100-pt), would-buy-again, expand toggle, Edit link, inline Delete confirmation
- TastingNoteHistory.tsx: wraps TastingNoteCard list with empty state
- BottleHistorySection.tsx: reverse-chronological events, CONSUMED events link to tasting note, empty state
- useWineDetail.ts: fetches wine + tasting-notes + events in parallel, exposes refresh callback
  </done>
</task>

<task type="auto">
  <name>Task 2: Add/Edit Wine Form, Storage Locations page, and Tasting Note Form with RatingWidget and WouldBuyAgainToggle</name>
  <files>
    app/wines/new/page.tsx
    app/wines/[wine_id]/edit/page.tsx
    components/wine-form/WineForm.tsx
    components/wine-form/CreateLocationModal.tsx
    app/locations/page.tsx
    components/locations/LocationRow.tsx
    components/locations/DeleteLocationModal.tsx
    app/wines/[wine_id]/tasting-notes/new/page.tsx
    app/wines/[wine_id]/tasting-notes/[note_id]/edit/page.tsx
    components/tasting-note/TastingNoteForm.tsx
    components/tasting-note/RatingWidget.tsx
    components/tasting-note/WouldBuyAgainToggle.tsx
    lib/hooks/useLocations.ts
    lib/hooks/useTastingNotes.ts
  </files>
  <action>
Build the Add/Edit Wine form (18+ fields, 5 sections, inline location modal), Storage Locations management page, and Tasting Note form components.

---

**lib/hooks/useLocations.ts** — Locations data and mutations:

```typescript
'use client';
import { useState, useEffect } from 'react';

export function useLocations() {
  const [locations, setLocations] = useState<StorageLocation[]>([]);
  const [loading, setLoading] = useState(true);

  const refresh = async () => {
    const res = await fetch('/api/v1/locations');
    const json = await res.json();
    setLocations(json.data ?? []);
    setLoading(false);
  };

  const createLocation = async (name: string): Promise<StorageLocation> => {
    const res = await fetch('/api/v1/locations', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ location_name: name }),
    });
    if (!res.ok) {
      const err = await res.json();
      throw new Error(err.error?.message ?? 'Failed to create location');
    }
    const loc = await res.json();
    await refresh();
    return loc;
  };

  const renameLocation = async (locationId: string, newName: string) => {
    await fetch(`/api/v1/locations/${locationId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ location_name: newName }),
    });
    await refresh();
  };

  const deleteLocation = async (locationId: string): Promise<{ affected_wines_count: number }> => {
    const res = await fetch(`/api/v1/locations/${locationId}`, { method: 'DELETE' });
    const json = await res.json();
    await refresh();
    return json;
  };

  useEffect(() => { refresh(); }, []);
  return { locations, loading, refresh, createLocation, renameLocation, deleteLocation };
}
```

---

**lib/hooks/useTastingNotes.ts** — Tasting notes mutations + rating scale preference:

```typescript
'use client';
import { useState, useEffect } from 'react';

export function useRatingScale(): 'STARS_5' | 'POINTS_100' {
  const [scale, setScale] = useState<'STARS_5' | 'POINTS_100'>('STARS_5');
  useEffect(() => {
    fetch('/api/v1/settings/rating-scale')
      .then(r => r.json())
      .then(d => setScale(d.rating_scale ?? 'STARS_5'))
      .catch(() => {});
  }, []);
  return scale;
}

export async function submitTastingNote(
  wineId: string,
  noteId: string | null,
  data: TastingNoteInput
): Promise<TastingNote> {
  const url = noteId
    ? `/api/v1/wines/${wineId}/tasting-notes/${noteId}`
    : `/api/v1/wines/${wineId}/tasting-notes`;
  const method = noteId ? 'PUT' : 'POST';
  const res = await fetch(url, {
    method,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
  if (!res.ok) {
    const err = await res.json();
    throw new Error(err.error?.message ?? 'Failed to save tasting note');
  }
  return res.json();
}
```

---

**components/wine-form/WineForm.tsx** — Full Add/Edit wine form per UX-Mockup §Screen 03. All 18+ fields in 5 visually grouped sections.

**Field groups per UX-Mockup §Screen 03:**

1. **REQUIRED** section (Bone `#FAFAF7` bg, Gold-600 eyebrow):
   - Wine Name* — `usa-input`, max 200 chars
   - Producer / Winery* — `usa-input`, max 200 chars
   - Vintage Year* — numeric `usa-input`, validates 1900–(currentYear+1), 4-digit
   - Wine Type* — `usa-radio` group, 6 options: Red / White / Rosé / Sparkling / Dessert / Fortified
   - Quantity* — integer `usa-input`, min 1
   - Storage Location* — `usa-select` dropdown (alphabetically sorted), with "+ Add new location..." option at bottom that opens `CreateLocationModal`

2. **OPTIONAL** section (Paper `#F5F5F2` bg, gray eyebrow):
   - Country — `usa-input`
   - Region — `usa-input`
   - Appellation — `usa-input`
   - Grape Variety — `usa-input`
   - Bottle Size — `usa-radio` group, 4 options: 375ml / 750ml (default) / 1.5L / 3L

3. **PURCHASE** section (Paper bg):
   - Purchase Date — `usa-date-picker`, not future
   - Purchase Source — `usa-input`
   - Purchase Price (per bottle) — numeric `usa-input`, currency display, min 0
   - Estimated Value (per bottle) — numeric `usa-input`, currency display, min 0

4. **DRINKING WINDOW** section (Paper bg):
   - Start Year — numeric `usa-input`, 1900–2200
   - End Year — numeric `usa-input`, 1900–2200, ≥ Start (cross-validates on blur)

5. **NOTES** section (Paper bg):
   - Notes — `usa-textarea`, max 5000 chars

Submit button: Gold `#FBCA5C` fill, Montserrat 700 UPPERCASE, text "ADD WINE" (add mode) or "SAVE WINE" (edit mode). Cancel button: ghost style, returns to previous screen.

**Validation per UX-Mockup §Screen 03 Validation Rules:**
- Required fields enforced; inline `usa-error-message` on each failed field
- Vintage: `1900 ≤ value ≤ currentYear+1`
- Quantity: integer ≥ 1
- Purchase Date: not future
- Drink Window Start ≤ End (cross-field, validates on blur of End field)
- Form-level error: "Please correct the fields below." shown above submit if multiple fail
- Data NOT cleared on validation failure

**Edit mode:** Pre-fill `initialValues` into all form fields on mount. `storage_location_id` pre-selects current location. On successful PUT, navigate back to Wine Detail with toast "Wine record updated."

**Add mode:** Pre-select most recently used location from `localStorage['lastLocationId']` if available. On successful POST, navigate to Wine Detail for new wine with toast "Wine added to your cellar." Store new `storage_location_id` in `localStorage['lastLocationId']`.

**Submit handler (add mode):**
```typescript
const res = await fetch('/api/v1/wines', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(formData),
});
```

**Submit handler (edit mode):**
```typescript
const res = await fetch(`/api/v1/wines/${wine.wine_id}`, {
  method: 'PUT',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(formData),
});
```

---

**components/wine-form/CreateLocationModal.tsx** — Inline modal per UX-Mockup §Screen 03 §Inline Create Location Modal:

```
[Add Storage Location modal]
  Location name * (max 100 chars)
  ⚠ A location with that name already exists.  (shown on 409)
  [Cancel]  [Add Location]
```

On save: POST /api/v1/locations. On 409: show inline error "A location with that name already exists." On success: call `onLocationCreated(newLocation)` so WineForm auto-selects it.

---

**app/wines/new/page.tsx** — Add Wine page:

```typescript
'use client';
import { WineForm } from '@/components/wine-form/WineForm';
import { useRouter } from 'next/navigation';
export default function AddWinePage() {
  const router = useRouter();
  return (
    <main className="usa-section">
      <h1 className="font-display">Add Wine</h1>
      <WineForm mode="add" onSuccess={(wine) => router.push(`/wines/${wine.wine_id}`)} />
    </main>
  );
}
```

---

**app/wines/[wine_id]/edit/page.tsx** — Edit Wine page. Fetch current wine then pass to WineForm as `initialValues`:

```typescript
'use client';
import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { WineForm } from '@/components/wine-form/WineForm';
export default function EditWinePage() {
  const { wine_id } = useParams<{ wine_id: string }>();
  const router = useRouter();
  const [wine, setWine] = useState<WineRecord | null>(null);
  useEffect(() => {
    fetch(`/api/v1/wines/${wine_id}`).then(r => r.json()).then(setWine);
  }, [wine_id]);
  if (!wine) return <div className="usa-section"><p>Loading...</p></div>;
  return (
    <main className="usa-section">
      <h1 className="font-display">Edit Wine</h1>
      <WineForm mode="edit" initialValues={wine} onSuccess={() => router.push(`/wines/${wine_id}`)} />
    </main>
  );
}
```

---

**app/locations/page.tsx** — Storage Locations management page per UX-Mockup §Screen 05:

```typescript
'use client';
import { useLocations } from '@/lib/hooks/useLocations';
import { LocationRow } from '@/components/locations/LocationRow';
import { DeleteLocationModal } from '@/components/locations/DeleteLocationModal';
import { CreateLocationModal } from '@/components/wine-form/CreateLocationModal';
// ...
```

Layout:
- Page header: "Storage Locations" (Montserrat 900)
- If any wine has `location_unknown = true` (detected from locations data): warning entry at top with "⚠ LOCATION UNKNOWN — [N] wine(s) need reassignment." and "Reassign wines →" link to `/wines?location_id=UNKNOWN`
- List of `LocationRow` for each location
- "+ ADD LOCATION" Gold primary button at bottom opens inline `CreateLocationModal`
- On delete confirmation: show `DeleteLocationModal` with affected wine count; on confirm call `deleteLocation(locationId)`; show toast "Location deleted. [N] wine(s) marked as Location Unknown."

Empty state (no locations): "No storage locations defined. Add one to get started."

---

**components/locations/LocationRow.tsx** — Single location row per UX-Mockup §Screen 05:

```
[Location Name]        [N bottles]     [Edit]  [Delete ⛔]
```

- Edit: inline text input that replaces the name on click; PUT /api/v1/locations/:id on submit; toast "Location renamed."
- Delete: opens `DeleteLocationModal`
- 0-bottle locations still shown with "0 bottles" in `--color-gray-400`

---

**components/locations/DeleteLocationModal.tsx** — Delete location confirmation (usa-modal) per UX-Mockup §Flow 05:

```
"Delete '[Location Name]'? [N] wine(s) assigned to this location
 will be marked as 'Location Unknown.' This cannot be undone."
[Cancel]  [Delete]
```

Ink `#1A1A1A` fill on Delete button. Call `onConfirm()` which triggers `deleteLocation` in parent.

---

**components/tasting-note/RatingWidget.tsx** — Dual-mode rating input per UX-Mockup §Screen 04 §Rating Input Scale Variants:

Props: `value: number | null`, `onChange: (n: number | null) => void`, `scale: 'STARS_5' | 'POINTS_100'`

**STARS_5 mode:** Render 5 tappable star buttons. Filled star = Gold `#FBCA5C` ★; empty = ☆. Tapping star N sets rating to N. Tapping the same star again clears to null. Label: "(5-star scale)" in JetBrains Mono.

**POINTS_100 mode:** Render `usa-input` numeric input, integer 1–100, validates on blur. Clears to null if empty. Label: "(1–100 scale)" in JetBrains Mono.

Accessibility: each star button has `aria-label="Rate [N] star[s]"`, `aria-pressed={rating >= N}`.

---

**components/tasting-note/WouldBuyAgainToggle.tsx** — `usa-button-group` toggle per UX-Mockup §Screen 04:

Props: `value: 'YES' | 'NO' | 'MAYBE' | null`, `onChange: (v: 'YES' | 'NO' | 'MAYBE' | null) => void`

Three buttons in a `usa-button-group`: [Yes] [Maybe] [No]. Active button gets Gold fill. Clicking an already-active button deselects (sets null). Uses `aria-pressed` on each.

---

**components/tasting-note/TastingNoteForm.tsx** — Full tasting note form per UX-Mockup §Screen 04:

Props: `wineId: string`, `noteId?: string` (for edit mode), `bottleEventId?: string` (pre-linked), `initialValues?: TastingNoteInput`, `onSuccess: () => void`

Layout (top to bottom):
- Wine context header: "*[Wine Name]* [Vintage]" in Fraunces italic (fetch wine name from props or parent context)
- If `bottleEventId`: show "Linked event: Consumed [date]" in Open Sans muted
- **Date Tasted*** — `usa-date-picker`, default today, not future validation
- **Personal Rating** — `RatingWidget` rendered per `ratingScale` from `useRatingScale()`
- **Would Buy Again?** — `WouldBuyAgainToggle`
- **Occasion** (optional) — `usa-input`, max 200 chars
- **TASTING DETAILS (OPTIONAL)** section header
- Appearance — `usa-textarea`, max 500 chars
- Aroma / Nose — `usa-textarea`, max 500 chars
- Flavor / Palate — `usa-textarea`, max 1000 chars
- Finish — `usa-textarea`, max 500 chars
- Guest Feedback (optional) — `usa-textarea`, max 500 chars
- "SAVE NOTE" Gold button — Montserrat 700 UPPERCASE
- [Cancel] ghost button

Validation: date_tasted required and not future (inline `usa-error-message`). If rating provided, validate range per scale (STARS_5: 1–5, POINTS_100: 1–100). Include `rating_scale` field in submission body.

Submit calls `submitTastingNote(wineId, noteId ?? null, formData)`. On success: show toast "Tasting note saved." (add) or "Tasting note updated." (edit). Call `onSuccess()`.

---

**app/wines/[wine_id]/tasting-notes/new/page.tsx** — Add Tasting Note page:

```typescript
'use client';
import { useParams, useRouter, useSearchParams } from 'next/navigation';
import { TastingNoteForm } from '@/components/tasting-note/TastingNoteForm';
export default function AddTastingNotePage() {
  const { wine_id } = useParams<{ wine_id: string }>();
  const searchParams = useSearchParams();
  const router = useRouter();
  const bottleEventId = searchParams.get('bottle_event_id') ?? undefined;
  return (
    <main className="usa-section">
      <h1 className="font-display">Add Tasting Note</h1>
      <TastingNoteForm
        wineId={wine_id}
        bottleEventId={bottleEventId}
        onSuccess={() => router.push(`/wines/${wine_id}`)}
      />
    </main>
  );
}
```

---

**app/wines/[wine_id]/tasting-notes/[note_id]/edit/page.tsx** — Edit Tasting Note page. Fetch existing note and pass as initialValues:

```typescript
'use client';
import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { TastingNoteForm } from '@/components/tasting-note/TastingNoteForm';
export default function EditTastingNotePage() {
  const { wine_id, note_id } = useParams<{ wine_id: string; note_id: string }>();
  const router = useRouter();
  const [note, setNote] = useState<TastingNoteInput | null>(null);
  useEffect(() => {
    fetch(`/api/v1/wines/${wine_id}/tasting-notes/${note_id}`)
      .then(r => r.json()).then(setNote);
  }, [wine_id, note_id]);
  if (!note) return <div className="usa-section"><p>Loading...</p></div>;
  return (
    <main className="usa-section">
      <h1 className="font-display">Edit Tasting Note</h1>
      <TastingNoteForm
        wineId={wine_id}
        noteId={note_id}
        initialValues={note}
        onSuccess={() => router.push(`/wines/${wine_id}`)}
      />
    </main>
  );
}
```
  </action>
  <verify>
```bash
test -f app/wines/new/page.tsx && \
test -f "app/wines/[wine_id]/edit/page.tsx" && \
test -f components/wine-form/WineForm.tsx && \
test -f components/wine-form/CreateLocationModal.tsx && \
test -f app/locations/page.tsx && \
test -f components/locations/LocationRow.tsx && \
test -f components/locations/DeleteLocationModal.tsx && \
test -f "app/wines/[wine_id]/tasting-notes/new/page.tsx" && \
test -f "app/wines/[wine_id]/tasting-notes/[note_id]/edit/page.tsx" && \
test -f components/tasting-note/TastingNoteForm.tsx && \
test -f components/tasting-note/RatingWidget.tsx && \
test -f components/tasting-note/WouldBuyAgainToggle.tsx && \
test -f lib/hooks/useLocations.ts && \
test -f lib/hooks/useTastingNotes.ts && \
grep -n 'export.*WineForm\|export function WineForm\|export const WineForm' components/wine-form/WineForm.tsx && \
grep -n 'export.*RatingWidget\|export function RatingWidget\|export const RatingWidget' components/tasting-note/RatingWidget.tsx && \
grep -n 'STARS_5\|POINTS_100' components/tasting-note/RatingWidget.tsx && \
grep -n 'aria-pressed\|YES.*MAYBE.*NO\|WouldBuyAgain' components/tasting-note/WouldBuyAgainToggle.tsx && \
grep -n 'CreateLocationModal\|Add new location\|Add Location' components/wine-form/WineForm.tsx && \
grep -n 'bottle_event_id\|bottleEventId' "app/wines/[wine_id]/tasting-notes/new/page.tsx" && \
grep -n 'LocationRow\|AddLocation\|LOCATION UNKNOWN' app/locations/page.tsx && \
echo "FORMS_LOCATIONS_TASTING_COMPONENTS_OK"
```
  </verify>
  <done>
- app/wines/new/page.tsx renders WineForm in add mode; success navigates to Wine Detail with toast
- app/wines/[wine_id]/edit/page.tsx fetches wine, renders WineForm in edit mode pre-filled; success navigates to Wine Detail
- WineForm.tsx: 5 grouped form sections (REQUIRED/OPTIONAL/PURCHASE/DRINKING WINDOW/NOTES), all 18+ fields, usa-input/usa-select/usa-radio/usa-textarea/usa-date-picker, validation per FRD F00.6, Gold submit button, localStorage lastLocationId pre-selection on Add mode
- CreateLocationModal.tsx: inline usa-modal for creating locations from within WineForm; 409 duplicate error shown inline; auto-selects new location on success
- app/locations/page.tsx: lists all locations with bottle counts, Location Unknown synthetic entry at top when applicable, + ADD LOCATION Gold button, delete confirmation modal with affected count
- LocationRow.tsx: name, bottle count (gray if 0), inline rename edit, Delete trigger
- DeleteLocationModal.tsx: usa-modal with affected wine count, Ink Delete button, calls onConfirm
- app/wines/[wine_id]/tasting-notes/new/page.tsx: reads bottle_event_id from searchParams (CP-03 post-consume flow), passes to TastingNoteForm
- app/wines/[wine_id]/tasting-notes/[note_id]/edit/page.tsx: fetches note, renders TastingNoteForm in edit mode
- TastingNoteForm.tsx: date_tasted (required, today default, not future), RatingWidget (per scale), WouldBuyAgainToggle, Occasion, all 4 sensory textareas, Guest Feedback; saves with rating_scale in body
- RatingWidget.tsx: STARS_5 = 5 Gold tappable stars with aria-pressed, POINTS_100 = numeric usa-input 1–100; deselect on re-tap; scale label shown
- WouldBuyAgainToggle.tsx: usa-button-group YES/MAYBE/NO, Gold active fill, aria-pressed, deselectable
- useLocations.ts: fetches locations, exposes createLocation/renameLocation/deleteLocation mutations with refresh
- useTastingNotes.ts: useRatingScale hook + submitTastingNote helper
  </done>
</task>

</tasks>

<verification>
After both tasks complete:

```bash
# 1. All page routes exist
ls "app/wines/[wine_id]/page.tsx" app/wines/new/page.tsx "app/wines/[wine_id]/edit/page.tsx" \
   app/locations/page.tsx \
   "app/wines/[wine_id]/tasting-notes/new/page.tsx" \
   "app/wines/[wine_id]/tasting-notes/[note_id]/edit/page.tsx"

# 2. All component files exist
ls components/wine-detail/WineDetailHero.tsx \
   components/wine-detail/BottleEventSheet.tsx \
   components/wine-detail/ConsumeEventDialog.tsx \
   components/wine-detail/TastingNoteCard.tsx \
   components/wine-form/WineForm.tsx \
   components/wine-form/CreateLocationModal.tsx \
   components/locations/LocationRow.tsx \
   components/tasting-note/TastingNoteForm.tsx \
   components/tasting-note/RatingWidget.tsx \
   components/tasting-note/WouldBuyAgainToggle.tsx

# 3. TechSur design token usage in hero band
grep -n 'canvas-dark\|0A0A0A\|font-accent\|Fraunces' components/wine-detail/WineDetailHero.tsx

# 4. Quantity floor guard — aria-disabled at qty=0
grep -n 'aria-disabled\|quantity.*===.*0\|qty.*0' components/wine-detail/WineDetailHero.tsx

# 5. CP-03 post-consume tasting note redirect
grep -n 'bottle_event_id\|onConsumeSuccess\|Add Tasting Note.*toggle\|toggle.*ON' components/wine-detail/ConsumeEventDialog.tsx

# 6. F03 validation rules in WineForm
grep -n 'Wine name is required\|Vintage must\|Drink by start\|Please correct' components/wine-form/WineForm.tsx

# 7. CreateLocationModal duplicate error handling
grep -n '409\|already exists\|DUPLICATE_LOCATION' components/wine-form/CreateLocationModal.tsx

# 8. RatingWidget dual-scale
grep -n 'STARS_5\|POINTS_100\|aria-pressed\|aria-label.*Rate' components/tasting-note/RatingWidget.tsx

# 9. Storage Locations page — Location Unknown synthetic entry
grep -n 'LOCATION UNKNOWN\|location_unknown\|Reassign' app/locations/page.tsx

# 10. TypeScript check
npx tsc --noEmit 2>&1 | head -30 || true
```
</verification>

<success_criteria>
- Wine Detail page fully functional: hero band (Black bg, Fraunces wine name, type/readiness/open badges, qty +/- with aria-disabled at 0, storage location pin, rating, action row)
- Open/Consume Bottle action sheet opens with 3 options; Consumed dialog has "Add Tasting Note?" toggle ON by default (CP-03); on confirm with toggle ON navigates to /wines/:id/tasting-notes/new?bottle_event_id=...
- Gifted dialog decrements quantity, shows toast; Opened dialog sets is_open badge
- Delete Wine modal: Ink Delete button, cascade confirmed, navigates to /wines, toast shown
- Wine Detail shows all 5 field sections; Location Unknown warning banner visible when applicable
- Tasting note cards: collapsed (rating + date + would-buy-again + occasion + flavor preview + expand toggle) and expanded (all sensory fields); Edit link and Delete confirmation
- Bottle history: reverse-chronological, CONSUMED events with "View tasting note →" link, empty state
- Add/Edit Wine form: all 18+ fields in 5 grouped sections, USWDS components, Gold submit, full FRD F00.6 validation with inline `usa-error-message`, data retained on validation failure
- "Add new location..." in Storage Location dropdown opens CreateLocationModal; 409 duplicate shown inline; new location auto-selected
- Edit mode pre-fills all fields; save returns to Wine Detail with toast "Wine record updated."
- Storage Locations page: Location Unknown synthetic entry at top (if any) with Reassign link, all locations with bottle counts (0-count shown), rename inline, delete with affected-count modal and toast
- Tasting Note form: date required (today default, not future), RatingWidget renders stars (STARS_5) or numeric input (POINTS_100) per user setting, WouldBuyAgainToggle (YES/MAYBE/NO), all sensory fields, Gold "SAVE NOTE" button
- RatingWidget: star tap sets rating, re-tap clears; 100-pt validates 1–100 on blur; aria-pressed on each star
- WouldBuyAgainToggle: usa-button-group, Gold active, aria-pressed, deselectable
- New tasting note page reads `bottle_event_id` from searchParams and passes to TastingNoteForm for linked post-consume flow
</success_criteria>

<output>
After completion, create `.planning/express/building-a-web-app-to-keep-track-of-my-w/07-SUMMARY.md` summarizing:
- Pages created (Wine Detail, Add Wine, Edit Wine, Storage Locations, Add/Edit Tasting Note)
- Components created per domain (wine-detail, wine-form, locations, tasting-note)
- Key UX flows implemented (CP-01 location-always-visible, CP-03 tiered-post-consume, F02 inline location creation)
- Integration points wired (API endpoints consumed per domain)
- Design token usage (TechSur Black hero, Gold buttons, Fraunces wine name, JetBrains Mono badges)
- Any deviations from UX-Mockup specs (expected: none)
</output>
