# Product Ledger — Our Love Story (Mimi)

This document is the single source of truth for domain model, rules, schemas, state machines, UI flows, and architectural decisions.

## Status
- Discovery: in progress
- Domain model: drafted
- Schemas: drafted
- Invariants: locked (per prompt)
- Open questions: pending user answers

## Vision & Scope
- Private, offline-first romantic mobile app for Mimi/Baby/My love.
- Flutter app targeting Android + iOS.
- No accounts, no backend, no network dependency.

## Tone & Identity (Locked)
- Allowed names only: Baby, Mimi, My love.
- Tone: warm, romantic, simple, premium.

## Important Dates (Locked)
- Relationship start: 2022-02-02.
- Anniversary milestone title: "Happy 4 Years Together ❤️".
- Valentine’s unlock date: Feb 14 (every year).

## Security (Locked)
- Passcode required after splash screen.
- Passcode: 222022.

## Platform & Architecture
- Framework: Flutter.
- Layered architecture:
  - Domain & Rules (pure Dart, no Flutter imports).
  - Application Logic (state orchestration, persistence, navigation).
  - Interface & Platform (Flutter UI widgets, animations, theme, assets).

## State Management Decision
- Selected: Riverpod (Reason: explicit providers, testability, clear separation from UI).

## Persistence Decision
- Selected: SharedPreferences (Reason: small key-value state, simple offline persistence).

## Domain Entities & Schemas

### TimelineItem
- id: string
- title: string
- date: string | null
- text: string
- imageAsset: string | null

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

## Invariants & Business Rules (Locked)

### Timeline Completion
- Timeline is complete only when user reaches the end and taps “I finished our story ❤️”.
- Then set timelineCompleted = true.

### Gallery Completion
- Gallery is complete only when every gallery image has been opened at least once.
- Then set galleryCompleted = true.

### Surprise Gift Unlock
- Locked unless timelineCompleted == true AND galleryCompleted == true.

### Valentine’s Mode — Before Feb 14
- Show countdown (days remaining to Feb 14).
- Show “Today’s Love Letter 💌”.
- Reveal 1 new letter per day deterministically based on date.

### Valentine’s Mode — On Feb 14
- Show unlock animation.
- Show mini-game placeholder.
- Show vouchers list with 3 vouchers:
  - “1 Free Meal 🍽️”
  - “2 Free McD 🍔🍟”
  - “1 Free Pic 📸”

### Voucher Redemption
- Each voucher redeemable once.
- Redemption persists permanently.
- Redeemed vouchers show “Redeemed ✅” and cannot be redeemed again.

## Application State Machine

### App Lifecycle
- Splash -> Passcode -> Home.

### Progress State Transitions
- Start: timelineCompleted=false, galleryViewedIds=empty, galleryCompleted=false, redeemedVoucherIds=empty.
- Timeline: on tap end button, set timelineCompleted=true.
- Gallery: on image open, add id to galleryViewedIds; if size == total gallery count, set galleryCompleted=true.
- Vouchers: on redeem, add voucher id to redeemedVoucherIds.

## UI Flow Overview
- Splash Screen
  - Romantic fade-in, enter button.
- Passcode Screen
  - Numeric keypad, hint text, wrong code message.
- Home Screen
  - Four main cards: Memory Gallery, Our Timeline, Surprise Gift (locked/unlocked), Valentine’s Mode (countdown + letters).
- Timeline Screen
  - Vertical list of 5 items from local JSON, end button.
- Gallery Screen
  - Grid of thumbnails from local JSON, tap to fullscreen with caption.
- Surprise Gift Screen
  - Locked: lock icon + checklist.
  - Unlocked: anniversary title + romantic message.
- Valentine’s Mode Screen
  - Before Feb 14: countdown + today’s letter.
  - On Feb 14: unlock animation + mini-game placeholder + vouchers.

## Required Content Files (JSON)
- assets/data/timeline.json
- assets/data/gallery.json
- assets/data/valentines_letters.json
- assets/data/vouchers.json

## Assets Structure
- assets/images/
- assets/icons/ (optional)

## Decisions Log
- 2026-02-01: Date source uses device local time.
- 2026-02-01: Valentine letters run Feb 1 through Feb 13 (13 letters, one per day).
- 2026-02-01: Initial gallery set located at images/seychelles/ (single section for Memories).
- 2026-02-01: Timeline items listed without full details (see draft list below).
- 2026-02-01: Use placeholder captions and timeline text until real content is provided.
- 2026-02-01: Day 14 Valentine letter reserved for Feb 14 unlock content, not part of daily letters.
- 2026-02-01: Use lucide_icons package for iconography in Flutter.
- 2026-02-01: Valentine unlock is treated as active on Feb 14 and later (assumption).
- 2026-02-01: If before Feb 1, Valentine letter card shows a placeholder note (assumption).
- 2026-02-01: Valentine unlock message uses Day 14 letter text.

## Draft Timeline Items (Titles + Dates)
1) First meet — 2022-01-21
2) Together — 2022-02-02
3) First meet/date — 2022-02-05
4) First movie — 2022-02-13
5) Meet your fam mother (Cass's family) — 2022-04
6) Meet my mother — 2022-04
7) Move in together — 2022-10
8) Meet whole family — 2023-04
9) Go to Seychelles — 2024-07/08

## Open Questions (Non-Blocking)
1) Provide final gallery captions when ready.
2) Provide full timeline texts and optional images when ready.
3) Confirm Valentine’s Mode behavior after Feb 14 and before Feb 1.

## Approvals Log
- 2026-02-01: Initial ledger created from prompt and style guide.
