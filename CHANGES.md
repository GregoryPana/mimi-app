# Mimi App Changes

### [2026-04-29] - Home Screen Widgets Refinement
- **Size Locking**: Enforced 4x4 grid size for Packing/Itinerary lists and 2x2 for Countdown/Us/Memory cards using `targetCellWidth` and `targetCellHeight`.
- **Data Persistence**: Fixed SharedPreferences naming mismatch (`HomeWidgetPreferences`) to ensure list data correctly displays when the app is closed.
- **Background Interactivity**: Split packing item click zones. Clicking the checkbox toggles state in a background isolate (Sanity CMS) without opening the app, while clicking the text deep-links to the Seychelles Packing tab.
- **Deep Linking**: Implemented `HomeWidget` URI listener in `main.dart` and updated `SeychellesScreen` to support programmatically selecting the correct tab on launch.
- **Robustness**: Enhanced background callback with logging and propagation delays to ensure the widget reflects the latest cloud state reliably.

### [2026-04-24] - Shared Memory Hub Stabilization & UI Refinement

#### Improved
- **PIN Page Redesign**: Completely overhauled `PasscodeScreen` with a premium glassmorphic aesthetic, animated indicator dots, and a centered minimal layout.
- **Seychelles UX**: Relocated the confetti party popper FAB to the left side (`startFloat`) to prevent overlap with tab-specific action buttons.
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
