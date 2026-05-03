# Sociefy App — Test Plan

## 1. Methodology

### 1.1 Equivalence Partitioning (EP)
Input domains are divided into partitions where all values in a partition are expected to behave identically. Each partition is represented by exactly one test case. For every input field the following partition classes are identified and tested:

- **Valid partition**: inputs that the system should accept and process correctly.
- **Invalid partitions**: inputs that the system should reject, showing an appropriate error.

### 1.2 Boundary Value Analysis (BVA)
Defects cluster at the edges of partitions. BVA supplements EP by adding test cases at the exact boundaries between classes:

| Boundary | What is tested |
|----------|----------------|
| Empty string (0 characters) | Transition from "no input" to "some input" |
| Whitespace-only string | Visually non-empty but logically empty after `trim()` |
| Single-character string | Minimum valid non-empty input |
| Hour 0 (midnight) | AM/PM boundary — `hourOfPeriod` returns 12, period = AM |
| Hour 12 (noon) | AM/PM boundary — `hourOfPeriod` returns 12, period = PM |
| Single-digit month/day | Zero-padding boundary in date formatting |

### 1.3 User Journey Testing
End-to-end workflows are verified from the user's perspective: creating a society → joining it; creating an announcement → viewing it; navigating between all tabs.

---

## 2. Test Tools

| Tool | Purpose |
|------|---------|
| `flutter_test` (SDK) | Widget test framework — `testWidgets`, `WidgetTester`, `find`, `expect` |
| `integration_test` (SDK) | Full-app integration tests runnable on device/emulator |
| `flutter test` | Runs all test files and prints pass/fail output |
| `flutter test --coverage` | Generates `coverage/lcov.info` with line-level coverage data |
| `genhtml` | Converts `lcov.info` to an HTML coverage report |

Run tests with:
```bash
flutter test
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 3. Units Under Test

| Unit | File | Widget type |
|------|------|-------------|
| `Announcement` model | `lib/announcements.dart` | Dart class |
| `AnnouncementHome` | `lib/announcements.dart` | StatefulWidget |
| `CreateAnnouncementPage` | `lib/announcements.dart` | StatefulWidget |
| `HomePage` | `lib/home_screen.dart` | StatefulWidget |
| `MainTabs` | `lib/main_tabs.dart` | StatefulWidget |
| `MessagesPage` | `lib/messages_screen.dart` | StatelessWidget |
| `SignInPage` | `lib/sign_in_screen.dart` | StatefulWidget |
| `MyApp` | `lib/main.dart` | StatelessWidget |

---

## 4. Test Cases

### 4.1 Announcement Model — `dateTimeVenueString`

The `dateTimeVenueString` getter formats a `DateTime` and `TimeOfDay` into a human-readable string.  
Input partitions: AM time, PM time, noon boundary, midnight boundary, single-digit date parts, double-digit date parts, multi-word venue.

| ID | Partition | Input | Expected output |
|----|-----------|-------|-----------------|
| ANN-01 | EP: valid AM | `hour: 9, min: 30`, date `2025-03-05`, venue `Room A` | `"2025-03-05, 09:30 AM @ Room A"` |
| ANN-02 | EP: valid PM | `hour: 14, min: 45`, date `2025-11-25`, venue `Hall` | `"2025-11-25, 02:45 PM @ Hall"` |
| ANN-03 | BVA: noon boundary | `hour: 12, min: 0` | period = PM, `hourOfPeriod` = 12 → `"12:00 PM"` |
| ANN-04 | BVA: midnight boundary | `hour: 0, min: 0` | period = AM, `hourOfPeriod` = 12 → `"12:00 AM"` |
| ANN-05 | BVA: single-digit month/day | date `2025-03-05` | contains `"2025-03-05"` |
| ANN-06 | BVA: double-digit month/day | date `2025-11-25` | contains `"2025-11-25"` |
| ANN-07 | EP: multi-word venue | venue `"Main Hall Room 2A"` | ends with `"@ Main Hall Room 2A"` |
| ANN-08 | BVA: single-digit minutes | `min: 5` | contains `":05"` |

### 4.2 AnnouncementHome Widget

| ID | Scenario | Expected result |
|----|----------|-----------------|
| AH-01 | No announcements in list | Shows `"No announcements yet."` |
| AH-02 | Empty state | Shows `Post` button |
| AH-03 | AppBar | Title is `"Society Announcements"` |
| AH-04 | FAB | `FloatingActionButton` has label `"Post"` |
| AH-05 | FAB tap | Navigates to `CreateAnnouncementPage` |

### 4.3 CreateAnnouncementPage Widget

Form validation uses `TextFormField` validators; `_save()` also checks date/time selection.

| ID | Partition | Input | Expected result |
|----|-----------|-------|-----------------|
| CAP-01 | Initial render | Open page | 3 `TextFormField` widgets, `Pick date`, `Pick time`, `Save` button |
| CAP-02 | EP: invalid title | Title empty, desc + venue provided | Error: `"Please enter a title"` |
| CAP-03 | BVA: whitespace title | Title = `"   "` | Error: `"Please enter a title"` (after `trim()`) |
| CAP-04 | EP: invalid description | Desc empty, title + venue provided | Error: `"Please enter a description"` |
| CAP-05 | EP: invalid venue | Venue empty, title + desc provided | Error: `"Please enter a venue"` |
| CAP-06 | EP: missing date/time | All text fields valid, no date/time picked | SnackBar: `"Please pick date and time"` |

### 4.4 HomePage Widget

Society creation uses plain `TextField` widgets (not form fields); validation is `isNotEmpty`.

| ID | Partition | Input | Expected result |
|----|-----------|-------|-----------------|
| HP-01 | Empty state | No societies | Shows `"No societies yet."` |
| HP-02 | FAB present | Initial render | `FloatingActionButton` with `Icons.add` |
| HP-03 | AppBar | Initial render | Title `"Home"` |
| HP-04 | Dialog opens | Tap FAB | `AlertDialog` titled `"Create Society"` with 2 `TextField` widgets |
| HP-05 | EP: invalid — name empty | Name empty, desc `"A cool society"` | Dialog stays open |
| HP-06 | EP: invalid — desc empty | Name `"Chess Club"`, desc empty | Dialog stays open |
| HP-07 | EP: invalid — both empty | Both fields empty | Dialog stays open |
| HP-08 | EP: valid | Name `"Chess Club"`, desc `"A club…"` | Society added, dialog closed |
| HP-09 | Cancel | Enter text, tap Cancel | Dialog dismissed, society NOT added |
| HP-10 | Join button | Create a society, tap `Join` | `AlertDialog` titled `"Joined Society"` with society name |
| HP-11 | OK button | Tap OK in join dialog | Dialog dismissed |
| HP-12 | BVA: min valid input | Name `"X"`, desc `"Y"` | Society created successfully |
| HP-13 | Multiple societies | Create two societies | Both society names displayed |

### 4.5 MainTabs Widget

| ID | Scenario | Expected result |
|----|----------|-----------------|
| MT-01 | Initial render | `BottomNavigationBar` with labels `Home`, `Announcements`, `Messages` |
| MT-02 | Default tab | `currentIndex` = 0 |
| MT-03 | Page management | `IndexedStack` present |
| MT-04 | Home icon | `Icons.home` present |
| MT-05 | Announcements icon | `Icons.announcement` present |
| MT-06 | Messages icon | `Icons.message` present |
| MT-07 | Tap Announcements | `currentIndex` = 1 |
| MT-08 | Tap Messages | `currentIndex` = 2 |
| MT-09 | Home content | `"No societies yet."` visible on launch |
| MT-10 | Announcements content | `"Society Announcements"` visible after tap |
| MT-11 | Messages content | `"Messages / Forums go here"` visible after tap |
| MT-12 | Return to Home | `currentIndex` = 0 after switching back |

### 4.6 MessagesPage Widget

| ID | Scenario | Expected result |
|----|----------|-----------------|
| MP-01 | AppBar | Title `"Messages"` |
| MP-02 | Body | Shows `"Messages / Forums go here"` |
| MP-03 | Layout | Placeholder text is wrapped in a `Center` widget |
| MP-04 | Widget type | `MessagesPage` found in widget tree |

### 4.7 SignInPage Widget

| ID | Partition | Input | Expected result |
|----|-----------|-------|-----------------|
| SI-01 | Initial render | Open page | Email field, password field, `Sign In` button |
| SI-02 | EP: invalid — empty email | Email empty, password provided | Error: `"Please enter your email"` |
| SI-03 | EP: invalid — empty password | Email valid, password empty | Error: `"Please enter your password"` |
| SI-04 | EP: invalid — bad format | Email `"notanemail"` (no `@`) | Error: `"Please enter a valid email"` |
| SI-05 | EP: valid | Email `"test@example.com"`, password `"pass123"` | No validation errors shown |
| SI-06 | BVA: whitespace email | Email `"   "` | Error: `"Please enter your email"` (after `trim()`) |
| SI-07 | BVA: minimal email | Email `"a@b"` | No format error (contains `@`) |

### 4.8 MyApp Widget

| ID | Scenario | Expected result |
|----|----------|-----------------|
| APP-01 | Renders | `MaterialApp` found in widget tree |
| APP-02 | Home widget | `MainTabs` present |
| APP-03 | Material 3 | `theme.useMaterial3` = `true` |
| APP-04 | App title | `title` = `"Society App"` |
| APP-05 | Navigation | `BottomNavigationBar` present |
| APP-06 | Color scheme | `colorScheme.primary` is not null |

---

## 5. Integration / End-to-End Tests

| ID | Scenario | Performance target |
|----|----------|--------------------|
| INT-01 | Navigate to Messages tab | ≤ 2 seconds from launch |
| INT-02 | Create a society | ≤ 2 seconds end-to-end |
| INT-03 | UI navigation labels present | `Home`, `Announcements`, `Messages` all visible |
| INT-04 | All 3 tabs accessible with correct content | Each tab shows expected content |

---

## 6. Test Coverage Strategy

Every unit in §3 has a dedicated test file under `test/`. Coverage is measured with `flutter test --coverage`, targeting:
- All `build()` methods for widget rendering
- All validation branches in form validators
- All `if/else` paths in `_save()`, `_showCreateSocietyDialog()`, `_showJoinConfirmation()`
- The full `dateTimeVenueString` getter (both AM and PM branches, zero-padding branches)

---

## 7. Test Evidence
- **Test report**: pass/fail output from `flutter test` (see project CI output)
- **Coverage report**: `coverage/lcov.info` and `coverage/html/index.html`
- All test files committed to the `test/` directory in the repository
