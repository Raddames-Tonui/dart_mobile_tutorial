# Sunfyre Mobile Prototype

A learning-focused Flutter app: 4 tabs, no real backend calls yet, built to
teach widget-tree structure, mock API shape, custom (non-Material) styling,
and the three mobile storage tiers.

## Running it

```bash
flutter pub get
flutter run
```

Needs Flutter installed and either an emulator/simulator running or a
device plugged in. No backend, API key, or network access required —
everything on the Table and Form tabs is simulated locally.

## Project tree

```
lib/
  main.dart                  entry point, wraps app in Provider
  theme/
    app_theme.dart           design tokens — colors, spacing, text styles
                              (the "raw CSS" file — everything else reads
                              from here instead of Theme.of(context))
  models/
    item.dart                mirrors a row shape from the jOOQ guide
  services/
    mock_api_service.dart    fake GET/POST, same response envelope your
                              real Java backend would return
    storage_service.dart     wraps shared_preferences + flutter_secure_storage
  state/
    session_state.dart       ChangeNotifier — the sessionStorage analog
  widgets/
    raw_button.dart          hand-built, no ElevatedButton
    raw_input.dart           hand-built, no default Material underline
    raw_card.dart            hand-built, no Material Card
    raw_table.dart           hand-built, no Material DataTable
  pages/
    home_shell.dart          ROOT of the navigation tree — IndexedStack of
                              4 tabs + a custom bottom nav bar
    dashboard_page.dart      "Tree" tab — visually explains the app's own tree
    table_page.dart          "Table" tab — mock GET, filter, RawTable
    form_page.dart           "Form" tab — validated form, mock POST
    form_success_page.dart   pushed onto the Navigator stack after submit
    storage_page.dart        "Storage" tab — the three tiers, side by side
```

## The navigation tree, in plain terms

```
MaterialApp
└─ HomeShell
    └─ IndexedStack                 <- tabs: all 4 pages exist at once,
        ├─ DashboardPage               only visibility toggles. State
        ├─ TablePage                   persists when you switch away.
        ├─ FormPage
        │   └─ (push) FormSuccessPage  <- a *stack* push, not a tab.
        │                                 Only exists after a successful
        │                                 submit; pop() removes it.
        └─ StoragePage
    └─ RawBottomNav
```

Two different tree mechanics, both included on purpose:

- **IndexedStack** — like keeping four browser tabs open. Nothing is
  destroyed when you switch tabs.
- **Navigator.push/pop** — like a normal in-page navigation stack (or
  browser back/forward). FormSuccessPage only exists on that stack, never
  as a tab of its own.

## Storage — the three tiers

| Tier | File | Web equivalent | Notes |
|---|---|---|---|
| `shared_preferences` | `storage_service.dart` | `localStorage` | Plaintext. Never store tokens here. |
| `flutter_secure_storage` | `storage_service.dart` | a secure, HttpOnly cookie | iOS Keychain / Android Keystore. Tokens belong here. |
| `Provider` / `ChangeNotifier` | `session_state.dart` | `sessionStorage` | RAM only — gone when the app process dies, not just backgrounded. |

Try it on the **Storage** tab: save a value into each tier, then fully kill
and reopen the app (not just background it) — the `shared_preferences` and
`flutter_secure_storage` values survive, the session value doesn't.

Cookies don't have a direct Flutter equivalent — Dio/http don't manage a
cookie jar automatically the way a browser does. Your Java backend's
`BEARER` mode (`X-Client-Type: BEARER`) is the intended path for a mobile
client like this one: it returns the JWT in the response body/headers
instead of setting a cookie, and you store it with `flutter_secure_storage`
and attach it as an `Authorization` header on every request.

## Where "pure raw CSS" shows up

Flutter has no stylesheet — every widget is styled with Dart properties.
This prototype leans into that by skipping Material's pre-styled widgets
(`ElevatedButton`, `Card`, `DataTable`, the default `TextField` look) and
building `RawButton`, `RawCard`, `RawTable`, and `RawInput` from bare
`Container` + `BoxDecoration` + `Text(style: ...)`, all pulling their
values from `theme/app_theme.dart`. That file is the closest thing to a
stylesheet you'll get — a single place that defines every color, spacing
value, and text style used across the app.

## What's new since the first version

Everything below was added to mirror the React back-office app's
architecture doc (theme system, toasts, masking, skeletons) — see that
doc's Part 3 translation table for the full concept-by-concept mapping.

| Feature | Files | Notes |
|---|---|---|
| Theme system (4 accents × light/dark × high-contrast) | `theme/app_palette.dart`, `theme/theme_controller.dart` | Persisted via `shared_preferences`. Every widget reads `context.watch<ThemeController>().colors` instead of a hardcoded color — this is the single "stylesheet" now. |
| Sidebar | `pages/home_shell.dart` (`_RawDrawer`) | A standard Flutter `Drawer`, opened via the AppBar hamburger. Holds a quick dark-mode toggle and a push to Settings. |
| Settings screen | `pages/settings_page.dart` | Dark/light switch, high-contrast switch, 4 accent swatches, language chips, toast test buttons. Pushed from the Drawer — not a tab. |
| Toasts (Sonner equivalent) | `services/toast_service.dart` | Custom `Overlay`-based, no package. `ToastService.show(context, message: ..., type: ToastType.success)`. |
| Language switching | `state/locale_controller.dart` | Deliberately minimal — a `Map<AppLanguage, Map<String,String>>`, not the full `intl`/`.arb` toolchain. Wired into the bottom nav labels and Settings page as a demo. |
| Cart | `state/cart_state.dart`, `pages/cart_page.dart` | Provider-shared state; add items from the Table tab's row "+" icon, view/clear them from the AppBar cart icon (with a live badge count). |
| Masked values | `widgets/masked_value.dart`, `state/visibility_controller.dart` | Shown on the Table tab ("Linked Account"). Re-masks automatically when the app leaves the foreground — via `AppLifecycleState`, the mobile equivalent of the web app's tab-hidden/blur handling. |
| Skeleton loading | `widgets/skeleton.dart` | `RawTableSkeleton` replaces the old spinner on the Table tab while the mock "GET" is in flight. Hand-rolled shimmer (`AnimationController` + `LinearGradient` sweep), no `shimmer` package. |
| Mascot | `widgets/mascot.dart` | A small bouncing owl — appears in the AppBar, the Drawer header, and Settings. Built with a looping `AnimationController`, no Rive/Lottie dependency (swap in a real character file later if you want proper animation). |

## Wiring it to your real Java backend later

Only `mock_api_service.dart` needs to change. Keep the method signatures
(`fetchItems()`, `createItem()`), swap the `Future.delayed()` bodies for
real `Dio` calls against your `/api/rest/items` endpoints (see the Sunfyre
jOOQ guide for the exact query params — `?q=`, `?status.eq=`, `?sort=`,
`?page=`/`?pageSize=`), and store the returned bearer token with
`StorageService.saveSecure()`. Nothing in `pages/` or `widgets/` needs to
know the difference.

Recommended next additions when you do wire it up:
- `dio` for the actual HTTP client (easier auth header injection than `http`)
- Certificate pinning (`dio_certificate_pinning`) — worth doing early given
  the fintech context
- A Riverpod or Provider-based auth state that mirrors this prototype's
  `SessionState` pattern, holding the decoded `AuthPrincipal`-equivalent
  data client-side
