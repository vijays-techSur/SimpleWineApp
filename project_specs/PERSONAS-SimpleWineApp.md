# Persona Profiles
## SimpleWineApp — Personal Wine Collection Manager

| Field | Value |
|-------|-------|
| **Product** | SimpleWineApp v1.0 MVP |
| **Date** | 2026-06-03 |
| **Author** | Pivota Spec Personas Generator |
| **Related PRD** | `project_specs/PRD-SimpleWineApp.md` |
| **Status** | Draft |

---

## Persona Summary

| ID | Name | Role | Primary Goal |
|----|------|------|--------------|
| PER-01 | Marcus T. | Casual Collector | Track what he owns and find a good bottle without overthinking it |
| PER-02 | Diane L. | Enthusiast | Build a personal preference record and drink every bottle at its best |
| PER-03 | Priya S. | Home Entertainer | Quickly find the right bottle for any guest or occasion |
| PER-04 | Richard A. | Serious Collector | Manage storage precision, readiness tracking, and collection health across a large cellar |

---

## PER-01: Marcus T.

**Role Title:** Casual Collector

**Role & Context:**
Marcus is a 38-year-old marketing manager who has gradually built a wine collection of around 30–50 bottles over the past few years — mostly gifts, holiday picks, and impulse buys from local wine shops. He stores most bottles in a small countertop wine fridge and a few extras in a kitchen rack. Today he tracks his collection in a note on his phone: a partial list that is almost always out of date. He opens the note before buying wine to avoid duplicates, but it rarely reflects what he actually has. Marcus is not a wine expert and does not want to become one — he just wants to know what he has and be able to pick something good for dinner without pulling out every bottle to check labels. He uses his phone for almost everything and will abandon any tool that takes more than a minute to update.

**Goals:**
- Know at any moment what bottles are in his collection, without a manual count (F0, F1)
- Add a new bottle in under 60 seconds, right after buying it (F0)
- Find a wine to open tonight without hunting through the fridge (F3, F5, F6)
- Stop buying duplicates by checking the app before going to the store (F0, F3)
- Understand the basics of his collection without studying it (F6)

**Pain Points:**
- His phone note is perpetually stale — he forgets to update it after drinking or gifting a bottle
- No sense of what is "ready to drink" vs. what needs more time; opens bottles at random
- Accidental duplicates — buys wines he already has because the list is incomplete
- Remembering where a specific bottle is (fridge vs. rack) costs a physical search
- Any tool with too many required fields will be abandoned immediately

**Technical Expertise:** Casual — comfortable with apps and mobile web; avoids tools that feel like data entry work; expects any new feature to be obvious on first use.

**Top Tasks:**
1. Add a new bottle immediately after a purchase, on mobile (daily/weekly — critical)
2. Browse or search for a wine to open tonight (several times per week — critical)
3. Mark a bottle as consumed after drinking it (weekly — high)
4. Check what he has before buying at a wine shop (ad hoc — high)
5. Glance at the dashboard to understand his collection size and readiness (occasional — medium)

**Success Criteria:**
- Can add a wine record in ≤ 60 seconds with no instructions
- Collection list is accurate enough that he stops maintaining the parallel phone note within 30 days
- Can locate a specific wine by name or type in ≤ 15 seconds
- Zero accidental duplicate purchases after first 30 days of use

---

## PER-02: Diane L.

**Role Title:** Enthusiast

**Role & Context:**
Diane is a 45-year-old financial analyst with a growing collection of 100–200 bottles that spans multiple regions and several vintages she is deliberately aging. She reads wine publications, attends occasional tastings, and buys with intention — she knows which bottles she wants to hold and which are ready now. Her current system is a hybrid spreadsheet and handwritten journal: the spreadsheet tracks inventory, the journal holds tasting notes, and the two are never fully in sync. She has detailed opinions about every wine she has opened and is frustrated that her preference history lives in a paper notebook that she cannot search or summarize. Diane wants a tool that does the thinking she already does — it just needs to do it faster and in one place. She uses both a laptop and her phone and expects the app to work well on both.

**Goals:**
- Capture tasting impressions immediately after opening a bottle, while the experience is fresh (F4)
- Track which bottles to hold and which have entered their drinking window (F5, F6)
- Build a searchable preference record she can use to guide future purchases (F4, F3)
- See a clear dashboard view of her collection's composition and readiness state (F6)
- Replace the spreadsheet entirely — one system, complete picture (F0, F1, F2)

**Pain Points:**
- Tasting notes live in a notebook she cannot search — opinions are captured but never usable
- Drinking window tracking is manual; she keeps a separate note reminding her which vintages to watch
- Spreadsheet and journal are out of sync — quantity counts drift, tasting history is incomplete
- No rating history means she cannot remember which producer or region consistently pleases her
- No "Drink Now" signal — she relies on memory and periodic spreadsheet reviews to find ready bottles

**Technical Expertise:** Intermediate-Advanced — comfortable with web apps and spreadsheets; appreciates structured data and expects fields that match her mental model of a wine record; tolerates moderate complexity if it delivers capability.

**Top Tasks:**
1. Record a tasting note with rating immediately after opening a bottle (weekly — critical)
2. Check drinking window status across the collection to find what is ready now (weekly — critical)
3. Search by producer or region to find bottles from a specific source (weekly — high)
4. View collection insights — breakdown by type, region, vintage decade (monthly — high)
5. Add new wine records with full field detail after a purchase or delivery (weekly — high)

**Success Criteria:**
- Can log a full tasting note (including rating) in ≤ 2 minutes on mobile
- Drinking-window status is accurate and visible without any manual calculation
- Can search tasting history by producer or grape to surface preference patterns
- Spreadsheet retired within 30 days of adoption

---

## PER-03: Priya S.

**Role Title:** Home Entertainer

**Role & Context:**
Priya is a 41-year-old product director who hosts dinner parties, holiday gatherings, and casual get-togethers several times per month. She maintains a modest but well-chosen collection of 40–80 bottles — purchased specifically with occasions in mind. Her challenge is not knowing what she owns in general; it is knowing what to serve to *these* guests at *this* dinner. Today she browses her wine fridge and kitchen rack physically, reading labels and trying to remember what would pair well or what a guest would enjoy. The decision takes longer than it should and she sometimes defaults to a safe pick rather than a better bottle she forgot she had. Priya is a confident app user who expects the product to be fast, beautiful, and not require wine expertise to operate. She wants a quick answer, not a wine education.

**Goals:**
- Find the right bottle for an occasion in under a minute without physical searching (F3, F5)
- Know what is ready to drink tonight versus what needs more time (F5, F6)
- Filter by type or occasion context to surface appropriate candidates quickly (F3)
- Track what she has served at past gatherings to avoid repeating with the same guests (F4)
- Keep the collection list accurate after each event so she knows what is left (F1)

**Pain Points:**
- Physical search through fridge and rack wastes time before guests arrive
- No quick way to filter by type (sparkling for aperitivo, red for the main course) without browsing the whole collection
- Bottles opened and consumed at gatherings are often not logged — inventory drifts
- No memory of what she served whom — relies on recollection for repeat guests
- Occasion notes on tasting records would help her recall context but she currently captures nothing

**Technical Expertise:** Intermediate — comfortable with polished consumer apps; expects intuitive navigation and a clean, attractive interface; will not read instructions; feature value must be immediately apparent.

**Top Tasks:**
1. Filter by wine type to find options for a specific course or occasion (before each event — critical)
2. Check readiness status to avoid opening bottles too early or past peak (before each event — critical)
3. Mark bottles consumed after an event and optionally add occasion/guest notes (after each event — high)
4. Search by producer or name to find a specific bottle she remembers having (ad hoc — high)
5. Glance at dashboard to understand current stock before planning a gathering (weekly — medium)

**Success Criteria:**
- Can filter to "Sparkling, Drink Now" in ≤ 3 taps from the home screen
- Collection quantity stays accurate — she updates it after each event without friction
- Can recall what was served at a past occasion via the tasting note occasion field; searching for an occasion keyword (e.g., "anniversary") in the main search bar surfaces wines whose most recent tasting note matches
- Opens the app before every gathering instead of doing a physical shelf walk

---

## PER-04: Richard A.

**Role Title:** Serious Collector

**Role & Context:**
Richard is a 58-year-old attorney with a collection of 400–600 bottles spread across a temperature-controlled basement cellar, a second wine fridge in his home office, and 20 bottles in off-site climate storage. He buys by the case, acquires across multiple regions and producers, and holds many bottles for 5–15 years before opening. His collection includes bottles valued at $100–$500+. Today he manages the collection in a combination of a detailed spreadsheet and a printed paper log he keeps with the cellar. The spreadsheet is accurate because he updates it religiously, but it gives him no visual summary, no readiness status, and no sense of the collection's composition at a glance. Richard's primary anxiety is making a mistake with a high-value bottle — opening it too early, misplacing it, or losing track of a case he stored in a different location. He uses a laptop primarily but expects mobile to work when he is standing in the cellar.

**Goals:**
- Know exactly where every bottle is stored, down to named location (F2, F0)
- Track drinking windows with precision and see what is entering peak readiness (F5, F6)
- Maintain an accurate running count across large quantities — by the case (F1, F0)
- See a complete collection overview: composition by region, type, vintage, readiness (F6)
- Record detailed tasting notes for significant bottles opened (F4)
- Replace his spreadsheet with a tool that gives him everything the spreadsheet does, plus readiness intelligence (F0, F5, F6)

**Pain Points:**
- Multi-location storage is managed mentally — he knows "roughly" where cases are but has no structured map
- Drinking window tracking is manual; he marks promising vintages in a paper notebook and reviews annually
- No readiness status across the full collection — he has to calculate mentally which bottles are entering peak
- Collection composition (what fraction is Bordeaux vs. Burgundy vs. California) requires manual counting in the spreadsheet
- Off-site storage is essentially invisible — he forgets what is there unless he checks a separate document
- A missed drinking window on a $300 bottle is a real loss, not just a minor inconvenience

**Technical Expertise:** Advanced — deeply comfortable with spreadsheets and structured data; expects every field to be present and editable; values data completeness over speed; comfortable with complexity if it delivers precision.

**Top Tasks:**
1. Check which bottles across all locations are entering or at "Drink Now" status (weekly — critical)
2. Add a full wine record with complete field set after a case purchase (weekly — critical)
3. Filter the collection by storage location to see what is in a specific physical space (weekly — high)
4. View collection breakdown by region, type, and vintage decade (monthly — high)
5. Log a detailed tasting note for a significant bottle after opening (monthly — high)

**Success Criteria:**
- Every bottle has a named, accurate storage location assigned
- Drinking window readiness status is visible across all 400–600 records without manual calculation
- Can filter by location to see only "Basement Cellar" wines in ≤ 10 seconds
- Collection composition view replaces his manual spreadsheet counting
- Zero bottles opened outside their drinking window due to missed tracking (aspirational — reduce vs. spreadsheet baseline)

---

## Persona Relationships

| Persona | Interacts With | Interaction Context |
|---------|---------------|---------------------|
| PER-01 Casual Collector | PER-03 Home Entertainer | Shares similar need: "what should I open tonight?" — differs in scale and occasion formality |
| PER-02 Enthusiast | PER-04 Serious Collector | Shares tasting note and drinking window features — differs in collection scale and location complexity |
| PER-03 Home Entertainer | PER-01 Casual Collector | Both want fast selection; Priya adds multi-guest occasion context Marcus skips |
| PER-04 Serious Collector | PER-02 Enthusiast | Diane's preference focus → Richard's precision focus; same F4/F5 features, different depth of use |

> **Note:** All four personas are single-user, personal-use in v1. Shared household and multi-user interactions are out of scope for MVP (see PRD Section 10).

---

## Feature-Persona Matrix

| Feature | PER-01 Casual | PER-02 Enthusiast | PER-03 Entertainer | PER-04 Serious |
|---------|:-------------:|:-----------------:|:------------------:|:--------------:|
| **F0** Wine Inventory CRUD | Primary | Primary | Primary | Primary |
| **F1** Quantity & Bottle Status | Primary | Primary | Primary | Primary |
| **F2** Storage Location Mgmt | Secondary | Secondary | Secondary | Primary |
| **F3** Search & Filter | Primary | Primary | Primary | Secondary |
| **F4** Tasting Notes & Ratings | Secondary | Primary | Secondary | Primary |
| **F5** Drinking Window Mgmt | Secondary | Primary | Primary | Primary |
| **F6** Collection Dashboard | Secondary | Primary | Secondary | Primary |

**Key:**
- **Primary** — This persona is the core user of this feature; feature must serve this persona's needs first
- **Secondary** — This persona uses this feature but it is not their primary driver; experience must not conflict with their workflow
- **—** — Feature is not relevant to this persona

### Feature Coverage Notes

- **F0 (CRUD):** All personas depend on this as the foundational capability. Speed of entry is most critical for PER-01 (casual); field completeness is most critical for PER-04 (serious).
- **F2 (Storage):** PER-04 is the primary driver — multi-location tracking is a core pain point. PER-01 and PER-03 use single or two locations; the feature must not add friction for simpler storage setups.
- **F3 (Search & Filter):** PER-01 and PER-03 drive the need for fast, low-effort filtering. PER-02 drives the richer filter attributes (by producer, grape, rating range). PER-04 uses location-based filtering most.
- **F4 (Tasting Notes):** PER-02 is the power user; tasting notes must support her structured preference-tracking workflow. PER-04 uses it for significant bottles. PER-01 and PER-03 may use it lightly — the feature must not feel mandatory.
- **F5 (Drinking Window):** Drinking readiness status is a high-value signal for PER-02, PER-03, and PER-04. PER-01 benefits from the "Drink Now" label without needing to understand drinking windows in depth.
- **F6 (Dashboard):** PER-02 and PER-04 are the primary audience for collection insights. PER-01 and PER-03 benefit from the Drink Now shelf; they will not engage deeply with breakdown charts.

---

*PERSONAS generated by Pivota Spec Personas Generator · SimpleWineApp v1.0 MVP · 2026-06-03*
