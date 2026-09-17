# Flutter Masterplan — 4 Weeks (Java + React → Mobile)

**Goal:** Go from zero Flutter to a working app that talks to your Java backend, with fintech-grade security, deployed to Play Store (and iOS if you have a Mac).

**Reality check:** Fully achievable. Your background compresses the learning curve a lot:
- React component/props/state → Flutter Widget/constructor params/State class (near 1:1 mental model)
- JS Promises/async-await → Dart Futures/async-await (same syntax basically)
- Java's strong typing, classes, interfaces → Dart feels like "Java with better syntax"

The one hard constraint: **iOS builds and App Store submission require a Mac** (Xcode only runs on macOS). You can develop the Dart/Flutter code on any OS, but the final iOS build + TestFlight/App Store upload needs a Mac at some point. Play Store has no such restriction.

---

## Week 1 — Dart, Flutter Basics, Setup

### Days 1–2: Environment + Dart language
- Install Flutter SDK, Android Studio (+ Android SDK/emulator), VS Code with Flutter/Dart plugins
- If you have a Mac: install Xcode + accept licenses + set up an iOS Simulator now (saves pain later)
- Run `flutter doctor` until everything is green
- Learn Dart basics: variables, null safety (`?`, `!`, `late`), classes, mixins, `async`/`await`/`Future`, collections
  - Coming from Java, focus on: **null safety** (stricter/different from Java's nullability), **extension methods**, **mixins** (no direct Java equivalent — closer to interfaces with default methods)

### Days 3–4: Widgets & layout
- StatelessWidget vs StatefulWidget (map mentally: StatelessWidget ≈ pure function component; StatefulWidget ≈ component with `useState`)
- Core widgets: `Scaffold`, `Column`/`Row` (≈ flexbox), `Container`, `ListView`, `Stack`
- `setState()` and the widget rebuild cycle (≈ React re-render on state change)
- Build 3–4 tiny static screens (profile card, list, form) with no logic yet

### Days 5–7: Navigation + basic state management
- Navigator 1.0 basics (`push`/`pop`), then move to **go_router** (declarative routing, closer to React Router)
- Intro to a state management approach — pick **Riverpod** (recommended for you: less boilerplate than Bloc, feels closer to React Context/hooks than Provider does)
- Build a small multi-screen app (e.g. a counter + list app) using Riverpod for state

**Checkpoint:** You can build static/interactive screens, navigate between them, and manage simple state without setState spaghetti.

---

## Week 2 — Networking, Backend Integration, Data

### Days 8–9: HTTP & JSON
- `http` or `dio` package (dio recommended — interceptors, easier auth header injection, timeouts)
- JSON serialization: manual first, then `json_serializable`/`freezed` for codegen (≈ like DTOs in Java, or `JSON.parse`/interfaces in TS)
- Error handling patterns for network calls (timeouts, 4xx/5xx, retries)

### Days 10–12: Connect to your Java backend
- Point Dio at your actual Spring Boot / Java REST endpoints
- Model your existing DTOs as Dart classes
- Implement: login/auth call, fetch list, fetch detail, create/update (full CRUD against your real API)
- Handle CORS-equivalent issues (mobile doesn't have browser CORS, but you'll deal with cert/self-signed issues if backend isn't on real TLS — see security section)

### Days 13–14: Forms & UX polish
- `Form` + `TextFormField` + validators (≈ controlled inputs in React)
- Loading/error/empty states for each screen (async state machine pattern)
- Pull-to-refresh, pagination if your API supports it

**Checkpoint:** Your app can authenticate against your Java backend and do full CRUD against real endpoints.

---

## Week 3 — Build the Real App + Security Hardening

Pick **one**: your existing monitoring system (reuse real endpoints, less design work) or a sample e-commerce app (more surface area to practice: cart, checkout, product list, order history). Given you want fintech-relevant skills, e-commerce is arguably more useful practice (payment-adjacent flows) even if fake.

### Days 15–17: Architecture + feature build
- Adopt a simple clean-ish structure: `data/` (API clients, models) → `domain/` (business logic) → `presentation/` (widgets, Riverpod providers)
- Build out the core flows: auth → list/browse → detail → action (add to cart / acknowledge alert) → submit
- Write a few widget tests (Flutter's testing is quite good, similar in spirit to Jest/RTL)

### Days 18–21: Fintech-grade security (this is the important part for you)

This is where Flutter differs meaningfully from web, since you're used to reasoning in terms of cookies/localStorage/sessionStorage. Here's the mapping and what to actually use:

| Web concept | Flutter equivalent | Notes |
|---|---|---|
| `localStorage` | `shared_preferences` | **Plaintext**, unencrypted, sandboxed to app. Fine for non-sensitive prefs (theme, locale). **Never** put tokens here. |
| `sessionStorage` | In-memory state (Riverpod provider / singleton) | Lives only while app process is alive; gone on full app kill — closest analog. |
| Cookies (with `HttpOnly`, `Secure`) | No native cookie jar — HTTP client doesn't auto-manage cookies like a browser | If your backend uses cookie-based sessions, use a cookie manager plugin (`dio_cookie_manager` + `cookie_jar`) to persist/send them manually. Otherwise switch to token-based auth (JWT in headers), which is the more common mobile pattern. |
| Secure, sensitive storage (nothing quite like this exists on web) | `flutter_secure_storage` | Backed by **iOS Keychain** and **Android Keystore**. This is where JWTs, refresh tokens, and any credential-like data belong. |
| HTTPS/TLS | Same TLS, but add **certificate pinning** | Use `dio` with a pinning interceptor (e.g. `dio_certificate_pinning` or platform channel + `http_certificate_pinning`) so a compromised CA or MITM proxy can't intercept traffic — standard for fintech apps. |
| CSP / XSS mitigation | Not directly applicable (no DOM) | Your equivalent risk is deep links / WebViews — sanitize any URL you load in a WebView, disable JS in WebViews unless required. |
| CSRF tokens | Usually N/A for pure token-auth APIs | If your Java backend still uses session+CSRF for some endpoints, you'll need to fetch and forward the CSRF token manually per request. |

Additional fintech-specific things to actually implement this week:
1. **Token storage & refresh flow**: access token in memory, refresh token in `flutter_secure_storage`, silent refresh via Dio interceptor.
2. **Biometric re-auth**: `local_auth` package — require Face ID/fingerprint before showing balances or authorizing an action.
3. **Root/jailbreak detection**: packages like `freerasp` or `safe_device` — refuse to run (or degrade) on compromised devices, common fintech App Store/compliance requirement.
4. **Screen recording/screenshot protection**: prevent sensitive screens from being captured (`flutter_windowmanager` on Android `FLAG_SECURE`, similar iOS handling).
5. **Obfuscation on release builds**: `flutter build apk --obfuscate --split-debug-info=./debug-info` (and equivalent for iOS) so decompiled code doesn't leak business logic.
6. **No sensitive data in logs**: strip `print`/logging of tokens and PII in release builds.
7. **Backend TLS**: make sure your Java backend actually serves valid TLS certs (not self-signed) before you wire in cert pinning, or pinning will just break everything.

**Checkpoint:** Your app authenticates, stores tokens securely (not shared_preferences), pins certs, and locks sensitive screens behind biometrics.

---

## Week 4 — Testing, CI/CD, Deployment

### Days 22–24: Testing & polish
- Widget tests for critical flows (login, checkout/action submission)
- Manual testing on a real Android device and (if available) real iPhone — emulators lie about performance and biometrics behavior
- App icons, splash screen (`flutter_launcher_icons`, `flutter_native_splash`)
- Basic crash reporting (Firebase Crashlytics or Sentry) — useful for any real fintech-adjacent app

### Days 25–26: Android → Play Store
- Generate a signing keystore, configure `build.gradle` signing config
- Build release AAB: `flutter build appbundle --obfuscate --split-debug-info=...`
- Create Play Console account ($25 one-time), fill store listing, privacy policy (required, especially for anything finance-adjacent), upload to Internal Testing track first
- Play Store review is usually fast (hours to ~2 days) for a first internal release

### Days 27–28: iOS → App Store (needs a Mac)
- Enroll in Apple Developer Program ($99/year) — do this as early as possible, approval can take a day or two
- Configure signing in Xcode (automatic signing is fine to start), set bundle ID, provisioning profile
- Build: `flutter build ipa`
- Upload via Transporter or Xcode to App Store Connect, submit to TestFlight first
- Apple review for a first submission can take 1–3 days; budget for at least one rejection round if you're not fully attentive to their guidelines (privacy manifest, permissions usage strings, etc.)

### Day 29–30: Buffer
- Use these for whatever slipped (App Store rejection fixes, Play Store policy questions, or just catching up if Week 3's security section took longer — it usually does).

---

## Realistic Notes

- **Timeline risk areas**: certificate pinning + secure storage debugging (Week 3) and Apple's review/signing process (Week 4) are the two places people lose days. Everything else is fairly linear.
- **If you don't have a Mac**: you can still finish everything through Play Store deployment in the 4 weeks. iOS becomes "do it later when you get Mac access" — the Dart/Flutter code doesn't change, only the build/signing/submission step.
- **Package recommendations recap**: `dio`, `riverpod`, `go_router`, `flutter_secure_storage`, `local_auth`, `freerasp`/`safe_device`, `dio_certificate_pinning`, `json_serializable`/`freezed`.
