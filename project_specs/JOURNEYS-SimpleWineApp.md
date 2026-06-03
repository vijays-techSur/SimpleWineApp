# User Journey Maps
## SimpleWineApp — Personal Wine Collection Manager

| Field | Value |
|-------|-------|
| **Product** | SimpleWineApp v1.0 MVP |
| **Date** | 2026-06-03 |
| **Author** | Pivota Spec Journeys Generator |
| **Related Personas** | `project_specs/PERSONAS-SimpleWineApp.md` |
| **Related JTBD** | `project_specs/JTBD-SimpleWineApp.md` |
| **Related PRD** | `project_specs/PRD-SimpleWineApp.md` |
| **Status** | Draft |

---

## Journey Index

| JRN-ID | Persona | Scenario | Key JTBD | Stages |
|--------|---------|----------|----------|--------|
| JRN-01.1 | PER-01 Marcus — Casual Collector | Add a Bottle: logging a new purchase on the way home | JTBD-01.3 | 5 |
| JRN-01.2 | PER-01 Marcus — Casual Collector | Find a Bottle: checking what he has at the wine shop | JTBD-01.1 | 5 |
| JRN-01.3 | PER-01 Marcus — Casual Collector | Choose a Wine: picking something for tonight's dinner | JTBD-01.2 | 5 |
| JRN-02.1 | PER-02 Diane — Enthusiast | Open a Bottle: consuming a wine and logging tasting notes | JTBD-02.1 | 6 |
| JRN-02.2 | PER-02 Diane — Enthusiast | Review Collection: understanding readiness and composition | JTBD-02.2, JTBD-02.3 | 5 |
| JRN-03.1 | PER-03 Priya — Home Entertainer | Choose a Wine: finding the right bottle before guests arrive | JTBD-03.1 | 5 |
| JRN-03.2 | PER-03 Priya — Home Entertainer | Open a Bottle: marking consumed and logging occasion context | JTBD-03.2, JTBD-03.3 | 5 |
| JRN-04.1 | PER-04 Richard — Serious Collector | Add a Bottle: entering a case purchase with full detail | JTBD-04.1 | 6 |
| JRN-04.2 | PER-04 Richard — Serious Collector | Review Collection: monitoring readiness across the full cellar | JTBD-04.2, JTBD-04.3 | 5 |

---

## PER-01: Marcus T. — Casual Collector

---

### JRN-01.1: Add a Bottle — Logging a New Purchase on the Way Home

**Persona:** PER-01 (Marcus T.)
**Scenario:** Marcus just left a wine shop and bought two bottles he is excited about. He is sitting in his car in the parking lot, determined to log them now before he gets home and forgets. He opens the app on his phone and wants to get both bottles added in under two minutes — combined — with minimum required fields so he can get on with his day.
**Related Jobs:** JTBD-01.3

### Journey Stages

| Stage | Action | Touchpoint | Thinking | Feeling | Pain Point | Opportunity |
|-------|--------|------------|----------|---------|------------|-------------|
| **Trigger** | Leaves the wine shop with two bottles, sits in car, opens app | App home screen (F6 Dashboard) | "If I don't do this now I'll forget by morning like every other time" | Motivated but slightly rushed | His current phone note is stale — app has to be faster or he will fall back to the note | Quick-entry FAB button visible immediately on home screen; no hunting |
| **Initiate** | Taps the "+" FAB to open the Add Wine form | Add Wine form (F0) | "Okay, how many fields is this going to make me fill in?" | Cautiously optimistic | If the form looks long, he will abandon it | Form opens showing only required fields; optional fields collapsed or clearly de-emphasized |
| **Enter Required Fields** | Types wine name, producer, vintage year, selects wine type; sets quantity to 1; picks storage location from dropdown | Add Wine form — required fields (F0, F2) | "Wine Fridge — that's where it's going. Good, that was already in the list." | Focused, moving quickly | Typing on mobile is slow; mistyping a name is easy | Large touch targets, autocomplete on producer name, location pre-selected to most recently used |
| **Save Record** | Taps "Save" or "Add Wine" button | Confirmation / wine list (F0, F1) | "Done. One down. Now the second bottle." | Relieved — one bottle saved | No clear confirmation that save succeeded; wonders if he should check the list | Brief success toast ("Château Margaux added to Wine Fridge") then auto-returns to Add form for next bottle |
| **Repeat & Exit** | Adds second bottle with same flow; closes app | App home screen (F6 Dashboard) | "Both in. Collection is actually up to date for once." | Satisfied, slightly surprised it was that easy | Second bottle takes as long as the first — no shortcut for similar entries | "Add another" shortcut that pre-fills storage location from previous entry; dashboard count visibly updated |

### Key Moments
- **Decision Point:** Initiate stage — Marcus evaluates the form complexity in the first 3 seconds; if it looks like work, he closes the app and falls back to his phone note.
- **Risk of Abandonment:** Enter Required Fields — any required field he does not understand (e.g., "Appellation" as a required label) triggers abandonment.
- **Delight Opportunity:** Save Record — a warm, affirming confirmation message ("Added! Your cellar is up to date.") turns a chore into a small win.

### Success Outcome
Marcus adds both bottles in under 2 minutes total; his collection list reflects the purchase before he starts the car. Within 30 days he abandons his parallel phone note entirely. (JTBD-01.3 success measure)

### Feature Touchpoints

| Stage | Features |
|-------|----------|
| Trigger | F6 (Dashboard / home screen) |
| Initiate | F0 (Wine Inventory CRUD — Add form) |
| Enter Required Fields | F0 (CRUD fields), F2 (Storage Location — location picker) |
| Save Record | F0 (Save action), F1 (Quantity initialized to 1) |
| Repeat & Exit | F0, F6 (Dashboard — updated count) |

---

### JRN-01.2: Find a Bottle — Checking the Collection at the Wine Shop

**Persona:** PER-01 (Marcus T.)
**Scenario:** Marcus is browsing at a wine shop and sees a Côtes du Rhône he thinks he might already have. He pulls out his phone to check before buying. He needs to know in 15 seconds or less whether the wine (or something close to it) is already in his collection.
**Related Jobs:** JTBD-01.1

### Journey Stages

| Stage | Action | Touchpoint | Thinking | Feeling | Pain Point | Opportunity |
|-------|--------|------------|----------|---------|------------|-------------|
| **Trigger** | Spots a wine in the shop, feels a nagging doubt | Wine shop, phone in hand | "I think I have this one... or something like it. Let me check." | Uncertain, mild anxiety | His old phone note was always wrong — he half-expects the app to be wrong too | Trusted, always-current collection data gives him confidence to check |
| **Open & Search** | Opens app, taps search bar, types producer name or wine name | Search bar (F3) | "Okay, search... typing with one hand while holding a bottle, perfect." | Mildly frustrated (typing) | One-handed mobile typing is awkward; autocomplete may not match his spelling | Real-time as-you-type results; fuzzy matching on producer and wine name |
| **Scan Results** | Scans the resulting wine list for a match | Wine list with search results (F3, F0) | "There it is — I have 2 bottles. Put this one back." | Relieved, confident | Results include too much detail — he needs to see wine name, producer, and quantity at a glance | Compact list card showing name + producer + quantity prominently; readiness badge secondary |
| **Confirm Decision** | Reads his existing record, sees quantity = 2, decides not to buy | Wine list card (F0, F1) | "I'm good. Two is enough for now." | Confident, pleased | Quantity is not visible without opening the detail record | Quantity shown as a bold badge on every list card |
| **Exit** | Pockets phone, puts the bottle back, continues browsing | — | "The app actually knew. Nice." | Satisfied, slightly impressed | — | Reinforces the habit: app is reliable, phone note is retired |

### Key Moments
- **Decision Point:** Scan Results — Marcus decides to trust the app result and not buy; this trust is only possible if the collection is accurate and current.
- **Risk of Abandonment:** Open & Search — if search does not return results within 2 seconds, he gives up and either buys the bottle or skips it.
- **Delight Opportunity:** Confirm Decision — seeing the quantity and location on one screen without drilling in makes the whole check feel effortless.

### Success Outcome
Marcus confirms within 15 seconds whether he owns a wine without opening a second app or calling anyone. Zero accidental duplicate purchases within 30 days of adoption. (JTBD-01.1 success measure)

### Feature Touchpoints

| Stage | Features |
|-------|----------|
| Trigger | — |
| Open & Search | F3 (Search — full-text bar) |
| Scan Results | F3 (results), F0 (wine records), F1 (quantity on card) |
| Confirm Decision | F0, F1 (quantity badge on list card) |
| Exit | — |

---

### JRN-01.3: Choose a Wine — Picking Something for Tonight's Dinner

**Persona:** PER-01 (Marcus T.)
**Scenario:** It is 6:30pm on a Wednesday. Marcus is making pasta for dinner and wants to open a red wine. He does not want to stand in front of the wine fridge reading every label — he wants the app to tell him what is good and ready to drink right now. He needs a recommendation in under 60 seconds.
**Related Jobs:** JTBD-01.2

### Journey Stages

| Stage | Action | Touchpoint | Thinking | Feeling | Pain Point | Opportunity |
|-------|--------|------------|----------|---------|------------|-------------|
| **Trigger** | Finishes cooking prep, wants a bottle of red, opens app | Dashboard (F6) | "Let me just see what's ready. I'm not reading every label tonight." | Relaxed, slightly hungry | Without the app, this defaults to "whatever is in front" — a habit he wants to break | Dashboard "Drink Now" shelf is visible immediately, no navigation required |
| **Browse Drink Now Shelf** | Scrolls the Drink Now shelf on the dashboard | Drink Now shelf (F6, F5) | "Okay, these are all ready... but which ones are red?" | Interested, slightly scanning | Drink Now shelf mixes types — sparkling, white, and red show together | Type badge prominently displayed on each Drink Now card; card color or icon signals wine type |
| **Filter by Type** | Taps wine type filter, selects "Red" | Filter panel / filter chips (F3) | "Two reds ready. That's easy." | Satisfied | Filter requires navigating away from the dashboard — multiple taps | Wine type filter accessible directly from the Drink Now shelf with a horizontal filter row |
| **Select a Bottle** | Taps on one of the two red results; reviews name, vintage, storage location | Wine detail (F0, F2, F5) | "2019 Côtes du Rhône, Wine Fridge — second shelf. Easy." | Confident, decided | Storage location buried in the detail; he wants to know "where is it" immediately | Location shown on detail hero section: large, clear, first visible field after wine name |
| **Retrieve & Enjoy** | Walks to fridge, finds the bottle, opens it | Physical action | "Got it. Good call." | Happy | — | Closing the loop: after consuming, a gentle prompt to mark it consumed keeps inventory current |

### Key Moments
- **Decision Point:** Filter by Type — Marcus filters to narrow an already short list; if the filter is buried, he skips it and picks randomly.
- **Risk of Abandonment:** Browse Drink Now Shelf — if all types are mixed with no way to quickly distinguish red from white, Marcus reverts to the physical shelf walk.
- **Delight Opportunity:** Select a Bottle — having the location ("Wine Fridge — second shelf") displayed immediately removes the last friction point.

### Success Outcome
Marcus identifies a ready-to-drink red wine in under 60 seconds from opening the app. He never walks to the fridge to read labels before choosing. (JTBD-01.2 success measure)

### Feature Touchpoints

| Stage | Features |
|-------|----------|
| Trigger | F6 (Dashboard home screen) |
| Browse Drink Now Shelf | F6 (Drink Now shelf), F5 (readiness status) |
| Filter by Type | F3 (wine type filter chip) |
| Select a Bottle | F0 (wine detail), F2 (storage location), F5 (readiness badge) |
| Retrieve & Enjoy | — |

---

## PER-02: Diane L. — Enthusiast

---

### JRN-02.1: Open a Bottle — Consuming a Wine and Logging Tasting Notes

**Persona:** PER-02 (Diane L.)
**Scenario:** Diane opens a 2015 Burgundy she has been looking forward to. While the wine is in the glass, she wants to record her impressions immediately — aroma, palate, finish, rating — before the experience fades. She also wants to note the occasion. She expects the whole process to take under 2 minutes on her phone, and she wants the note to be searchable later.
**Related Jobs:** JTBD-02.1

### Journey Stages

| Stage | Action | Touchpoint | Thinking | Feeling | Pain Point | Opportunity |
|-------|--------|------------|----------|---------|------------|-------------|
| **Trigger** | Pours the first glass, picks up her phone while waiting for the wine to breathe | App home screen or wine list (F6) | "I need to get this down before I get distracted." | Eager, focused | In her old system, she would reach for the paper journal — muscle memory fight | Quick "Add Tasting Note" entry point from dashboard recently-consumed or prominent search |
| **Locate the Wine** | Searches for "Burgundy 2015" or producer name; finds the record | Search bar + wine detail (F3, F0) | "There it is — Domaine Leflaive, two bottles. I'm opening one now." | Focused | If the wine has a long list of records, scanning to find the right one takes time | Search by producer returns result immediately; wine list card shows vintage prominently |
| **Initiate Open/Consume** | Taps "Open / Consume" button on wine detail; quantity decrements | Wine detail — consume action (F1) | "One bottle consumed. One left." | Methodical | Consume action could feel final — she wants to be sure before tapping | Clear confirmation prompt: "Mark 1 bottle of [Wine Name] as consumed?" with quantity update preview |
| **Add Tasting Note** | Taps "Add Tasting Note" from the post-consume prompt or detail view; fills in aroma, palate, finish, rating (4 stars), occasion ("Friday dinner, testing readiness") | Tasting note form (F4) | "Cherry, tobacco, a little leather on the nose. Not quite at its peak but lovely. Four stars." | In the zone, enjoying the process | Typing detailed notes on mobile is slow; must be able to move field-to-field easily | Large text areas for each field, auto-advance on scroll, voice input supported by OS keyboard |
| **Review & Save** | Reviews the note, taps Save | Tasting note confirmation (F4) | "Saved. This will actually be useful in six months." | Satisfied, pleased | No confirmation the note saved other than returning to the detail view | Display saved note inline on the wine detail immediately; most recent rating now visible on list card |
| **Check Collection State** | Scrolls the wine detail to see updated quantity (1 remaining) and tasting history | Wine detail (F0, F1, F4) | "One bottle left. I should hold it another year." | Reflective | Readiness status and remaining quantity should be visible together — she mentally connects them | Readiness badge adjacent to quantity on the detail view — "1 bottle · Drink Now" in one line |

### Key Moments
- **Decision Point:** Add Tasting Note — Diane decides between thorough and quick note; the form must support both without forcing structure she does not need.
- **Risk of Abandonment:** Locate the Wine — if she cannot find the record in 10 seconds, she falls back to her paper journal.
- **Delight Opportunity:** Review & Save — seeing the note appear immediately in the chronological history confirms the system is working and builds the habit.

### Success Outcome
Diane logs a full tasting note including rating and occasion in under 2 minutes on mobile. Her preference history grows searchable over time, eventually replacing her paper journal. (JTBD-02.1 success measure)

### Feature Touchpoints

| Stage | Features |
|-------|----------|
| Trigger | F6 (Dashboard), F3 (Search) |
| Locate the Wine | F3 (search bar), F0 (wine detail) |
| Initiate Open/Consume | F1 (consume action, quantity decrement) |
| Add Tasting Note | F4 (tasting note form — aroma, palate, finish, rating, occasion) |
| Review & Save | F4 (saved note in tasting history) |
| Check Collection State | F0 (quantity), F1, F5 (readiness badge) |

---

### JRN-02.2: Review Collection — Understanding Readiness and Composition

**Persona:** PER-02 (Diane L.)
**Scenario:** It is a Sunday afternoon and Diane has 20 minutes to review her collection. She wants to know which bottles have entered their drinking window this year, understand the overall shape of her cellar (types, regions), and identify whether she should be buying more in any particular area. This is her monthly check-in — the task that currently takes 30 minutes with a spreadsheet and a paper notebook.
**Related Jobs:** JTBD-02.2, JTBD-02.3

### Journey Stages

| Stage | Action | Touchpoint | Thinking | Feeling | Pain Point | Opportunity |
|-------|--------|------------|----------|---------|------------|-------------|
| **Open Dashboard** | Opens app; lands on dashboard | Dashboard (F6) | "Okay — how many are ready to drink this year? That's my first question." | Purposeful | Dashboard must answer the first question immediately, without clicking | Summary stats bar shows "Drink Now: 14 wines" and "Approaching Peak: 7 wines" above the fold |
| **Check Drink Now Count** | Reads the summary stats bar; taps "Drink Now" count to see the full filtered list | Drink Now filter result (F6 → F3, F5) | "14 ready to drink. That's more than I thought. Let me see what they are." | Pleasantly surprised | Cannot see the full list directly from the count — extra navigation needed | Drink Now count is a tappable link to the pre-filtered wine list |
| **Scan Readiness List** | Scrolls the filtered list of Drink Now wines; notes which are Burgundy vs. other regions | Wine list — filtered (F3, F5, F0) | "Three Burgundies ready now — I should open one this weekend. The Rhône can wait another year." | Engaged, analytical | List is sorted by wine name by default — she wants sort by end year (drink soonest first) | Default sort for Drink Now filter is end year ascending ("Drink Soonest First") |
| **Explore Collection Breakdown** | Navigates back to dashboard; reviews wine type breakdown and top regions chart | Dashboard — collection breakdown (F6) | "Still too Bordeaux-heavy. I should pick up more white Burgundy next trip." | Reflective, strategic | Breakdown is percentage-only with no counts — she wants both "33%" and "48 bottles" | Each breakdown segment shows percentage AND absolute bottle count |
| **Cross-Reference Tasting History** | Searches by producer name; finds wines with high ratings to guide next purchase | Search results with rating filter (F3, F4) | "My 4-star and 5-star ratings are mostly Burgundy. That confirms my instinct." | Confident in her analysis | Rating filter and region filter combined — she does not know if multi-filter is supported | Filter chips combinable: Region + Rating Range simultaneously; active filters shown as dismissible chips |

### Key Moments
- **Decision Point:** Scan Readiness List — Diane decides which bottles to open this month based on end-year proximity; wrong sort order (alphabetical vs. soonest-first) could cause her to miss an expiring window.
- **Risk of Abandonment:** Explore Collection Breakdown — if the breakdown is too simple (type only, no region), she returns to the spreadsheet for the depth she needs.
- **Delight Opportunity:** Open Dashboard — seeing the full Drink Now count at a glance with zero navigation confirms the app delivers what her 30-minute spreadsheet ritual never could.

### Success Outcome
Diane identifies all wines entering their drinking window in a single filter session taking under 15 seconds. She retires her spreadsheet within 30 days; the app is her single source of collection truth. (JTBD-02.2, JTBD-02.3 success measures)

### Feature Touchpoints

| Stage | Features |
|-------|----------|
| Open Dashboard | F6 (Dashboard summary stats bar) |
| Check Drink Now Count | F6 (Drink Now count link), F5, F3 (pre-filtered list) |
| Scan Readiness List | F3 (wine list filter), F5 (readiness badges), F0 (wine records) |
| Explore Collection Breakdown | F6 (collection breakdown by type and region) |
| Cross-Reference Tasting History | F3 (search + rating filter), F4 (tasting note ratings) |

---

## PER-03: Priya S. — Home Entertainer

---

### JRN-03.1: Choose a Wine — Finding the Right Bottle Before Guests Arrive

**Persona:** PER-03 (Priya S.)
**Scenario:** Priya is hosting a dinner party in 45 minutes. She needs to choose two bottles: a sparkling for the aperitivo and a red for the main course. She cannot walk through the fridge right now — she is in the kitchen prepping. She opens the app and expects to find both options in under 90 seconds total.
**Related Jobs:** JTBD-03.1

### Journey Stages

| Stage | Action | Touchpoint | Thinking | Feeling | Pain Point | Opportunity |
|-------|--------|------------|----------|---------|------------|-------------|
| **Trigger** | Puts down the salad bowl, wipes hands, opens app mid-dinner prep | Dashboard (F6) | "I need a sparkling and a red that are ready now. I don't have time to think about this." | Focused, slightly pressured | In her old system, this is a physical walk to the fridge — she cannot do that right now | App is fast: dashboard loads instantly with Drink Now shelf visible |
| **Filter for Sparkling + Drink Now** | Taps filter, selects "Sparkling" and "Drink Now" simultaneously | Filter panel / chips (F3, F5) | "Sparkling, ready now — three options. Perfect." | Relieved | Filter panel requires two separate interactions (type, then readiness) that reset between taps | Type and readiness filters combinable in a single drawer interaction; applied simultaneously |
| **Choose the Sparkling** | Scans three sparkling results; selects the Crémant she remembers guests liked | Wine list — filtered (F3, F0, F5) | "Crémant d'Alsace. That's the one. It's in the Wine Fridge." | Decisive | Cannot see the storage location on the list card — she needs to tap into the detail | Storage location visible on the list card as a secondary line (e.g., "Wine Fridge — Top Shelf") |
| **Switch Filter to Red** | Changes type filter to "Red," keeps Drink Now active | Filter panel / chips (F3, F5) | "Four reds ready. Which one works for the main course?" | Scanning quickly | Changing one filter dimension clears both — she has to reapply readiness | Active filters persist when changing type; only the type chip swaps |
| **Select the Red** | Taps on a 2018 Côtes du Rhône; confirms storage location; sets phone down | Wine detail (F0, F2) | "Done. Both bottles chosen. Under a minute." | Satisfied, pleased | — | Quick confirmation moment: brief haptic or visual feedback signals her selections are locked in |

### Key Moments
- **Decision Point:** Filter for Sparkling + Drink Now — Priya commits to the filter-first approach instead of browsing; if this takes more than 3 taps, she abandons and walks to the fridge.
- **Risk of Abandonment:** Switch Filter to Red — if changing the wine type clears her readiness filter, she loses patience and does not repeat the interaction for the red selection.
- **Delight Opportunity:** Choose the Sparkling — seeing location on the list card means she never needs to open a detail record; the entire selection is done in the list view.

### Success Outcome
Priya reaches a filtered "Sparkling, Drink Now" list in ≤ 3 taps and selects both bottles within 90 seconds. She opens the app before every gathering instead of doing a physical shelf walk within 30 days. (JTBD-03.1 success measure)

### Feature Touchpoints

| Stage | Features |
|-------|----------|
| Trigger | F6 (Dashboard — Drink Now shelf visible) |
| Filter for Sparkling + Drink Now | F3 (filter panel — type + readiness), F5 (readiness status) |
| Choose the Sparkling | F3 (list result), F0 (wine name/detail), F2 (storage location on card) |
| Switch Filter to Red | F3 (filter chips — type swap, readiness persists) |
| Select the Red | F0 (wine detail), F2 (storage location) |

---

### JRN-03.2: Open a Bottle — Marking Consumed and Logging Occasion Context

**Persona:** PER-03 (Priya S.)
**Scenario:** The dinner party is over. Three bottles were opened — two Priya tracked in JRN-03.1 and one additional bottle that was opened spontaneously. It is 11pm and guests just left. Priya wants to update the app in under 5 minutes while the details are still fresh, mark all three bottles as consumed, and add a brief occasion note for the guest record so she remembers what she served when these friends return.
**Related Jobs:** JTBD-03.2, JTBD-03.3

### Journey Stages

| Stage | Action | Touchpoint | Thinking | Feeling | Pain Point | Opportunity |
|-------|--------|------------|----------|---------|------------|-------------|
| **Trigger** | Guests leave; Priya stands in the kitchen with three empty bottles | App home screen (F6) | "Three bottles. I need to log these now or I won't remember tomorrow." | Tired but motivated | Historically she skips this step — the app must make it faster than "I'll do it later" | Drink Now shelf or Recently Added section provides fast jump points to likely wines |
| **Find First Wine** | Searches for the Crémant; opens the record | Search + wine detail (F3, F0) | "Crémant d'Alsace, there it is. One consumed." | Moving efficiently | Having to search for each bottle separately adds up across three bottles | "Recently Selected" or "Recently Viewed" shortcut shows wines accessed in the last session |
| **Mark as Consumed + Add Occasion Note** | Taps "Consume" on the wine detail; quantity decrements; optional prompt appears for tasting note; adds occasion: "Sarah & Tom — anniversary dinner" | Wine detail consume action + tasting note prompt (F1, F4) | "Occasion: 'Sarah and Tom, anniversary dinner.' Done. That took 20 seconds." | Efficient, pleased | Tasting note form is full-featured — Priya just wants a quick occasion field without all the aroma/palate fields | Quick-capture mode on consume prompt: single "Occasion & Guest Note" field + optional rating; full tasting note deferred |
| **Repeat for Remaining Bottles** | Repeats consume + note flow for the red and the spontaneous third bottle | Wine detail × 2 (F1, F4) | "Second one logged. The third bottle was... that Rioja. Where is that record?" | Slightly fatigued | Finding the third bottle requires another search while tired | Post-consume prompt offers "Add Another Consumed Bottle" shortcut to stay in the consume flow |
| **Verify Inventory** | Returns to wine list; scans to confirm three quantities decremented | Wine list (F0, F1) | "Crémant: 1 left. Côtes du Rhône: 0, cellar empty. Rioja: 2 left. That's right." | Relieved, satisfied | "Cellar Empty" wines disappear from the list — she cannot confirm the count without looking at inactive records | Cellar Empty wines shown as de-emphasized rows for 24 hours post-event; confirm counts visible |

### Key Moments
- **Decision Point:** Mark as Consumed + Add Occasion Note — Priya decides how much to fill in; a long form means she skips the note and loses future recall value.
- **Risk of Abandonment:** Repeat for Remaining Bottles — fatigue after a dinner party is real; if the third bottle requires as much effort as the first, she skips it.
- **Delight Opportunity:** Verify Inventory — seeing accurate quantities across all three wines in one list view closes the loop with a satisfying confirmation.

### Success Outcome
Priya marks three bottles consumed in under 5 minutes, each with an occasion note. Collection quantity stays within ±1 bottle of the physical cellar for 30 consecutive days. (JTBD-03.2, JTBD-03.3 success measures)

### Feature Touchpoints

| Stage | Features |
|-------|----------|
| Trigger | F6 (Dashboard — recently viewed / Drink Now shelf) |
| Find First Wine | F3 (search), F0 (wine detail) |
| Mark as Consumed + Add Occasion Note | F1 (consume action, quantity decrement), F4 (occasion + guest note) |
| Repeat for Remaining Bottles | F1, F4 (per bottle) |
| Verify Inventory | F0 (wine list), F1 (quantity displayed) |

---

## PER-04: Richard A. — Serious Collector

---

### JRN-04.1: Add a Bottle — Entering a Case Purchase with Full Detail

**Persona:** PER-04 (Richard A.)
**Scenario:** Richard has just received a delivery of a 12-bottle case of 2018 Barolo from a Piedmont producer he has tracked for years. He is standing at his basement cellar entrance. He wants to add the wine to the app with full metadata — producer, appellation, grape, bottle size, purchase price, drinking window (2026–2040), and storage location ("Basement Cellar — Rack C") — before placing the bottles in the rack. He uses his phone for this first entry step, then will review on laptop later.
**Related Jobs:** JTBD-04.1

### Journey Stages

| Stage | Action | Touchpoint | Thinking | Feeling | Pain Point | Opportunity |
|-------|--------|------------|----------|---------|------------|-------------|
| **Trigger** | Case arrives; Richard opens the app while at the cellar entrance | Dashboard (F6) | "I want this in the system before I stack the bottles, so I know exactly what went where." | Methodical, purposeful | He is used to a spreadsheet where he can tab through every field — the app must match that data completeness | App shows recently added wines on dashboard; reassures him the system is live and accurate |
| **Open Add Wine Form** | Taps "+" FAB; form opens | Add Wine form (F0) | "Let me see if all the fields I need are here — appellation, grape, drinking window, purchase price." | Evaluating carefully | If optional fields are hidden or collapsed, he may not realize they exist | Add form shows all fields in a logical sequence; optional fields clearly marked but visible (not hidden behind toggles) |
| **Enter Required Fields** | Fills name, producer, vintage (2018), type (Red), quantity (12), storage location ("Basement Cellar — Rack C") | Add Wine form — required fields (F0, F2) | "Quantity: 12. Location: Basement Cellar — Rack C. That's new, let me add it." | Confident | "Basement Cellar — Rack C" is a new sub-location he has not created yet; he needs to add it without losing his form progress | "Create new location" available inline in the location picker without navigating away from the form |
| **Enter Optional Fields** | Fills grape (Nebbiolo), country (Italy), region (Piedmont / Barolo DOCG), bottle size (750ml), purchase price ($280/bottle), drinking window start (2026), end (2040) | Add Wine form — optional fields (F0, F5) | "2026 to 2040. That's a 14-year window. App should calculate readiness automatically from this." | Thorough, satisfied | Entering purchase price per bottle vs. per case is ambiguous — is this $280 per bottle or $3,360 per case? | Field label clarifies: "Purchase Price (per bottle)" — no ambiguity |
| **Save and Verify** | Taps Save; wine record appears in list with readiness badge "Hold" (current year before 2026) | Wine list / wine detail (F0, F5) | "Hold — correct. I have 8 years before this enters its window. I'll set a reminder in Phase 2." | Precisely satisfied | No confirmation of which fields were saved; he wants to verify the record is complete | Detail view opens automatically after save, showing all entered fields for verification before returning to list |
| **Confirm Location** | Opens Storage Location view; confirms "Basement Cellar — Rack C" has 12 bottles assigned | Storage location filter result (F2, F3) | "Rack C: 12 bottles — Barolo 2018. Perfect. Now I can stack them." | Fully confident | Storage location overview requires navigating through filter; no dedicated location view in MVP | Filter by location is one tap; result shows all wines in that location with quantities |

### Key Moments
- **Decision Point:** Enter Optional Fields — Richard enters every field; if any is missing, he considers the record incomplete and will not retire his spreadsheet.
- **Risk of Abandonment:** Open Add Wine Form — if the form only shows 4 required fields and hides the rest, Richard will not trust the app for serious collection management.
- **Delight Opportunity:** Save and Verify — automatic "Hold" readiness badge confirms the drinking window was processed correctly without any additional action.

### Success Outcome
Richard adds the full Barolo case record with all fields in under 4 minutes; every bottle has a named, accurate storage location. He filters "Basement Cellar — Rack C" and sees 12 bottles assigned within 10 seconds. (JTBD-04.1 success measure)

### Feature Touchpoints

| Stage | Features |
|-------|----------|
| Trigger | F6 (Dashboard — recently added) |
| Open Add Wine Form | F0 (Add Wine form — all fields visible) |
| Enter Required Fields | F0, F2 (Storage Location — inline create new location) |
| Enter Optional Fields | F0 (optional fields), F5 (drinking window start/end) |
| Save and Verify | F0 (save action), F5 (readiness badge auto-calculated), F1 (quantity = 12) |
| Confirm Location | F2 (location), F3 (filter by location) |

---

### JRN-04.2: Review Collection — Monitoring Readiness Across the Full Cellar

**Persona:** PER-04 (Richard A.)
**Scenario:** Every Sunday morning Richard spends 15–20 minutes reviewing his cellar state. He wants to know which bottles are entering their drinking window this year or next, see the full composition breakdown by region and type, and confirm nothing has slipped past peak unnoticed. He uses his laptop for this weekly review, switching to his phone only if he needs to check the physical cellar.
**Related Jobs:** JTBD-04.2, JTBD-04.3

### Journey Stages

| Stage | Action | Touchpoint | Thinking | Feeling | Pain Point | Opportunity |
|-------|--------|------------|----------|---------|------------|-------------|
| **Open Dashboard on Laptop** | Navigates to app in browser; dashboard loads | Dashboard (F6) | "Total: 487 bottles. Drink Now: 22. Approaching Peak: 31. Good — this is the overview I need." | Oriented, methodical | Summary stats must be at-a-glance; if he has to calculate "Drink Now + Approaching Peak" himself the app is failing | Summary bar shows both Drink Now AND Approaching Peak counts side by side |
| **Filter to Drink Now + Approaching Peak** | Applies readiness filter — selects both "Drink Now" and "Approaching Peak" simultaneously | Filter panel (F3, F5) | "53 bottles entering their window. Let me sort by end year to see what's most urgent." | Focused | Cannot select multiple readiness statuses simultaneously — has to run two separate filters | Readiness filter supports multi-select; both Drink Now and Approaching Peak checkable in one interaction |
| **Sort by End Year, Identify Urgent Bottles** | Sorts the filtered list by Vintage or by Drinking Window End year (ascending) | Wine list — sorted (F3, F0, F5) | "Three Burgundies with an end year of 2027 — I need to open those in the next 18 months. Let me flag them." | Alert, responsible | No way to "flag" or tag a wine for upcoming action — he adds a note to his paper notebook instead | Shortlist or "Watch" flag per wine record; flagged wines surfaced as a separate mini-list on dashboard |
| **Review Collection Breakdown** | Scrolls to collection breakdown section on dashboard | Dashboard — collection breakdown (F6) | "Bordeaux: 38%, Burgundy: 24%, California: 18%, Italy: 14%, Rest: 6%. I am over-indexed in Bordeaux." | Strategically reflective | Breakdown is by wine type only in simplified view; Richard needs breakdown by region AND by vintage decade | Collection breakdown shows: type by count + %, region by count (top 5 or all), vintage decade histogram |
| **Cross-Check Off-Site Storage** | Filters wine list by "Off-Site Climate Storage" location | Wine list — filtered by location (F2, F3) | "Off-site: 24 bottles. Two Bordeaux from 2012 — those are approaching peak. I forgot about those." | Concerned (almost missed) | Off-site storage is invisible without filtering — there is no summary of "what is off-site" on the dashboard | Dashboard includes a "By Location" breakdown showing bottle count per named location — off-site always visible |

### Key Moments
- **Decision Point:** Filter to Drink Now + Approaching Peak — Richard needs both statuses simultaneously; single-status filtering forces two separate sessions and risks one being forgotten.
- **Risk of Abandonment:** Review Collection Breakdown — if the breakdown does not include regional data and vintage decade distribution, Richard keeps his spreadsheet for the composition analysis.
- **Delight Opportunity:** Cross-Check Off-Site Storage — discovering the approaching-peak Bordeaux via location filter prevents a real financial loss; this moment proves the app's value for serious collectors.

### Success Outcome
Richard answers "how many bottles are Drink Now, and what is my top region?" within 30 seconds of opening the app. He identifies approaching-peak wines across all locations in a single session; zero high-value bottles opened past their window due to missed tracking. (JTBD-04.2, JTBD-04.3 success measures)

### Feature Touchpoints

| Stage | Features |
|-------|----------|
| Open Dashboard on Laptop | F6 (Dashboard — summary stats bar: total, Drink Now, Approaching Peak) |
| Filter to Drink Now + Approaching Peak | F3 (readiness filter — multi-select), F5 (readiness status) |
| Sort by End Year, Identify Urgent Bottles | F3 (sort by drinking window end), F0, F5 |
| Review Collection Breakdown | F6 (collection breakdown — type %, region count, vintage decade) |
| Cross-Check Off-Site Storage | F2 (storage location), F3 (filter by location), F6 (by-location summary) |

---

## Cross-Journey Patterns

### CP-01: Location Visibility Is Critical Across All Personas
All four personas need storage location surfaced at the **list card level** — not buried in the detail view. Marcus needs it to retrieve a bottle quickly (JRN-01.3), Priya needs it to avoid a physical walk during dinner prep (JRN-03.1), and Richard needs it to confirm case placement after entry (JRN-04.1). **Opportunity:** Display location as a secondary line on every wine list card, not just the detail view.

### CP-02: Filter Persistence Prevents Rework
In JRN-01.3, JRN-03.1, and JRN-04.2, every persona applies a filter and then wants to **change one dimension without losing the others** (e.g., change type from Sparkling to Red while keeping Drink Now active). If any filter reset wipes all active filters, the persona either repeats the interaction (friction) or abandons the second selection. **Opportunity:** Active filter chips are individually dismissible; changing one filter does not clear others.

### CP-03: Post-Consume Flow Is the Retention Hinge
JRN-01.3, JRN-02.1, JRN-03.2 all converge on the consume event. The moment after a bottle is opened is the highest-value prompt for both **inventory accuracy** (F1) and **tasting note capture** (F4). Personas differ in depth: Marcus wants minimum friction (quantity decrement only), Priya wants a quick occasion field, Diane wants full tasting notes. **Opportunity:** A tiered post-consume prompt — first screen is quick (decrement + optional occasion), second screen is full tasting note — serves all personas without forcing depth on any.

### CP-04: Drink Now Shelf Must Be Typed, Not Just Listed
All three "Choose a Wine" scenarios (JRN-01.3, JRN-03.1, JRN-04.2 review) reveal that personas always want to narrow Drink Now results by wine type. The Drink Now shelf without type filtering is useful but not sufficient for quick decision-making. **Opportunity:** Add horizontal type-filter pills directly on the Drink Now shelf (e.g., All · Red · White · Sparkling) so filtering requires zero navigation away from the dashboard.

### CP-05: Empty / Zero-Quantity Record Handling
After a consuming event (JRN-03.2, JRN-02.1), personas want to **confirm the quantity decremented correctly** without losing visibility of the record. If Cellar Empty wines silently disappear from the list, the confirmation loop is broken and trust erodes. **Opportunity:** Cellar Empty wines remain visible with a de-emphasized style for 24–48 hours post-event, clearly labeled, then optionally archived.

---

## Journey-to-JTBD Traceability

| JRN-ID | Stage | JTBD-ID | Expected Outcome |
|--------|-------|---------|-----------------|
| JRN-01.1 | Initiate | JTBD-01.3 | Add form opens in ≤ 2 taps with required fields prominent |
| JRN-01.1 | Enter Required Fields | JTBD-01.3 | Record saved in ≤ 60 seconds on mobile with 4–5 required fields only |
| JRN-01.1 | Save Record | JTBD-01.3 | Collection list is accurate; parallel phone note abandoned within 30 days |
| JRN-01.2 | Open & Search | JTBD-01.1 | Search results appear within 2 seconds of typing; full-text across name and producer |
| JRN-01.2 | Scan Results | JTBD-01.1 | Quantity visible on list card without opening detail; decision in ≤ 15 seconds |
| JRN-01.2 | Confirm Decision | JTBD-01.1 | Zero accidental duplicate purchases within 30 days of adoption |
| JRN-01.3 | Browse Drink Now Shelf | JTBD-01.2 | Drink Now wines visible on dashboard without any additional navigation |
| JRN-01.3 | Filter by Type | JTBD-01.2 | Type filter reachable in 2–3 taps from home screen; results within 5 seconds |
| JRN-01.3 | Select a Bottle | JTBD-01.2 | Ready-to-drink wine of desired type identified in ≤ 60 seconds from app open |
| JRN-02.1 | Initiate Open/Consume | JTBD-02.1 | Tasting note entry reachable within 2 taps of opening a bottle record |
| JRN-02.1 | Add Tasting Note | JTBD-02.1 | Full tasting note with rating logged in ≤ 2 minutes on mobile |
| JRN-02.1 | Check Collection State | JTBD-02.3 | Quantity, readiness, and tasting note visible in a single detail view |
| JRN-02.2 | Check Drink Now Count | JTBD-02.2 | All wines with a Drink Now status visible via single filter interaction in ≤ 15 seconds |
| JRN-02.2 | Scan Readiness List | JTBD-02.2 | Zero wines opened past their window due to missed tracking signal |
| JRN-02.2 | Explore Collection Breakdown | JTBD-02.3 | Collection breakdown by type, region, vintage decade visible without additional navigation |
| JRN-02.2 | Cross-Reference Tasting History | JTBD-02.3 | Spreadsheet retired within 30 days; single searchable system holds all collection data |
| JRN-03.1 | Filter for Sparkling + Drink Now | JTBD-03.1 | Type + readiness filter reached in ≤ 3 taps from home screen |
| JRN-03.1 | Choose the Sparkling | JTBD-03.1 | Filtered list of Sparkling + Drink Now wines renders in ≤ 30 seconds |
| JRN-03.1 | Switch Filter to Red | JTBD-03.1 | Physical shelf walk replaced by app within 30 days of adoption |
| JRN-03.2 | Mark as Consumed + Add Occasion Note | JTBD-03.2 | Consume action completed in ≤ 3 taps; quantity updates immediately |
| JRN-03.2 | Mark as Consumed + Add Occasion Note | JTBD-03.3 | Occasion field available and optional; note retrievable within 30 seconds on future visit |
| JRN-03.2 | Verify Inventory | JTBD-03.2 | Collection quantity within ±1 bottle of physical cellar for 30 consecutive days |
| JRN-04.1 | Enter Required Fields | JTBD-04.1 | Every wine record has a required, user-defined named storage location |
| JRN-04.1 | Confirm Location | JTBD-04.1 | Location filter returns complete wine list for named location in ≤ 10 seconds |
| JRN-04.1 | Save and Verify | JTBD-04.1 | Off-site and secondary locations are as visible as primary cellar locations |
| JRN-04.2 | Filter to Drink Now + Approaching Peak | JTBD-04.2 | All wines entering their window identified in a single filter interaction |
| JRN-04.2 | Sort by End Year | JTBD-04.2 | Zero high-value bottles opened past their window due to missed tracking within 90 days |
| JRN-04.2 | Review Collection Breakdown | JTBD-04.3 | Full collection composition (type, region, vintage decade, readiness) visible in ≤ 30 seconds |
| JRN-04.2 | Cross-Check Off-Site Storage | JTBD-04.3 | Spreadsheet composition review retired within 60 days of adoption |

---

*JOURNEYS generated by Pivota Spec Journeys Generator · SimpleWineApp v1.0 MVP · 2026-06-03*
