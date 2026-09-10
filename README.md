# in_class_01_tabs

In-Class 01 — Tabs, Widgets & Assets Lab.

Flutter is not installed on the machine this project was authored on, so the
native platform folders (`android/`, `ios/`, `web/`, etc.) have not been
generated yet. `lib/main.dart`, `pubspec.yaml`, and `assets/images/campus.png`
are ready to go — finish setup with the steps below.

## Setup

```bash
cd in_class_01_tabs
flutter create .        # generates android/ ios/ web/ without touching lib/ or pubspec.yaml
flutter pub get
flutter run
```

`flutter create .` (run *inside* the existing project folder, with the dot)
scaffolds the missing platform folders while leaving `lib/main.dart` and
`pubspec.yaml` untouched.

## What's implemented

- 4 tabs via `TabController` / `TabBar` / `TabBarView`
- Bottom app bar via `Scaffold.bottomNavigationBar`
- Each tab has its own background color (`Container` wrapping the content)
- Tab 1: styled `Text` + `ElevatedButton` that opens an `AlertDialog`
- Tab 2: `Image.network` + `Image.asset` (`assets/images/campus.png`) + `TextField`
- Tab 3: `ElevatedButton` that shows a `SnackBar`
- Tab 4: `ListView` of `Card`-wrapped `ListTile`s
