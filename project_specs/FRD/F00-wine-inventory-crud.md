---

## F00: Wine Inventory CRUD

**PRD Reference:** F0 — Priority P0 (Critical)

**Description:** The core data management feature that allows users to create, view, edit, and delete wine records in their personal cellar. Every wine in the cellar is represented as a structured record covering identity, provenance, storage assignment, acquisition context, and drinking window. This is the foundational capability from which all other features (F1–F6) are built — no other feature functions without wine records existing.

---

### Terminology

| Term | Definition |
|------|-----------|
| **Wine Record** | The primary entity: a single wine entry identified by producer + label + vintage. One record may represent multiple physical bottles (quantity ≥ 1). |
| **Required Fields** | The minimum set of fields that must be populated to create or save a wine record. |
| **Optional Fields** | Fields that enrich the record but may be omitted. Stored as NULL in the database. |
| **Estimated Value** | User-entered current market value estimate per bottle. Not calculated automatically in v1. |
| **Appellation** | A legally defined wine-producing geographic designation (e.g., Napa Valley AVA, Bordeaux AOC). Sub-division of Region. |
| **Bottle Size** | Physical volume of the wine bottle. Supported sizes: 375ml (half-bottle), 750ml (standard), 1.5L (Magnum), 3L (Double Magnum). |

---

### Sub-Features

- **F00.1 — Add Wine:** Create a new wine record via form with all fields
- **F00.2 — Wine List View:** Browse all wines in a card/table list with key attributes
- **F00.3 — Wine Detail View:** View all fields for a single wine record
- **F00.4 — Edit Wine:** Modify any field on an existing wine record
- **F00.5 — Delete Wine:** Remove a wine record with confirmation prompt
- **F00.6 — Form Validation:** Enforce required fields and field-level format rules before save

---

### Process

#### F00.1 — Add Wine

1. User taps the "+" floating action button (FAB) or the "Add Wine" navigation action.
2. System displays the Add Wine form with all fields (required fields marked with asterisk).
3. User fills in required fields: Wine Name, Producer, Vintage Year, Wine Type, Quantity, Storage Location.
4. User optionally fills in: Country, Region, Appellation, Grape Variety, Bottle Size, Purchase Date, Purchase Source, Purchase Price, Estimated Value, Drinking Window Start, Drinking Window End, Notes.
5. User submits the form.
6. System validates all required fields are present and all format rules pass (see Validation).
7. If validation fails, system highlights failed fields with inline error messages; form is NOT saved.
8. If validation passes, system saves the wine record to the data store.
9. System assigns a unique `wine_id` (UUID), sets `created_at` and `updated_at` timestamps.
10. System navigates the user to the Wine Detail view for the newly created record.
11. System displays a success toast: "Wine added to your cellar."

#### F00.2 — Wine List View

1. User navigates to the Wine List (main collection view).
2. System fetches all wine records, defaulting to sort by `date_added` descending (newest first).
3. System renders each wine as a card (mobile) or table row (desktop) showing: Wine Name, Producer, Vintage, Wine Type badge, Readiness Status badge (from F05), Quantity, Storage Location.
4. "Cellar Empty" wines (quantity = 0) are visually de-emphasized (muted opacity) but still shown by default.
5. User may apply search or filters (see F03) to narrow the list.
6. Active filter state is displayed as dismissible chips above the list.

#### F00.3 — Wine Detail View

1. User taps a wine card or row in the list.
2. System fetches the full wine record by `wine_id`.
3. System renders all fields, grouped by section: Identity, Provenance & Purchase, Storage, Drinking Window, Tasting Notes (from F04), Bottle Event Log (from F01).
4. Readiness Status badge is displayed prominently (derived from F05).
5. Action buttons displayed: "Edit," "Open / Consume Bottle," "Add Tasting Note," "Delete."

#### F00.4 — Edit Wine

1. User taps "Edit" on the Wine Detail view.
2. System displays the Edit Wine form pre-populated with all current field values.
3. User modifies any field(s).
4. User submits the form.
5. System validates all required fields and format rules (same rules as Add Wine).
6. If validation fails, inline errors are shown; record is NOT saved.
7. If validation passes, system updates the record and sets `updated_at` to current timestamp.
8. System navigates back to the Wine Detail view and displays a success toast: "Wine record updated."

#### F00.5 — Delete Wine

1. User taps "Delete" on the Wine Detail view.
2. System displays a confirmation modal: "Delete [Wine Name]? This will permanently remove this wine and all associated tasting notes. This cannot be undone." with "Cancel" and "Delete" buttons.
3. If user confirms, system deletes the wine record and all associated tasting notes and bottle events (cascade delete).
4. System navigates to the Wine List view.
5. System displays a success toast: "Wine record deleted."
6. If user cancels, modal closes with no changes made.

---

### Inputs

**Required Fields:**

| Field | Type | Constraints |
|-------|------|------------|
| `wine_name` | string | Required; 1–200 characters |
| `producer` | string | Required; 1–200 characters |
| `vintage_year` | integer | Required; 1900 ≤ value ≤ (current year + 1) |
| `wine_type` | enum | Required; one of: RED, WHITE, ROSE, SPARKLING, DESSERT, FORTIFIED |
| `quantity` | integer | Required; 1 ≤ value ≤ 9999 |
| `storage_location_id` | UUID (FK) | Required; must reference an existing storage location |

**Optional Fields:**

| Field | Type | Constraints |
|-------|------|------------|
| `country` | string | Optional; 1–100 characters |
| `region` | string | Optional; 1–100 characters |
| `appellation` | string | Optional; 1–100 characters |
| `grape_variety` | string | Optional; 1–200 characters; free text (may contain multiple grapes, e.g., "Cabernet Sauvignon, Merlot") |
| `bottle_size` | enum | Optional; one of: 375ML, 750ML, 1500ML, 3000ML; default 750ML if omitted |
| `purchase_date` | date | Optional; ISO 8601 date (YYYY-MM-DD); must not be in the future |
| `purchase_source` | string | Optional; 1–200 characters (e.g., "Wine.com," "Local shop") |
| `purchase_price` | decimal | Optional; ≥ 0.00; up to 2 decimal places; currency assumed USD in v1 |
| `estimated_value` | decimal | Optional; ≥ 0.00; up to 2 decimal places; user-entered estimate per bottle |
| `drink_window_start` | integer | Optional; 1900 ≤ value ≤ 2200; must be ≤ `drink_window_end` if both provided |
| `drink_window_end` | integer | Optional; 1900 ≤ value ≤ 2200; must be ≥ `drink_window_start` if both provided |
| `notes` | string | Optional; up to 5000 characters; free text |

---

### Outputs

- **Wine Detail View:** All fields rendered, grouped by section (Identity, Provenance, Storage, Drinking Window, Tasting Notes, Bottle Events)
- **Wine List Card (mobile):** `wine_name`, `producer`, `vintage_year`, `wine_type` badge, readiness status badge, `quantity`, `storage_location` display name
- **Wine List Row (desktop):** Same fields plus `country`, `region`, `purchase_price` columns
- **API Response (POST /wines):** Full wine record JSON (see `Y1-api.md §F00`)
- **API Response (GET /wines/:id):** Full wine record JSON
- **API Response (PUT /wines/:id):** Updated wine record JSON
- **API Response (DELETE /wines/:id):** `204 No Content`

---

### Validation Rules

- `wine_name`: Required; must not be blank or whitespace-only; max 200 chars.
- `producer`: Required; must not be blank or whitespace-only; max 200 chars.
- `vintage_year`: Required; must be an integer; must satisfy 1900 ≤ value ≤ (current year + 1). Non-numeric input rejected with message "Vintage must be a year (e.g., 2019)."
- `wine_type`: Required; must be one of the six valid enum values. UI enforces via select/radio; API validates and rejects unknown values with `400`.
- `quantity`: Required; must be a positive integer ≥ 1. Decimal or negative values rejected.
- `storage_location_id`: Required; the referenced location ID must exist in the `storage_locations` table. Orphan reference rejected with `422`.
- `bottle_size`: If provided, must be one of the four valid enum values. Defaults to `750ML` if omitted.
- `purchase_date`: If provided, must be a valid ISO 8601 date; must not be in the future (> today's date).
- `purchase_price`: If provided, must be a non-negative number with ≤ 2 decimal places.
- `estimated_value`: If provided, must be a non-negative number with ≤ 2 decimal places.
- `drink_window_start`: If provided, must be integer 1900–2200. If `drink_window_end` is also provided, `drink_window_start` must be ≤ `drink_window_end`.
- `drink_window_end`: If provided, must be integer 1900–2200. If `drink_window_start` is also provided, `drink_window_end` must be ≥ `drink_window_start`.
- `notes`: If provided, must not exceed 5000 characters.
- `grape_variety`, `country`, `region`, `appellation`, `purchase_source`: Optional string fields; if provided, must not exceed their respective max lengths.

---

### Error States

| Scenario | HTTP Status | Error Code | User Message |
|----------|-------------|------------|-------------|
| Missing required field | 422 | VALIDATION_ERROR | "Wine name is required." (field-specific) |
| Vintage year out of range | 422 | VALIDATION_ERROR | "Vintage must be between 1900 and [current+1]." |
| Invalid wine type value | 422 | VALIDATION_ERROR | "Wine type must be one of: Red, White, Rosé, Sparkling, Dessert, Fortified." |
| Quantity < 1 | 422 | VALIDATION_ERROR | "Quantity must be at least 1." |
| Storage location not found | 422 | INVALID_REFERENCE | "The selected storage location no longer exists. Please choose another." |
| Drinking window start > end | 422 | VALIDATION_ERROR | "Drink by start year must be before or equal to end year." |
| Purchase date in future | 422 | VALIDATION_ERROR | "Purchase date cannot be in the future." |
| Wine record not found | 404 | WINE_NOT_FOUND | "Wine record not found." |
| Delete with confirm cancelled | — | — | Modal closed; no action taken |
| Duplicate wine name + producer + vintage | — | — | No uniqueness constraint in v1; user may create identical records |

---

### API Surface (this feature)

See `Y1-api.md §F00 — Wine Inventory` for full request/response schemas.

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/v1/wines` | List all wine records (with filter/sort query params) |
| POST | `/api/v1/wines` | Create a new wine record |
| GET | `/api/v1/wines/:wine_id` | Get single wine record by ID |
| PUT | `/api/v1/wines/:wine_id` | Update a wine record (full replace) |
| PATCH | `/api/v1/wines/:wine_id` | Partial update of a wine record |
| DELETE | `/api/v1/wines/:wine_id` | Delete a wine record (cascade) |

---

### Schema Surface (this feature)

Uses tables: `wines`, `storage_locations` (FK reference) — see `Y0-schema.md §Wines` for full DDL.

**Key columns on `wines`:** `wine_id` (PK), `wine_name`, `producer`, `vintage_year`, `wine_type`, `grape_variety`, `country`, `region`, `appellation`, `bottle_size`, `quantity`, `storage_location_id` (FK), `purchase_date`, `purchase_source`, `purchase_price`, `estimated_value`, `drink_window_start`, `drink_window_end`, `notes`, `created_at`, `updated_at`.

---
