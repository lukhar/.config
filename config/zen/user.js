// Framework laptop's Zen profile; linked into it by modules/home.
// Zen reads user.js at every start and copies these over prefs.js.

// load chrome/userChrome.css (config/zen/userChrome.css)
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
// dark browser UI and dark-preferring sites, matching the rest of the desktop
user_pref("layout.css.prefers-color-scheme.content-override", 0);
// blank pages and sites without a background of their own: solarized base03
user_pref("browser.display.background_color.dark", "#002b36");
