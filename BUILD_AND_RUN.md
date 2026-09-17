# Get This App Running On Your Phone

Everything from a bare Windows machine to a working APK on your Android
phone - written once so you can just follow it top to bottom instead of
juggling chat messages.

> **Quick note on "Visual Studio":** this guide uses **VS Code**
> (code.visualstudio.com) - the small, free editor with a Flutter
> extension. It's a different download from the full **Visual Studio**
> (the C#/.NET/C++ IDE), which has no Flutter support at all. If the
> icon on your desktop is the purple infinity one, that's VS Code and
> you're already set. If it's the purple "VS" with a different mark,
> that's full Visual Studio - install VS Code alongside it, they don't
> conflict.

---

## Part 1 - One-time computer setup

Do this section once. Skip anything you've already got.

### 1. Install the Flutter SDK

1. Go to `docs.flutter.dev` -> Get Started -> Windows, download the SDK zip.
2. Extract it somewhere short with no spaces - `C:\src\flutter` is the
   standard choice. Don't extract into `Program Files`.
3. Add `C:\src\flutter\bin` to your PATH:
   - Windows key -> search "environment variables" -> **Edit the system
     environment variables** -> **Environment Variables** button
   - Under "User variables", select `Path` -> **Edit** -> **New** ->
     paste `C:\src\flutter\bin`
   - OK your way out of all the dialogs.
4. Open a **new** terminal (PowerShell) and run:
   ```
   flutter --version
   ```
   If it prints a version number, PATH is working.

### 2. Install Android Studio (for the Android SDK, not to write code in)

1. Download from `developer.android.com/studio`, run the installer.
2. On first launch, use the **Standard** setup - this pulls in the
   Android SDK, SDK Platform-Tools (`adb`), and a system image.
3. Let it finish downloading everything before moving on.

### 3. Check your setup

```
flutter doctor
```

This prints a checklist. If it complains about Android licenses:

```
flutter doctor --android-licenses
```

Press `y` and Enter for each license prompt. Re-run `flutter doctor`
until Android toolchain shows a green check. (A complaint about Visual
Studio/C++ desktop workload can be ignored - that's for building
Windows desktop apps, not Android.)

### 4. Install VS Code + the Flutter extension

1. Install VS Code from `code.visualstudio.com` if you don't have it.
2. Open VS Code -> Extensions panel (`Ctrl+Shift+X`) -> search
   **Flutter** -> install the one by **Dart Code**. It pulls in the Dart
   extension automatically.

### 5. Put your phone in developer mode

1. On the phone: **Settings -> About phone** -> tap **Build number**
   7 times in a row. It'll say "You are now a developer."
2. Go back to **Settings -> System -> Developer options** -> turn on
   **USB debugging**.

### 6. Connect the phone and confirm Flutter can see it

1. Plug the phone into the PC with a USB cable.
2. If the phone shows a USB mode picker, choose **File transfer (MTP)**
   - not "charging only."
3. The phone will pop up **"Allow USB debugging?"** - check "always
   allow from this computer" and tap **Allow**.
4. In a terminal:
   ```
   flutter devices
   ```
   Your phone should show up by name. If it doesn't, unplug/replug, or
   try a different USB cable - some cables are charge-only.

**Setup done. Everything below is what you'll actually repeat each time.**

---

## Part 2 - Open the project

1. Unzip the project folder somewhere simple, e.g. `C:\dev\sunfyre_mobile_prototype`.
2. In VS Code: **File -> Open Folder** -> select that folder.
3. Open a terminal inside VS Code (`` Ctrl+` ``) and run:
   ```
   flutter pub get
   ```
   This downloads the three packages the app uses (`provider`,
   `shared_preferences`, `flutter_secure_storage`). Needs internet the
   first time; after that it's cached.

---

## Part 3 - Run it live on your phone (fastest way to test)

This is the option to reach for while you're actively poking at the app
- no APK file involved, changes show up almost instantly.

1. With the phone still plugged in, look at the **bottom-right corner**
   of the VS Code window - it shows the current run target. Click it
   and pick your phone from the list.
2. Press **F5** (or the green ▶ play icon top-right, or **Run -> Start
   Debugging**).
3. VS Code compiles a debug build and installs it on your phone
   automatically. First run takes a minute or two; it gets much faster
   after that.
4. Once it's running: edit any `.dart` file, save (`Ctrl+S`) - the app
   updates on your phone in under a second, no reinstall. This is
   Flutter's "hot reload," and it's the main reason to use this option
   over building an APK every time.
5. To stop: click the red square in the debug toolbar, or just close
   the debug session.

---

## Part 4 - Build an actual installable APK file

Use this when you want a file you can keep on the phone without a
cable, share with someone else to test, or just hold onto.

1. Open the VS Code terminal (`` Ctrl+` ``) and run:
   ```
   flutter build apk --release
   ```
   First build takes a few minutes - Gradle downloads build tooling the
   first time. Later builds are faster.

   > This uses Flutter's default debug signing key for the release
   > build, which is completely fine for testing on your own device.
   > You'd only need a real signing key if you were publishing to the
   > Play Store.

2. When it finishes, the file is at:
   ```
   build\app\outputs\flutter-apk\app-release.apk
   ```

3. **Install it on your connected phone directly:**
   ```
   flutter install
   ```
   or, equivalently:
   ```
   adb install build\app\outputs\flutter-apk\app-release.apk
   ```

4. **Or install it without a cable** - copy `app-release.apk` to your
   phone any way you like (email it to yourself, upload to Google
   Drive/WhatsApp/USB drive), open it from the phone's Downloads app,
   and tap it. Android will ask permission to "install unknown apps"
   for whichever app you opened it from the first time - allow it, then
   tap **Install**.

5. Look for **"Sunfyre Mobile Prototype"** in your app drawer.

---

## Cheat sheet - commands you'll actually reuse

| What you want | Command |
|---|---|
| Confirm phone is connected | `flutter devices` |
| Get/update packages after pulling new code | `flutter pub get` |
| Run live with hot reload | `flutter run` (or press F5 in VS Code) |
| Build an installable APK | `flutter build apk --release` |
| Install the APK on a connected phone | `flutter install` |
| Full health check if something's broken | `flutter doctor -v` |

---

## Troubleshooting

**`flutter devices` shows nothing**
Unplug and replug the cable, check it's a data cable (not charge-only),
make sure you tapped **Allow** on the "Allow USB debugging?" popup on
the phone - it only appears once per computer unless you revoke it.

**Gradle build fails the first time with a download error**
Just re-run `flutter build apk --release` - it's usually a slow/dropped
download of Gradle itself, and it resumes on retry.

**"App not installed" when tapping the APK on the phone**
Usually means an older version with a different signature is already
installed. Uninstall the existing "Sunfyre Mobile Prototype" app first,
then try again.

**Android blocks the install with a Play Protect warning**
Expected for any APK not distributed through the Play Store. Tap
"Install anyway" / "More details -> Install anyway."
