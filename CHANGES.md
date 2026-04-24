# Mimi App Changes

### [2026-04-24] - Shared Memory Hub Stabilization

#### Fixed
- **Sanity API**: Resolved 404 error during image asset upload by removing redundant 'v' prefix in versioned URLs.
- **Author Identity**: Migrated all author labels and attribution logic from "Greg and Mimi" to "Mimi Boy" and "Mimi Girl".
- **Shared Memory CRUD**: Added the ability to delete shared memories from both the collection list (long press) and the full-screen gallery viewer.

#### Improved
- **Cloud Page Layout**: Refactored `SharedHubScreen` to remove standard AppBars and use a custom header that integrates cleanly with the persistent glassmorphic header.
- **UI Spacing**: Standardized top padding across Shared Hub tabs to ensure consistent visual flow and no content overlap with the app's persistent elements.
- **Sync Reliability**: Verified that `invalidate` calls correctly refresh the UI after deletions and additions in shared modules.

### [2026-04-23] - Seychelles Prep & Countdown Refinement

#### Added
- **Seychelles Countdown**: Implemented a high-end mechanical split-flap countdown animation for the trip screen.
- **Persistent Header**: Integrated a global glassmorphic header with relationship duration counter and music player.
- **Shared Hub**: Initial integration of Sanity CMS for collaborative notes, photos, and movies.
