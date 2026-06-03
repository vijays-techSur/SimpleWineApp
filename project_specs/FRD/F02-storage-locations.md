---

## F02: Storage Location Management

**PRD Reference:** F2 — Priority P0 (Critical)

**Description:** Users store bottles in multiple physical spaces — wine fridges, basement cellars, kitchen racks, storage units. This feature lets users define named storage locations, assign each wine record to one location, and maintain an accurate "where is it?" answer for every bottle. Locations are user-defined and free-form, with no structural hierarchy imposed. When a location is deleted, all wines assigned to it are flagged as "Location Unknown" rather than being silently left with a broken reference, preserving data integrity and surfacing the issue to the user.

---

### Terminology

| Term | Definition |
|------|-----------|
| **Storage Location** | A user-defined named physical place where wine bottles are kept (e.g., "Wine Fridge – Top Shelf," "Basement Cellar," "Kitchen Rack"). |
| **Location Unknown** | Flag state applied to wines whose assigned storage location has been deleted. Displayed as a warning on the wine record. |
| **Location Assignment** | The foreign-key link from a wine record to a storage location (`storage_location_id` on the `wines` table). |

---

### Sub-Features

- **F02.1 — Create Location:** Define a new named storage location
- **F02.2 — Rename Location:** Change the display name of an existing location
- **F02.3 — Delete Location:** Remove a location; flag affected wine records
- **F02.4 — Assign Location to Wine:** Select a location when adding or editing a wine record
- **F02.5 — Filter by Location:** Filter the wine list to show only wines in a given location (see F03)
- **F02.6 — Location List View:** View all defined locations with bottle count per location

---

### Process

#### F02.1 — Create Location

1. User navigates to Settings → Storage Locations (or taps "Manage Locations" from the wine add/edit form).
2. User taps "Add Location."
3. System presents a text input: "Location name" (max 100 characters).
4. User enters a name and confirms.
5. System validates the name is not blank and is unique among existing locations (case-insensitive check).
6. System saves the new `storage_location` record with a generated `location_id` (UUID) and `created_at`.
7. System displays success message: "Location added." The new location is immediately available in the wine add/edit form's location dropdown.

#### F02.2 — Rename Location

1. User navigates to Settings → Storage Locations.
2. User taps "Edit" on an existing location row.
3. System presents an editable text field pre-populated with the current name.
4. User changes the name and confirms.
5. System validates: not blank, unique (case-insensitive), max 100 chars.
6. System updates the `storage_location` record's `location_name` and `updated_at`.
7. All wine records referencing this location immediately display the new name (no migration needed — name is stored on the location record, not denormalized on wines).
8. Success message: "Location renamed."

#### F02.3 — Delete Location

1. User navigates to Settings → Storage Locations.
2. User taps "Delete" on a location row.
3. System displays confirmation modal: "Delete '[Location Name]'? [N] wine(s) assigned to this location will be marked as 'Location Unknown.' This cannot be undone." with "Cancel" and "Delete" buttons.
4. If user confirms:
   a. System sets `storage_location_id = NULL` on all `wines` records that referenced this location.
   b. System sets `location_unknown = true` on those wine records.
   c. System deletes the `storage_location` record.
   d. System displays success message: "Location deleted. [N] wine(s) marked as Location Unknown."
5. If user cancels, modal closes; no changes made.

#### F02.4 — Assign Location to Wine

1. During Add Wine (F00.1) or Edit Wine (F00.4), the "Storage Location" field is a required dropdown select.
2. System populates the dropdown with all existing location names, sorted alphabetically.
3. A "Add new location..." option at the bottom of the dropdown opens the Create Location inline flow (F02.1) and returns the user to the wine form with the new location pre-selected.
4. User must select a location before the form can be saved.

#### F02.6 — Location List View

1. User navigates to Settings → Storage Locations.
2. System displays all locations as a list, each row showing: Location Name, Bottle Count (sum of `quantity` across all wines at this location with quantity > 0).
3. Rows with bottle count = 0 are still shown (empty location).
4. Row actions: "Edit" (rename), "Delete."
5. "Location Unknown" is shown as a synthetic entry at the top if any wines have `location_unknown = true`, with the count of affected wines and a "Reassign" link that filters the wine list to Location Unknown wines.

---

### Inputs

| Field | Type | Required | Constraints |
|-------|------|----------|------------|
| `location_name` | string | Yes | 1–100 characters; must be unique (case-insensitive) among existing locations |
| `location_id` | UUID | Yes (for update/delete) | Must reference existing location |

**Wine Assignment Input:**

| Field | Type | Required | Constraints |
|-------|------|----------|------------|
| `storage_location_id` | UUID (FK) | Yes (on wine form) | Must reference existing location |

---

### Outputs

- **Location List:** All user-defined locations with bottle counts
- **Location Dropdown (wine form):** Alphabetically sorted list of location names
- **Wine List Card / Detail:** `storage_location` display name shown prominently
- **"Location Unknown" Warning:** Displayed on wine card and detail view when `location_unknown = true`
- **API Response (POST /locations):** Created location JSON
- **API Response (GET /locations):** Array of all locations with bottle counts

---

### Validation Rules

- `location_name`: Required; must not be blank or whitespace-only; max 100 characters.
- `location_name` uniqueness: New names and renamed names must be unique among all existing location names, case-insensitive comparison (e.g., "wine fridge" and "Wine Fridge" are treated as the same).
- **No maximum limit on location count** in v1.
- Storage location assigned to wine (`storage_location_id`): Must reference an existing, non-deleted location. Validated at wine save time (see F00 validation).
- Delete confirmation: Always required; system must show wine count affected before user can confirm.

---

### Error States

| Scenario | HTTP Status | Error Code | User Message |
|----------|-------------|------------|-------------|
| Blank location name | 422 | VALIDATION_ERROR | "Location name is required." |
| Duplicate location name | 422 | DUPLICATE_LOCATION | "A location with that name already exists." |
| Location name too long | 422 | VALIDATION_ERROR | "Location name must be 100 characters or fewer." |
| Location not found | 404 | LOCATION_NOT_FOUND | "Storage location not found." |
| Delete without confirmation | — | — | Action blocked; confirmation modal required |
| Wine references deleted location | — | — | Wine `location_unknown` flag set; warning displayed on wine record |

---

### API Surface (this feature)

See `Y1-api.md §F02 — Storage Locations` for full request/response schemas.

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/v1/locations` | List all storage locations with bottle counts |
| POST | `/api/v1/locations` | Create a new storage location |
| PUT | `/api/v1/locations/:location_id` | Rename a storage location |
| DELETE | `/api/v1/locations/:location_id` | Delete a location; flag affected wines |

---

### Schema Surface (this feature)

Uses tables: `storage_locations`, `wines` (FK `storage_location_id`, flag `location_unknown`) — see `Y0-schema.md §StorageLocations` for full DDL.

**Key columns on `storage_locations`:** `location_id` (PK), `location_name`, `created_at`, `updated_at`.
**Key columns on `wines` (updated by this feature):** `storage_location_id` (FK, nullable after delete), `location_unknown` (boolean).

---
