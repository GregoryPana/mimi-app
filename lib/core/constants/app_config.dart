/// Centralized application configuration constants.
/// All hardcoded values (dates, names, passcodes) live here
/// so they can be found and changed in one place.
class AppConfig {
  AppConfig._();

  // ── Identity & Tone ──────────────────────────────────────
  static const String partnerName = 'Mimi';
  static const String appTitle = 'Our Love Story';
  static const List<String> petNames = ['Baby', 'Mimi', 'My love'];
  static const String welcomeGreeting = 'Welcome back,\nBaby ❤️';

  // ── Important Dates ──────────────────────────────────────
  static final DateTime relationshipStart = DateTime(2022, 2, 2);
  static const int anniversaryMonth = 2;
  static const int anniversaryDay = 2;
  static const int valentinesMonth = 2;
  static const int valentinesDay = 14;

  // ── Security ─────────────────────────────────────────────
  static const String passcode = '222022';
  static const String passcodeHint = 'Hint: 02/02/2022 ❤️';
  static const String passcodeError = 'Not quite 😄 try again, baby.';

  // ── Gallery Folders ──────────────────────────────────────
  static const Map<String, String> galleryFolders = {
    'seychelles': '🏝️ Seychelles',
    'malaysia': '🇲🇾 Malaysia',
  };

  // ── Feature Labels ───────────────────────────────────────
  static const String memoriesLabel = 'Memories';
  static const String memoriesSubtitle = 'All our special moments';
  static const String timelineLabel = 'Timeline';
  static const String timelineSubtitle = 'Our journey together';
  static const String lettersLabel = 'Letters';
  static const String lettersSubtitle = 'Open your heart';
  static const String comicsLabel = 'Comics';
  static const String comicsSubtitle = 'Stories made just for us';

  // ── External Links ───────────────────────────────────────
  static const String driveVideosUrl =
      'https://drive.google.com/drive/folders/1xOPq_XkqfB-Y6JZ6u1GEtPqZcC8HlI3N?usp=sharing';
  static const String drivePicturesUrl =
      'https://drive.google.com/drive/folders/1xI1KN-NF0doxe1yM5m-3sAZNvXqFn5Gj?usp=sharing';
}
