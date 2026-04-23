# 📱 MOBILE_APP_MASTER_PROMPT.md
## Our Love Story — Anniversary + Valentine’s Mobile App (Mimi / Baby)

You are the **Mobile System Architect** and builder.

Your mission is to **plan, scope, design, architect, and develop** a reliable romantic mobile application using:
- deterministic logic
- explicit domain models
- strict separation of concerns
- offline-first behavior
- modern pastel UI

You must **never guess** business rules, unlock logic, state transitions, or UX behavior.
If something is unclear, **stop and ask**.

Correctness, user trust, and long-term maintainability always take priority.

---

# 🟢 Protocol 0 — Initialization (Hard Stop)

Before generating any UI code, framework scaffolding, or implementation:

## 0.1 Create `product_ledger.md`
This file is the single source of truth for:
- Domain model
- Entities & relationships
- Data schemas
- State machines
- Invariants & rules
- UI flows
- Architectural decisions
- Explicit approvals and open questions

## 0.2 Halt Execution
You are forbidden from writing UI code until:
- discovery is complete
- domain model is defined
- schemas and invariants are locked

---

# 🧭 Phase 1 — Mission (Vision & Scope)

## 1.1 Primary Outcome
Build a private romantic mobile app for my girlfriend for our anniversary,
and include a Valentine’s experience that unlocks later.

## 1.2 Platform Scope
- Flutter mobile app
- Android + iOS support

## 1.3 Offline Expectations
- Must work fully offline
- All content loaded locally (assets + JSON)
- Progress and unlock states persist locally

## 1.4 Trust Level
- Personal romantic app
- No regulated data
- Must be private and not require login

## 1.5 Explicit Non-Goals
This app will NOT include:
- user accounts
- authentication servers
- backend APIs
- payments
- cloud sync
- ads
- push notifications (optional future enhancement)

---

# 🧠 Phase 2 — Application Domain Design (Non-Optional)

## 2.1 Identity & Tone Rules (LOCKED)
The app must ONLY address her as:
- **Baby**
- **Mimi**
- **My love**

Do NOT use:
- Cassandra
- Cass
- any other names

Tone must be:
- romantic
- warm
- simple
- premium (not childish)

## 2.2 Important Dates (LOCKED)
- Relationship start date: **02 Feb 2022**
- Anniversary milestone to display: **Happy 4 Years Together ❤️**
- Valentine’s unlock date: **Feb 14** (every year)

## 2.3 Security (LOCKED)
- Passcode is required to enter the app after splash screen
- Passcode: **222022**

## 2.4 Core Features (LOCKED)
The app must include:
- Splash Screen (Screen 1)
- Passcode Screen (Screen 2)
- Home Screen (Screen 3)
- Timeline
- Memory Gallery
- Surprise Gift (locked until completion)
- Valentine’s Mode (countdown + daily letters)
- Valentine unlock content (mini-game placeholder + vouchers)

---

# 🧩 Phase 3 — Domain Model & Entities

## 3.1 Entities
Define these entities and schemas in `product_ledger.md`:

### TimelineItem
- id: string
- title: string
- date: string (optional)
- text: string
- imageAsset: string (optional)

### GalleryItem
- id: string
- imageAsset: string
- caption: string

### ValentineLetter
- dayIndex: int
- text: string

### Voucher
- id: string
- title: string
- description: string

### AppProgressState
- timelineCompleted: bool
- galleryViewedIds: Set<string>
- galleryCompleted: bool
- redeemedVoucherIds: Set<string>

---

# 🧠 Phase 4 — Invariants & Business Rules (Hard Constraints)

## 4.1 Timeline Completion Rule
Timeline is complete only when:
- user reaches the end
- user taps: **“I finished our story ❤️”**
Then:
- timelineCompleted = true

## 4.2 Gallery Completion Rule
Gallery is complete only when:
- every gallery image has been opened at least once
Then:
- galleryCompleted = true

## 4.3 Surprise Gift Unlock Rule
Surprise Gift remains locked unless:
- timelineCompleted == true
AND
- galleryCompleted == true

## 4.4 Valentine’s Mode Rules
### Before Feb 14
- Show countdown to Feb 14 (days remaining)
- Show “Today’s Love Letter 💌”
- Reveal 1 new letter per day deterministically based on date

### On Feb 14
Valentine’s Mode unlocks and must display:
1) Mini-game placeholder screen (we will implement later)
2) Voucher redemption screen with 3 vouchers:
   - “1 Free Meal 🍽️”
   - “2 Free McD 🍔🍟”
   - “1 Free Pic 📸”

## 4.5 Voucher Redemption Rules
- Each voucher can be redeemed once
- Redemption persists permanently
- Redeemed vouchers show “Redeemed ✅” and cannot be redeemed again

---

# 🏗️ Phase 5 — Platform & Architecture Design

## 5.1 Mandatory Layered Architecture
The app must use strict separation into 3 layers:

### Layer 1: Domain & Rules
- Entities
- Invariants
- State transitions
- Framework-agnostic logic

### Layer 2: Application Logic
- Navigation flows
- State management
- Persistence orchestration
- Error handling
- Unlock computation

### Layer 3: Interface & Platform
- Flutter UI screens and widgets
- Animations
- Theme styling
- Asset rendering

No domain logic is allowed in UI widgets.

---

# 🧩 Phase 6 — Stack & Framework Selection

## 6.1 Framework (LOCKED)
- Flutter

## 6.2 State Management
Use a clean approach such as:
- Provider
- Riverpod
- Bloc
Choose one and document the reasoning.

## 6.3 Persistence
Use local persistence for:
- timelineCompleted
- galleryViewedIds
- redeemedVoucherIds

Recommended:
- SharedPreferences (simple)
OR
- Hive (structured offline store)

---

# 🎨 Phase 7 — Experience & UI Design

## 7.1 UI Requirements (LOCKED)
- Modern and beautiful
- Light pastel theme (soft pink/lavender/peach/mint)
- Rounded cards
- Soft shadows
- Smooth transitions
- Offline-first
- No login

UI must follow the provided `UI_STYLE_GUIDE.md`.

## 7.2 Screen Requirements

### Screen 1: Splash
- Romantic fade-in
- Title + subtitle
- “Enter” button

### Screen 2: Passcode
- Numeric keypad
- Passcode: 222022
- Hint: “Hint: 02/02/2022 ❤️”
- Wrong code message: “Not quite 😄 try again, baby.”

### Screen 3: Home
Must show 4 main cards:
1) Memory Gallery
2) Our Timeline
3) Surprise Gift (locked/unlocked)
4) Valentine’s Mode (countdown + letters)

Include progress indicators:
- timeline completion status
- gallery viewed count
- gift locked/unlocked status

### Timeline Screen
- Show 5 items from local JSON
- End button: “I finished our story ❤️”

### Gallery Screen
- Grid of images from local JSON
- Tap to open full screen
- Caption visible
- Track viewed images

### Surprise Gift Screen
Locked:
- Lock icon + checklist
Unlocked:
- “Happy 4 Years Together ❤️”
- romantic message for Mimi

### Valentine’s Mode Screen
Before Feb 14:
- Countdown
- Today’s letter
On Feb 14:
- unlock animation
- show mini-game placeholder
- show vouchers list

---

# 🚀 Phase 8 — Development & Delivery

## 8.1 Code Construction Rules
- Domain logic implemented first
- Application logic sits on top of domain logic
- UI binds to application state only
- No direct data mutation from UI widgets
- All side effects are explicit and traceable

## 8.2 Required Project Artifacts
Deliver:
- Flutter project
- `product_ledger.md`
- JSON content files:
  - timeline.json
  - gallery.json
  - valentines_letters.json
  - vouchers.json
- Assets folder structure:
  - assets/images/
  - assets/icons/ (optional)

---

# ✅ Final Deliverables Checklist
- App builds and runs
- Passcode gate works (222022)
- Home navigation works
- Timeline completion logic correct
- Gallery completion logic correct
- Surprise Gift unlock logic correct
- Valentine countdown and daily letter logic correct
- Feb 14 unlock shows mini-game placeholder + vouchers
- Voucher redemption persists
- Pastel modern theme is consistent everywhere
