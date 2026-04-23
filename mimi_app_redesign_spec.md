# Mimi App Redesign and Enhancement Specification

## Purpose of this document
This document is intended to be handed off to an AI coding agent inside an AI-enabled IDE. The agent should use this as the authoritative redesign and implementation brief for the existing Flutter application.

The app already exists and is functional. The goal is **not** to rewrite it blindly from scratch unless necessary. The goal is to:
- read and understand the existing Flutter codebase,
- preserve what is already working where reasonable,
- refactor where needed,
- redesign the UX/UI,
- introduce a better internal structure,
- add new features in a controlled way,
- keep the app offline-first,
- and maintain the emotional/personal nature of the product.

This specification should be treated as a detailed implementation and product design brief.

---

# 1. Project Context

## 1.1 Current state of the app
The current Flutter app is an offline-only personal relationship/memory app built for the user's significant other.

Current flow:
1. PIN entry screen
2. Main menu
3. Individual sections/pages including:
   - Gallery
   - Comics
   - Timeline
   - Valentine’s page (outdated seasonal page)
   - Links page for Google Drive links to pictures/videos

## 1.2 Current content/features
### PIN entry
- App opens into a PIN-protected entry screen.
- Successful PIN entry leads to the main menu.

### Gallery
- Contains many images.
- Images are currently categorized using two basic hardcoded criteria.
- Current logic is simple and likely static.

### Comics
- Displays comic pages created by the app owner.

### Timeline
- Shows notable events throughout the relationship.

### Valentine’s page
- Was used as a special temporary seasonal page.
- Currently outdated.
- Should not remain as a standalone permanent top-level feature in its current form.

### Links
- Contains external Google Drive links for photos and videos.
- Currently exposed via the app as menu-driven external access.

---

# 2. Product Direction

## 2.1 Strategic redesign goal
The app should evolve from a simple menu of separate features into a more emotionally engaging, polished, memory-driven experience.

The current structure feels like a collection of independent pages.
The new structure should feel like a cohesive “living memory app”.

## 2.2 Experience goal
The experience should feel:
- personal,
- soft,
- warm,
- romantic,
- elegant,
- dynamic,
- and intentionally designed.

It should not feel like a generic utility app.
It should feel like a curated private space for memories, milestones, letters, stories, and meaningful interactions.

## 2.3 Technical goal
The implementation should:
- continue using Flutter,
- remain offline-first by default,
- preserve compatibility with the existing project where possible,
- avoid unnecessary architectural overengineering,
- improve maintainability,
- and support future expansion cleanly.

---

# 3. Core Product Principles

The AI agent should follow these principles during implementation:

## 3.1 Preserve existing working value
Do not discard working logic unless it blocks the redesign.
If existing gallery/comics/timeline implementations can be reused or adapted, prefer refactoring over destructive replacement.

## 3.2 Offline-first remains the default
The app is currently offline-only, and that should remain the primary mode.
External links may still exist, but the app’s core experience must not depend on internet access.

## 3.3 Emotion before utility
The app is not primarily a productivity or file management tool.
Visuals, interaction design, and content presentation should support an emotional experience first.

## 3.4 Dynamic feeling without requiring AI or backend
Even while remaining offline-only, the app should feel alive through date-based logic, resurfacing memories, featured content, and personalized presentation.

## 3.5 Avoid fragmented top-level navigation
The new home should not just be a large menu of equal cards.
There should be content hierarchy, a featured section, and guided exploration.

## 3.6 Build a stronger internal data model
Where possible, unify currently separate concepts under a better content model so the app becomes easier to scale and maintain.

---

# 4. Redesign Scope Overview

The redesign should cover all of the following:

1. Home screen redesign
2. Navigation restructuring
3. Gallery improvements
4. Comics improvements
5. Timeline improvements
6. Removal/replacement of outdated Valentine’s standalone page
7. Reframing of external links page
8. Addition of new feature types (especially Letters)
9. Better content modeling and architecture
10. UI polishing and consistency
11. Retention of PIN-protected entry flow, with possible visual improvement

---

# 5. Existing Features: What should happen to each

## 5.1 PIN entry screen
### Keep
The app should still open into a protected entry screen.

### Improve
The visual design of the PIN screen may be updated to match the redesigned app language.

### Functional expectations
- Maintain PIN validation behavior.
- Preserve local/offline functionality.
- Keep it lightweight and fast.
- Optional: make it feel more custom and branded to the app rather than generic.

### Optional enhancements
These are optional, not mandatory for first pass:
- custom keypad styling,
- subtle animation,
- a hidden/easter-egg-style alternative unlock method,
- thematic messages on unlock.

Do not complicate security logic unnecessarily unless there is already a clean implementation path.

## 5.2 Gallery
### Keep
The gallery remains a core feature.

### Redesign intent
The gallery should feel more integrated into the broader “memories” experience instead of just being a separate photo section.

### Improve
- Better categorization structure
- Better layout/presentation
- Ability to surface featured/recent/meaningful memories from the gallery on the home page
- Better browsing experience

### Current assumption
There are hardcoded categories right now.
The AI agent should inspect current implementation and determine whether to:
- preserve current categories while improving the UI, or
- refactor them into a more scalable content/category model.

## 5.3 Comics
### Keep
Comics remain a core feature.

### Improve
- Better home-page surfacing
- Potential “continue where you left off” behavior
- Cleaner comic-reading presentation
- Better organization of comic stories/pages if current implementation is too flat

### Desired emotional role
Comics should feel like a special story section made “just for us”, not just an image list.

## 5.4 Timeline
### Keep
Timeline remains a core feature.

### Improve
- Better visual presentation
- More elegant card/event layout
- Better filtering or grouping by year/category if feasible
- Support for richer event entries
- Potential inclusion of media or memory references inside timeline entries where appropriate

### Important new logic
Timeline data should power “Today in Our Story” behavior on the home screen by checking whether any timeline event matches the current day/month.

## 5.5 Valentine’s page
### Remove as a standalone main feature
The current Valentine’s page is outdated and should not remain as an equal top-level module in its current form.

### Replace with better concept
Instead of one outdated seasonal page, introduce a more flexible approach for temporary/seasonal/date-based special experiences.

Possible handling:
- convert it into a reusable “special moments” or “seasonal/event card” concept,
- integrate date-based unlockables,
- or repurpose any useful code/assets into another feature.

The old Valentine’s page should not remain visible as a permanent main menu destination.

## 5.6 Links page
### Keep concept, but redesign purpose
The current links page should be reframed.
It should not feel like a raw utility page.

### New role
Treat it more like an “External Memories” or “Shared Albums / Shared Videos” area.

### Improve
- cleaner naming,
- cleaner visual presentation,
- better grouping,
- better UX for opening external resources,
- more emotional framing.

### Constraint
These links may still point to Google Drive or other external storage. That is acceptable, but the section should fit the app’s tone better.

---

# 6. New App Structure

## 6.1 Overall direction
The new app should shift from a simple card menu into a content-led home experience.

Instead of presenting all features equally at once, the app should:
- welcome the user,
- highlight something meaningful,
- resurface memories,
- allow quick continuation,
- and then provide access to deeper sections.

## 6.2 Proposed top-level feature structure
The app should revolve around these conceptual areas:
- Home
- Memories / Gallery
- Timeline
- Comics
- Letters
- External albums/videos (if retained as separate area)
- Optional unlocks / special content

Not every one of these must be a bottom navigation tab. Some may remain as routed pages from the home screen.

## 6.3 Home screen as experience hub
The home screen should become the main emotional dashboard and should contain:
- personalized welcome section,
- relationship duration indicator,
- “Today in Our Story” card,
- featured memory card,
- continue section,
- quick actions grid,
- optional mood selector,
- and generally a stronger content hierarchy.

---

# 7. Detailed Home Screen Specification

## 7.1 Visual role of the home screen
The home screen should be the app’s centerpiece.
It should feel premium, warm, clean, and emotionally expressive.

It should not feel like a dashboard for tools.
It should feel like entering a private memory space.

## 7.2 Home screen layout order
The intended home layout should roughly follow this content order:

1. Header / Welcome section
2. Relationship duration / contextual subtitle
3. Today in Our Story card
4. Featured Memory card
5. Continue Where You Left Off section
6. Quick Actions grid
7. Optional Mood Mode section
8. Lower navigation or page continuation

The exact spacing and implementation may vary, but the overall hierarchy should remain.

## 7.3 Header section
### Content
- Personalized greeting such as “Welcome back, Baby ❤️”
- Secondary line such as relationship day count or another soft contextual line

### Behavior
Relationship duration should be calculated based on a configured relationship start date.
The start date should be stored in a clean configurable place, not scattered through UI code.

### Style
- Large bold heading
- Softer subtitle text
- Plenty of breathing room
- Soft romantic tone

## 7.4 Today in Our Story
### Purpose
Surface meaningful events that happened on the same calendar date in previous years.

### Logic
Match current date against timeline items:
- compare day and month,
- ignore year for matching purposes,
- if multiple events match, either:
  - choose the most meaningful by priority, or
  - rotate/select one deterministically.

If no event matches:
- either hide the section,
- or show a gentle fallback card with another resurfaced memory.

### Content
The card may include:
- small image thumbnail if available,
- event title,
- short description or relative time text such as “2 years ago today”.

### Interaction
Tap should open the relevant timeline item or memory details.

## 7.5 Featured Memory
### Purpose
This is the visual hero card of the home screen.
It should be the most prominent card.

### Content
- large image background,
- short title,
- gentle subtitle such as “Tap to relive this moment”.

### Logic
The featured memory can be selected based on one of these strategies:
- manually curated featured item,
- rotating featured item,
- date-sensitive featured item,
- recently important/favorite item.

The initial implementation can use a simple deterministic approach as long as it is structured to be improved later.

### Design
- full-width large card,
- rounded corners,
- image with soft dark or gradient overlay,
- strong readable typography,
- subtle affordance that it is tappable.

## 7.6 Continue Where You Left Off
### Purpose
Give continuity to the experience.

### Content examples
- last opened comic/page,
- last viewed gallery album/category,
- or last opened memory collection.

### Logic
Track lightweight local state for recently visited content.

### Scope
First version can implement one or two “continue” cards only.
Do not overcomplicate.

## 7.7 Quick Actions Grid
### Purpose
Provide access to main sections without making the entire home screen feel like a menu.

### Recommended items
- Memories
- Timeline
- Letters
- Comics

Optionally external albums/videos may also be included either here or elsewhere.

### Design
- 2x2 grid preferred,
- smaller cards than current main menu cards,
- consistent icon + label + short subtitle,
- soft colors,
- not visually overpowering.

## 7.8 Mood Mode (optional but desired)
### Purpose
Allow the user to pick a mood and receive thematically relevant content.

### Moods can include
- happy,
- missing you,
- romantic,
- comfort/sad,
- sleepy/calm.

### First implementation recommendation
This does not need AI.
It can simply map moods to pre-tagged categories or content groups.

### Outcome
Tapping a mood should lead to a filtered view or curated content set.

---

# 8. New Feature: Letters

## 8.1 Add a Letters feature
This is a high-priority enhancement and should be added as a first-class feature.

## 8.2 Purpose
Letters are private written notes/messages that can be read intentionally, often in an emotional context.

## 8.3 Example content types
- open when you miss me,
- open when you’re sad,
- open when you need motivation,
- anniversary notes,
- soft reminders,
- special date letters.

## 8.4 Functional expectations
- letters can be displayed as a list/grid of beautiful cards,
- a letter opens into a dedicated reading view,
- reading experience should feel intimate and calm,
- content should remain local/offline unless explicitly externalized later.

## 8.5 Optional unlock behavior
Some letters may optionally be:
- date-gated,
- manually unlockable,
- hidden until triggered.

Initial implementation can support a simple flag-based unlock system.

---

# 9. Data Model Direction

## 9.1 Current likely issue
The current app probably treats Gallery, Comics, Timeline, and other sections as mostly separate hardcoded UI/data blocks.
That works initially but becomes harder to scale.

## 9.2 Desired improvement
The AI agent should inspect the codebase and, where practical, move toward a more coherent content model.

## 9.3 Suggested conceptual model
A flexible internal content model may be introduced, for example under a concept like a “Moment” or “MemoryItem”.

This does not have to be forced everywhere immediately, but the structure should support cross-feature reuse.

Possible shared fields:
- id
- title
- description
- date
- type
- image paths
- tags
- category
- route target or content payload
- featured flag
- unlock info

## 9.4 Important note
The agent should not over-normalize if the existing app is simple and small. The goal is maintainability and reuse, not unnecessary abstraction.

A balanced refactor is preferred.

---

# 10. Gallery Redesign Specification

## 10.1 Preserve all current content
Existing gallery assets and categories should be preserved unless there is a strong technical reason to change them.

## 10.2 Improve structure
The gallery should support better browsing through one or more of the following:
- category tabs,
- sectioned albums,
- date groups,
- tagged moments,
- favorites/highlights.

## 10.3 Improve UI
The gallery should feel more curated and premium.
Possible UI improvements:
- cleaner album cards,
- masonry/grid layout if appropriate,
- memory detail view,
- smooth image transitions,
- captions or contextual metadata where available.

## 10.4 Home integration
Gallery content should be able to power:
- Featured Memory,
- continue section,
- resurfaced content,
- mood filtering.

## 10.5 Performance
If the gallery is image-heavy, ensure image loading and scrolling remain smooth.
Use Flutter-friendly optimizations where useful.

---

# 11. Comics Redesign Specification

## 11.1 Preserve current comic content
Existing comic assets/pages should remain usable.

## 11.2 Improve navigation and reading
The AI agent should evaluate the current reading experience and improve it if needed.
Possible improvements:
- cleaner comic list page,
- story grouping if multiple comics exist,
- page viewer with smooth swipe experience,
- reading progress tracking,
- resume/continue behavior.

## 11.3 Home integration
Comics should appear in:
- continue section,
- quick actions,
- possibly featured content when relevant.

---

# 12. Timeline Redesign Specification

## 12.1 Preserve and enrich
Timeline remains central.
It should become both visually better and more functionally useful.

## 12.2 Event model
Each timeline entry should ideally support:
- title,
- date,
- short description,
- optional long description,
- optional image,
- optional tag/category,
- optional icon or accent style.

## 12.3 UI improvements
Possible direction:
- chronological vertical timeline,
- grouped by year,
- visually elegant event cards,
- smoother spacing and typography,
- ability to tap into event details.

## 12.4 Home integration
Timeline entries should power:
- Today in Our Story
- resurfaced memories
- future special/event-based highlights

---

# 13. Replacement for the old Valentine’s feature

## 13.1 Problem
A hardcoded seasonal Valentine’s page is not scalable and is now outdated.

## 13.2 New approach
Replace it with one or both of the following:

### Option A: Special Moments framework
A flexible feature for date-based or event-based temporary content.
Examples:
- anniversary card,
- valentine card,
- birthday surprise,
- milestone unlock.

### Option B: Unlockables / seasonal content
A small framework for hidden or date-triggered cards/content.

## 13.3 Recommendation
Do not retain the old Valentine screen as-is.
Refactor any useful assets/code into a more generic mechanism if worthwhile.

---

# 14. External Links Redesign Specification

## 14.1 Rename/reframe
The existing “Links” section should be reframed into something more emotionally aligned.
Possible names:
- Shared Albums
- Shared Memories
- Videos & Albums
- More Memories

The agent may keep a simple/internal route name but should improve the user-facing naming.

## 14.2 Structure
Instead of raw buttons, group links more intentionally.
Example grouping:
- Photos
- Videos
- Shared folders

## 14.3 UX
- Provide cleaner cards/buttons
- Use icons and subtitles
- Make it clear when content opens externally
- Keep visual consistency with the rest of the app

---

# 15. Navigation and Routing

## 15.1 Current likely issue
Navigation is probably page-based and menu-driven.

## 15.2 Desired direction
Navigation should be cleaner and more intentional.
The AI agent should evaluate whether to use:
- bottom navigation,
- a home-centered push-navigation approach,
- or a hybrid.

## 15.3 Recommendation
At minimum, the app should have a strong Home route and sensible routes to:
- Memories/Gallery
- Timeline
- Letters
- Comics
- External albums/videos if retained as separate route

The exact routing pattern should match the scale of the current app and existing architecture.

---

# 16. UI Design System Specification

## 16.1 Overall visual language
The UI should remain soft, romantic, pastel, and modern.
It should preserve the emotional DNA of the current app while becoming more refined.

## 16.2 Background
Use a soft pastel gradient, likely in the family of:
- pink,
- blush,
- lavender,
- light peach,
- soft purple.

The background should remain gentle and not visually noisy.

## 16.3 Cards
Cards should have:
- large rounded corners,
- soft shadows,
- clean spacing,
- slightly translucent or softly tinted surfaces where appropriate.

## 16.4 Typography
Typography should establish clearer hierarchy:
- strong display heading for the welcome section,
- medium-weight section headers,
- softer body/subtitle text,
- consistent sizing and spacing.

## 16.5 Icons
Icons should be soft and friendly.
Use consistent iconography style across the app.

## 16.6 Motion
Use subtle animation where it helps:
- fade/slide in on cards,
- gentle press states,
- smooth route transitions,
- hero animations for featured memory/gallery transitions where appropriate.

Avoid excessive or gimmicky motion.

## 16.7 Hierarchy
Not all content should have equal visual weight.
The home screen especially should clearly prioritize:
1. welcome,
2. today card,
3. featured memory,
4. continue,
5. quick actions.

## 16.8 Decorative details
Very subtle decorative accents are acceptable, such as:
- faint heart shapes in the background,
- sparkle motifs,
- soft overlays.

These should remain understated.

---

# 17. State and Persistence Expectations

## 17.1 Offline persistence
The app remains offline-first.
Where persistence is needed, the agent should use appropriate local persistence already present in the project or a lightweight solution consistent with the codebase.

## 17.2 Things worth persisting locally
- PIN or unlock config if already present
- relationship start date config
- last viewed comic/page
- last opened gallery/memory category
- unlock states for letters/surprises if implemented
- user preferences if needed for polish

## 17.3 Constraint
Do not introduce a backend or cloud dependency for the redesign.

---

# 18. Proposed Codebase Structure Direction

The AI agent should inspect the existing codebase first and then decide how aggressively to refactor.
A preferred direction is feature-based organization with shared core components.

Example high-level structure:

- core/
  - theme/
  - constants/
  - models/
  - widgets/
  - utils/
  - services/
- features/
  - auth_or_pin/
  - home/
  - gallery/
  - comics/
  - timeline/
  - letters/
  - external_memories/
  - unlocks_or_specials/

This is a direction, not a strict mandatory folder layout if the existing codebase already has a reasonable pattern.

## 18.1 Reusable widgets that may be created
- section header widget
- featured card widget
- quick action tile
- memory thumbnail card
- timeline event card
- empty state widget
- soft pill/badge widget

## 18.2 Theme centralization
Colors, spacing, radii, and text styles should be centralized where possible.
Avoid hardcoding repeated design values throughout the app.

---

# 19. Content Configuration Expectations

## 19.1 Avoid scattering hardcoded data across widgets
Where practical, move content/data definitions into cleaner structured files, constants, or model-backed lists.

## 19.2 Relationship config
Centralize values such as:
- relationship start date,
- app title,
- key labels/messages,
- featured item configuration.

## 19.3 Asset organization
Assets such as photos, comic pages, icons, illustrations, and decorative images should be organized cleanly.

---

# 20. Logic Requirements Summary

The following logic should exist or be introduced:

## 20.1 PIN flow
- preserve entry gate behavior
- transition into new home screen after success

## 20.2 Relationship duration calculation
- compute and display number of days together
- use centralized start date configuration

## 20.3 Today in Our Story logic
- compare current day/month against timeline events
- display matching event if present
- fallback gracefully if none found

## 20.4 Featured Memory logic
- select/display a featured memory
- allow deterministic configurable selection
- open detail screen on tap

## 20.5 Continue logic
- persist and show last relevant user progress/content entry points

## 20.6 Mood filtering logic (if implemented in first pass)
- map moods to content groups/tags
- open filtered content view

## 20.7 Letters logic
- support rendering and opening locally stored letters
- optionally support unlock conditions

## 20.8 External content logic
- keep ability to open external media links where needed
- make this feel integrated in the app UX

---

# 21. Implementation Expectations for the AI Agent

The coding agent should follow this process:

## 21.1 First inspect the existing codebase
Before modifying, read the codebase and understand:
- current architecture,
- current routes,
- data storage approach,
- asset organization,
- existing reusable widgets,
- current dependencies,
- current pin implementation,
- and current feature boundaries.

## 21.2 Preserve before replacing
Only replace sections aggressively where the current implementation is too rigid or poor for the redesign.

## 21.3 Prefer incremental refactor
A staged refactor is preferred:
1. understand existing app,
2. restructure foundation,
3. redesign home,
4. upgrade existing features,
5. add letters,
6. remove outdated valentine page,
7. polish and unify.

## 21.4 Maintain buildability
The app should remain buildable and runnable throughout the refactor as much as possible.
Avoid huge destructive changes in one step if not needed.

---

# 22. Suggested Implementation Phases

## Phase 1: Discovery and structural cleanup
- inspect existing codebase
- understand current flow and dependencies
- identify reusable parts
- centralize theme/config where needed
- clean routing foundation

## Phase 2: Home redesign
- replace old main menu with new home experience
- implement welcome header
- relationship duration
- today in our story
- featured memory
- continue section
- quick actions grid

## Phase 3: Existing feature upgrades
- improve gallery
- improve comics
- improve timeline
- reframe links page

## Phase 4: New features
- add letters
- optionally add unlock/special content scaffolding
- optionally add mood mode

## Phase 5: Cleanup and polish
- remove obsolete standalone valentine page
- unify spacing/colors/components
- improve transitions and small interactions
- verify UX consistency

---

# 23. What should explicitly not happen

The AI agent should avoid the following unless absolutely necessary:

- Do not convert this into an online-dependent app.
- Do not introduce a backend/server requirement.
- Do not overengineer the architecture beyond what the app size needs.
- Do not keep the old Valentine page as a permanent equal feature.
- Do not leave the app as a flat menu of identical cards.
- Do not scatter redesign constants everywhere without theming/config structure.
- Do not remove existing content just to simplify implementation.

---

# 24. Definition of success

The redesign is successful if the final app:
- still works offline,
- keeps the PIN entry flow,
- preserves and improves existing content,
- has a beautifully redesigned home screen,
- feels like a cohesive memory experience rather than a menu,
- adds letters as a meaningful feature,
- upgrades gallery/comics/timeline without losing their content,
- removes the outdated valentine-first design problem,
- and is organized cleanly enough for future maintenance and expansion.

---

# 25. Final instruction to the coding agent

Use this document as the redesign and implementation brief.
Start by understanding the existing Flutter codebase in detail.
Then plan the least destructive path to achieve this redesign while improving structure, UI, logic, and maintainability.

Preserve the emotional intent of the app at all times.
This is not just a technical refactor. It is a redesign of a deeply personal product.

