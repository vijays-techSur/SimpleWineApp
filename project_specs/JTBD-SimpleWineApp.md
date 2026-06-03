# Jobs-to-be-Done Document
## SimpleWineApp — Personal Wine Collection Manager

| Field | Value |
|-------|-------|
| **Product** | SimpleWineApp v1.0 MVP |
| **Date** | 2026-06-03 |
| **Author** | Pivota Spec JTBD Generator |
| **Related Personas** | `project_specs/PERSONAS-SimpleWineApp.md` |
| **Related PRD** | `project_specs/PRD-SimpleWineApp.md` |
| **Status** | Draft |

---

## JTBD Summary Table

| JTBD-ID | Persona | Job Statement (abbreviated) | Priority |
|---------|---------|------------------------------|----------|
| JTBD-01.1 | PER-01 Marcus — Casual Collector | Instantly know what I own so I never buy a duplicate | P0 |
| JTBD-01.2 | PER-01 Marcus — Casual Collector | Pick something good to drink tonight without a physical search | P0 |
| JTBD-01.3 | PER-01 Marcus — Casual Collector | Log a new bottle immediately after purchase before I forget | P0 |
| JTBD-02.1 | PER-02 Diane — Enthusiast | Capture tasting impressions while the memory is fresh | P1 |
| JTBD-02.2 | PER-02 Diane — Enthusiast | Know which bottles have entered their drinking window without manual calculation | P1 |
| JTBD-02.3 | PER-02 Diane — Enthusiast | Replace my spreadsheet with a single, searchable system | P0 |
| JTBD-03.1 | PER-03 Priya — Home Entertainer | Find the right bottle for tonight's occasion before guests arrive | P0 |
| JTBD-03.2 | PER-03 Priya — Home Entertainer | Keep my inventory accurate after each event without extra effort | P0 |
| JTBD-03.3 | PER-03 Priya — Home Entertainer | Remember what I served at past gatherings to avoid repeating with the same guests | P1 |
| JTBD-04.1 | PER-04 Richard — Serious Collector | Know exactly where every bottle is stored across all locations | P0 |
| JTBD-04.2 | PER-04 Richard — Serious Collector | Track drinking-window readiness across hundreds of bottles without manual calculation | P0 |
| JTBD-04.3 | PER-04 Richard — Serious Collector | See a complete picture of my collection's composition at a glance | P1 |

---

## PER-01: Marcus T. — Casual Collector

### JTBD-01.1: Know What I Own Before Buying

**Job Statement:**
When I am at a wine shop and considering a purchase, I want to check what I already have without calling home or relying on a stale note, so I can avoid buying duplicates and make a confident, informed purchase.

**Current Alternatives:**
- Checks a partially complete note on his phone — almost always out of date
- Calls home or texts a household member to check the fridge physically
- Buys the bottle anyway and risks a duplicate

**Hiring Criteria:**
- Shows the full collection list in under 3 seconds on mobile
- Supports text search by wine name or producer with results as he types
- Does not require a login step each time he opens the app

**Success Measure:** Zero accidental duplicate purchases in the 30 days following adoption.

**Related Features:** F0, F3
**Priority:** P0

---

### JTBD-01.2: Pick Something to Drink Tonight

**Job Statement:**
When I want wine with dinner and I am standing in front of the fridge, I want to see which of my bottles are ready to drink right now without reading every label, so I can make a quick, good decision and enjoy the evening.

**Current Alternatives:**
- Physically reads labels in the fridge, guessing at readiness
- Defaults to whatever is most visible or most recognizable
- Asks someone else to pick or skips wine entirely

**Hiring Criteria:**
- Shows a "Drink Now" list on the home screen with no extra navigation
- Allows filtering by wine type (e.g., Red, Sparkling) in 2–3 taps
- Loads the filtered result in under 5 seconds on a mid-range phone

**Success Measure:** Marcus can identify a ready-to-drink wine matching a desired type in under 60 seconds from app open.

**Related Features:** F3, F5, F6
**Priority:** P0

---

### JTBD-01.3: Log a New Bottle Before I Forget

**Job Statement:**
When I return from a wine shop or receive a bottle as a gift, I want to add it to my collection immediately — right there in the car or at the door — so I can keep my inventory accurate without saving it for later (which never happens).

**Current Alternatives:**
- Intends to update his phone note later and rarely does
- Takes a photo of the label as a reminder — the photo is never transcribed
- Simply skips recording and the collection stays incomplete

**Hiring Criteria:**
- New wine record can be completed in under 60 seconds with only 4–5 required fields
- Add flow works fully on mobile with one hand
- Optional fields are clearly optional — no friction to skip them

**Success Measure:** Marcus's collection list is accurate enough that he abandons his parallel phone note within 30 days of adoption.

**Related Features:** F0, F1
**Priority:** P0

---

## PER-02: Diane L. — Enthusiast

### JTBD-02.1: Capture Tasting Impressions While Fresh

**Job Statement:**
When I open a bottle and form an opinion about it, I want to record my impressions, rating, and occasion context immediately — before the experience fades — so I can build a searchable preference record I can actually act on in the future.

**Current Alternatives:**
- Writes in a paper journal — legible but not searchable
- Uses a voice memo she never transcribes
- Relies on memory, which degrades and is inconsistent across producers

**Hiring Criteria:**
- Tasting note entry form is reachable within 2 taps of opening a bottle record
- Supports free-text fields for aroma, palate, and finish plus a star rating
- Multiple dated tasting notes allowed per wine record

**Success Measure:** Diane can log a full tasting note including rating within 2 minutes on mobile; tasting notes are searchable by producer and grape within the app.

**Related Features:** F4, F1
**Priority:** P1

---

### JTBD-02.2: Know Which Bottles Are Ready Without Calculating

**Job Statement:**
When I want to decide which bottles to open this month, I want to see an automatically calculated readiness status across my entire collection — without cross-referencing vintage charts or doing mental math — so I can drink each wine at its best and stop missing drinking windows.

**Current Alternatives:**
- Keeps a separate note reminding her which vintages are entering their window
- Reviews her spreadsheet annually and manually flags rows
- Occasionally misses a window and opens a bottle past its peak

**Hiring Criteria:**
- Every wine with a drinking window set shows a clear, automatically calculated readiness badge (Drink Now / Approaching Peak / Hold / Past Window)
- Readiness status is visible on the wine list card without opening individual records
- Collection can be filtered to show only "Drink Now" wines across all regions and types

**Success Measure:** Diane identifies all wines entering their drinking window in a single filter interaction taking under 15 seconds; zero wines opened past their window due to a missed tracking signal.

**Related Features:** F5, F6, F3
**Priority:** P1

---

### JTBD-02.3: Replace the Spreadsheet With One Complete System

**Job Statement:**
When I manage my collection across inventory, tasting history, and drinking window notes, I want a single tool that holds everything in one structured, searchable place — so I can stop maintaining a spreadsheet and a handwritten journal simultaneously and trust one source of truth.

**Current Alternatives:**
- Maintains a spreadsheet for inventory counts and a paper journal for tasting notes
- The two systems drift out of sync — quantity counts are inaccurate and tasting history is incomplete
- Reconciles manually every few weeks, which takes 30+ minutes

**Hiring Criteria:**
- Stores wine identity, quantity, storage location, drinking window, and tasting notes per record
- Quantity and tasting history are always in sync — a consumed event links to a tasting note
- Collection is searchable by producer, grape, region, and rating without exporting to a spreadsheet

**Success Measure:** Diane retires her spreadsheet within 30 days of adoption; collection inventory count in the app matches physical cellar count within ±2 bottles.

**Related Features:** F0, F1, F2, F4
**Priority:** P0

---

## PER-03: Priya S. — Home Entertainer

### JTBD-03.1: Find the Right Bottle for Tonight Before Guests Arrive

**Job Statement:**
When I am preparing for a dinner party or gathering, I want to filter my collection by wine type and readiness status in a few taps — so I can identify the best candidates for the occasion in under a minute without walking to the fridge or reading labels.

**Current Alternatives:**
- Physically walks through the wine fridge and kitchen rack, reading labels
- Defaults to a known safe pick rather than risk a forgotten better bottle
- Asks a household member to check, adding coordination overhead

**Hiring Criteria:**
- Filter by wine type (e.g., Sparkling, Red) reachable in ≤ 3 taps from the home screen
- Filter by readiness status (Drink Now) combinable with wine type in a single interaction
- Results render within 2 seconds on mobile

**Success Measure:** Priya can reach a filtered list of Sparkling, Drink Now wines in ≤ 3 taps and under 30 seconds; she opens the app before every gathering instead of doing a physical shelf walk within 30 days of adoption.

**Related Features:** F3, F5, F6
**Priority:** P0

---

### JTBD-03.2: Keep Inventory Accurate After Every Event

**Job Statement:**
When guests leave and bottles have been consumed at a gathering, I want to quickly mark those bottles as consumed — optionally adding a brief occasion note — so my inventory stays accurate and I know exactly what I have left before the next event.

**Current Alternatives:**
- Intends to update the count later but forgets, causing inventory drift
- Physically checks the fridge before the next event and counts what remains
- Maintains a separate mental note of what was served, which is unreliable

**Hiring Criteria:**
- Marking a bottle as consumed takes ≤ 3 taps from the wine list
- Occasion and guest note fields are available but optional — zero friction to skip
- Updated quantity is reflected immediately on the wine list and dashboard

**Success Measure:** Priya's collection quantity count stays within ±1 bottle of the physical cellar for 30 consecutive days of use.

**Related Features:** F1, F4
**Priority:** P0

---

### JTBD-03.3: Remember What I Served at Past Gatherings

**Job Statement:**
When a guest I have hosted before is joining an upcoming dinner, I want to see what I served them previously — without relying on memory — so I can avoid repeating the same wine and make a more thoughtful hosting choice.

**Current Alternatives:**
- Relies entirely on recollection — unreliable after more than one or two visits
- Checks a mental shortlist of "safe" wines she rotates, missing variety
- Has no structured way to retrieve occasion or guest context from past bottle events

**Hiring Criteria:**
- Tasting note entry includes an optional Occasion field and optional Guest Feedback field
- Past tasting notes are listed chronologically on the wine detail view and searchable by occasion text
- Occasion notes are visible without opening a separate journal or document

**Success Measure:** Priya can retrieve the occasion and guest context for at least one past gathering via the tasting note history within 30 seconds of opening a wine record.

**Related Features:** F4, F1
**Priority:** P1

---

## PER-04: Richard A. — Serious Collector

### JTBD-04.1: Know Exactly Where Every Bottle Is Stored

**Job Statement:**
When I want to retrieve a specific bottle from my cellar — or when I need to confirm what is in off-site storage — I want to look up a wine's named storage location immediately, without walking every location or consulting a separate paper log, so I can retrieve the right bottle efficiently and confidently.

**Current Alternatives:**
- Maintains a printed paper log kept physically in the cellar — not accessible remotely
- Knows "roughly" which area cases are in but has no structured location map
- Off-site storage is essentially invisible — requires a separate document check

**Hiring Criteria:**
- Every wine record has a required, user-defined named storage location (e.g., "Basement Cellar — Rack B," "Off-Site Climate Storage")
- Wine list can be filtered by storage location to show only wines in a specific physical space
- Location is displayed prominently on both the wine list card and the detail view

**Success Measure:** Richard can filter the wine list to a specific named storage location and retrieve the complete list of wines stored there in under 10 seconds; every bottle has an assigned, accurate storage location within 60 days of adoption.

**Related Features:** F0, F2, F3
**Priority:** P0

---

### JTBD-04.2: Track Drinking-Window Readiness Across the Entire Collection

**Job Statement:**
When I manage hundreds of bottles across multiple vintages and producers, I want an automatically calculated readiness status for every wine — updated each time I open the app — so I can identify bottles entering their peak window before I miss it, especially for high-value bottles where a mistake is a real financial loss.

**Current Alternatives:**
- Marks promising vintages in a paper notebook and reviews it annually
- Calculates readiness mentally from vintage data — error-prone at scale
- Missed a drinking window on a $300 bottle because the manual review cycle was too long

**Hiring Criteria:**
- Readiness status (Drink Now / Approaching Peak / Hold / Past Window) auto-calculated from start and end year and current date — no manual input required
- Collection can be filtered to show all "Drink Now" and "Approaching Peak" wines across all locations simultaneously
- Readiness status recalculates on each app load with no manual refresh

**Success Measure:** Richard identifies all wines entering their drinking window in a single filter interaction; zero high-value bottles (≥ $100) are opened past their window due to a missed tracking signal within 90 days of adoption.

**Related Features:** F5, F3, F6
**Priority:** P0

---

### JTBD-04.3: See a Complete Overview of My Collection's Composition

**Job Statement:**
When I want to understand the shape of my cellar — what fraction is Bordeaux vs. Burgundy, how my bottles are distributed across vintages, or how many are currently ready to drink — I want a visual summary I can read in 30 seconds, so I can make informed buying decisions and stop counting rows in a spreadsheet.

**Current Alternatives:**
- Manually counts rows in the spreadsheet by region and type — takes 15–20 minutes
- Has no visual breakdown; collection composition is a mental approximation
- Cannot quickly answer "how many ready-to-drink bottles do I have?" without filtering manually

**Hiring Criteria:**
- Dashboard displays total bottle count, unique wine count, and Drink Now / Approaching Peak counts in a visible summary bar
- Collection breakdown by wine type, region, and vintage decade is available without additional navigation
- Dashboard cards link directly to the filtered wine list for each segment

**Success Measure:** Richard can answer "how many bottles are currently Drink Now, and what is my top region?" within 30 seconds of opening the app; he retires his manual spreadsheet composition review within 60 days of adoption.

**Related Features:** F6, F5, F3
**Priority:** P1

---

## Outcome-to-Feature Traceability

| JTBD-ID | Related Features | Expected Outcome |
|---------|-----------------|------------------|
| JTBD-01.1 | F0, F3 | Casual collector eliminates duplicate purchases; collection list becomes his primary reference before a wine shop visit |
| JTBD-01.2 | F3, F5, F6 | Casual collector selects a ready-to-drink wine by type in under 60 seconds from the dashboard |
| JTBD-01.3 | F0, F1 | Casual collector adds a new bottle in under 60 seconds on mobile; parallel phone note is abandoned within 30 days |
| JTBD-02.1 | F4, F1 | Enthusiast builds a searchable preference record; tasting history replaces paper journal |
| JTBD-02.2 | F5, F6, F3 | Enthusiast identifies all Drink Now wines without manual calculation; drinking window misses eliminated |
| JTBD-02.3 | F0, F1, F2, F4 | Enthusiast retires spreadsheet within 30 days; all collection data held in one searchable system |
| JTBD-03.1 | F3, F5, F6 | Home entertainer reaches a filtered Sparkling + Drink Now list in ≤ 3 taps; physical shelf walk replaced by app |
| JTBD-03.2 | F1, F4 | Home entertainer logs consumed bottles after events; inventory stays accurate within ±1 bottle |
| JTBD-03.3 | F4, F1 | Home entertainer retrieves past occasion and guest context from tasting note history within 30 seconds |
| JTBD-04.1 | F0, F2, F3 | Serious collector assigns every bottle a named location; off-site storage becomes visible; location filter returns results in ≤ 10 seconds |
| JTBD-04.2 | F5, F3, F6 | Serious collector monitors all drinking-window readiness in a single filter; zero high-value bottles opened past peak |
| JTBD-04.3 | F6, F5, F3 | Serious collector reads full collection composition — by type, region, vintage, readiness — in under 30 seconds; spreadsheet composition review retired |

---

## NaC Preview

Natural Acceptance Criteria candidates for downstream refinement in STORY-MAP and acceptance testing.

| JTBD-ID | Outcome | Candidate Natural Acceptance Criteria |
|---------|---------|---------------------------------------|
| JTBD-01.1 | No duplicate purchases | Given Marcus searches for a wine name he already owns, when he types the name into the search bar, then the matching record appears in results within 2 seconds with current quantity displayed |
| JTBD-01.2 | Drink Now selection in < 60 sec | Given Marcus is on the home screen, when he taps the Drink Now shelf and applies a wine-type filter, then a filtered list of ready-to-drink wines of the selected type renders within 5 seconds |
| JTBD-01.3 | New bottle added in ≤ 60 sec | Given Marcus opens the Add Wine form on mobile, when he completes only the required fields (name, producer, vintage, type, quantity, location), then the record is saved and visible in his list in under 60 seconds from form open |
| JTBD-02.1 | Tasting note logged in ≤ 2 min | Given Diane opens a wine's detail view, when she taps "Add Tasting Note" and completes the rating and at least one free-text field, then the note is saved and appears in chronological tasting history in under 2 minutes |
| JTBD-02.2 | All Drink Now wines visible in ≤ 15 sec | Given Diane applies the "Drink Now" readiness filter, when the filter is activated, then all wines with a drinking window that includes the current year are shown and no wines outside the window appear |
| JTBD-02.3 | Single source of truth | Given Diane has logged inventory, tasting notes, and drinking windows in the app, when she searches for a wine by producer, then the result shows quantity, readiness status, and most recent tasting note rating in a single view |
| JTBD-03.1 | Filtered list in ≤ 3 taps | Given Priya is on the home screen, when she selects a wine type and the "Drink Now" readiness status, then a filtered wine list matching both criteria appears within 3 taps and renders in under 5 seconds |
| JTBD-03.2 | Inventory accurate post-event | Given Priya marks a consumed bottle after a gathering, when she increments the consumed event and optionally adds an occasion note, then the wine's quantity decreases by one and the updated count is immediately visible on the wine list |
| JTBD-03.3 | Past occasion retrievable | Given Priya opens a wine she has served previously, when she views the tasting note history, then at least one note with an Occasion field value is listed with date and content visible without additional navigation |
| JTBD-04.1 | Location filter in ≤ 10 sec | Given Richard filters the wine list by a named storage location (e.g., "Basement Cellar"), when the filter is applied, then only wines assigned to that location are shown and the result renders in under 10 seconds for a 500-record collection |
| JTBD-04.2 | Readiness auto-calculated | Given Richard opens the app, when the wine list loads, then each wine with a drinking window start and end year displays an auto-calculated readiness badge (Drink Now / Hold / Approaching Peak / Past Window) without any manual action |
| JTBD-04.3 | Collection overview in ≤ 30 sec | Given Richard is on the dashboard, when he views the collection breakdown section, then total bottle count, Drink Now count, top 5 regions by count, wine-type distribution, and vintage decade breakdown are all visible without additional navigation |

---

*JTBD generated by Pivota Spec JTBD Generator · SimpleWineApp v1.0 MVP · 2026-06-03*
