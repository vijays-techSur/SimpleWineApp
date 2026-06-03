---

## Y2: Cross-Feature Error Catalog

**Scope:** All error scenarios across F00–F06, consolidated with HTTP status codes, error codes, user-facing messages, and developer notes.

---

### Error Response Format

All API errors use a consistent JSON envelope:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Wine name is required.",
    "field": "wine_name",
    "details": []
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `code` | string | Machine-readable error code (UPPER_SNAKE_CASE) |
| `message` | string | Human-readable error message for display or logging |
| `field` | string | (Optional) The specific input field that caused the error |
| `details` | array | (Optional) Array of sub-errors for multi-field validation failures |

**Multi-field validation response example:**

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "One or more fields failed validation.",
    "field": null,
    "details": [
      { "field": "wine_name", "message": "Wine name is required." },
      { "field": "vintage_year", "message": "Vintage must be between 1900 and 2027." }
    ]
  }
}
```

---

### HTTP Status Code Summary

| Status | Meaning | When Used |
|--------|---------|-----------|
| 200 OK | Success (read / update) | GET, PUT, PATCH, DELETE with body |
| 201 Created | Resource created | POST |
| 204 No Content | Success, no body | DELETE |
| 400 Bad Request | Malformed request (e.g., invalid JSON, wrong content-type) | Any |
| 404 Not Found | Resource does not exist | Any by-ID endpoint |
| 409 Conflict | Duplicate / uniqueness violation | POST to locations |
| 422 Unprocessable Entity | Business rule / validation failure | Any write |
| 500 Internal Server Error | Unexpected server error | Any |

---

### F00 — Wine Inventory Errors

| Error Code | HTTP | Field | Message | Notes |
|-----------|------|-------|---------|-------|
| `WINE_NOT_FOUND` | 404 | — | "Wine record not found." | wine_id does not exist |
| `VALIDATION_ERROR` | 422 | `wine_name` | "Wine name is required." | null or empty |
| `VALIDATION_ERROR` | 422 | `producer` | "Producer is required." | null or empty |
| `VALIDATION_ERROR` | 422 | `vintage_year` | "Vintage must be between 1900 and [current+1]." | out of range or non-integer |
| `VALIDATION_ERROR` | 422 | `wine_type` | "Wine type must be one of: Red, White, Rosé, Sparkling, Dessert, Fortified." | invalid enum |
| `VALIDATION_ERROR` | 422 | `quantity` | "Quantity must be at least 1." | < 1 or non-integer |
| `VALIDATION_ERROR` | 422 | `storage_location_id` | "Storage location is required." | null |
| `INVALID_REFERENCE` | 422 | `storage_location_id` | "The selected storage location no longer exists. Please choose another." | references deleted location |
| `VALIDATION_ERROR` | 422 | `drink_window_start` | "Drinking window year must be between 1900 and 2200." | out of range |
| `VALIDATION_ERROR` | 422 | `drink_window_end` | "Drinking window year must be between 1900 and 2200." | out of range |
| `VALIDATION_ERROR` | 422 | `drink_window_start` | "Drink by start year must be before or equal to end year." | start > end |
| `VALIDATION_ERROR` | 422 | `purchase_date` | "Purchase date cannot be in the future." | date > today |
| `VALIDATION_ERROR` | 422 | `notes` | "Notes must be 5000 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `bottle_size` | "Bottle size must be one of: 375ml, 750ml, 1.5L, 3L." | invalid enum |

---

### F01 — Bottle Event Errors

| Error Code | HTTP | Field | Message | Notes |
|-----------|------|-------|---------|-------|
| `QUANTITY_EMPTY` | 422 | — | "No bottles remain in the cellar for this wine." | CONSUMED or GIFTED when quantity = 0 |
| `VALIDATION_ERROR` | 422 | `event_type` | "Event type must be Consumed, Gifted, or Opened." | invalid enum |
| `VALIDATION_ERROR` | 422 | `event_date` | "Event date is required." | null |
| `VALIDATION_ERROR` | 422 | `event_date` | "Event date cannot be in the future." | date > today |
| `VALIDATION_ERROR` | 422 | `notes` | "Notes must be 500 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `recipient` | "Recipient must be 200 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `adjustment` | "Adjustment must be +1 or -1." | invalid PATCH value |
| `QUANTITY_FLOOR` | 422 | `adjustment` | "Quantity cannot go below zero." | decrement at 0 |
| `WINE_NOT_FOUND` | 404 | — | "Wine record not found." | wine_id does not exist |

---

### F02 — Storage Location Errors

| Error Code | HTTP | Field | Message | Notes |
|-----------|------|-------|---------|-------|
| `VALIDATION_ERROR` | 422 | `location_name` | "Location name is required." | null or empty |
| `VALIDATION_ERROR` | 422 | `location_name` | "Location name must be 100 characters or fewer." | exceeds max |
| `DUPLICATE_LOCATION` | 409 | `location_name` | "A location with that name already exists." | case-insensitive dup check |
| `LOCATION_NOT_FOUND` | 404 | — | "Storage location not found." | location_id does not exist |

---

### F04 — Tasting Note Errors

| Error Code | HTTP | Field | Message | Notes |
|-----------|------|-------|---------|-------|
| `NOTE_NOT_FOUND` | 404 | — | "Tasting note not found." | note_id does not exist |
| `VALIDATION_ERROR` | 422 | `date_tasted` | "Tasting date is required." | null |
| `VALIDATION_ERROR` | 422 | `date_tasted` | "Tasting date cannot be in the future." | date > today |
| `VALIDATION_ERROR` | 422 | `personal_rating` | "Rating must be between 1 and 5." | 5-star out of range |
| `VALIDATION_ERROR` | 422 | `personal_rating` | "Rating must be between 1 and 100." | 100-point out of range |
| `VALIDATION_ERROR` | 422 | `would_buy_again` | "Would-buy-again must be Yes, No, or Maybe." | invalid enum |
| `INVALID_REFERENCE` | 422 | `bottle_event_id` | "Linked bottle event not found or is not a Consumed event." | wrong type or missing |
| `VALIDATION_ERROR` | 422 | `appearance` | "Appearance must be 500 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `aroma` | "Aroma must be 500 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `flavor` | "Flavor must be 1000 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `finish` | "Finish must be 500 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `guest_feedback` | "Guest feedback must be 500 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `occasion` | "Occasion must be 200 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `rating_scale` | "Rating scale must be STARS_5 or POINTS_100." | invalid settings value |

---

### F03 — Search & Filter Errors

| Error Code | HTTP | Field | Message | Notes |
|-----------|------|-------|---------|-------|
| `VALIDATION_ERROR` | 422 | `vintage_from` | "Start year must be before or equal to end year." | vintage_from > vintage_to |
| `VALIDATION_ERROR` | 422 | `rating_min` | "Min rating must be less than or equal to max rating." | rating_min > rating_max |

> Filter errors in the UI are shown as inline messages on the filter panel. API filter parameter errors return `422`.

---

### Global / Infrastructure Errors

| Error Code | HTTP | Message | Notes |
|-----------|------|---------|-------|
| `INTERNAL_SERVER_ERROR` | 500 | "An unexpected error occurred. Please try again." | Uncaught server exceptions |
| `BAD_REQUEST` | 400 | "Invalid request format. Expected JSON." | Malformed JSON or wrong Content-Type |
| `METHOD_NOT_ALLOWED` | 405 | "HTTP method not allowed for this endpoint." | Wrong HTTP verb |
| `NOT_FOUND` | 404 | "Endpoint not found." | Unmapped route |

---

### UI Error Display Guidelines

| Severity | UI Pattern |
|----------|-----------|
| Field validation error | Inline red text beneath the field; field border changes to error color; `aria-describedby` links input to error text |
| Form-level error | Error summary at the top of the form listing all failed fields; links to each field |
| Destructive action confirmation | Modal dialog with explicit confirmation required before proceeding |
| Toast notification (success) | Non-blocking toast at bottom of screen; auto-dismisses after 3 seconds |
| Toast notification (error) | Non-blocking toast with persistent close button; does not auto-dismiss |
| Empty state (no data) | Centered illustration + message + primary action CTA |
| Data load failure | Card-level error state with "Pull to refresh" or retry button |

---
