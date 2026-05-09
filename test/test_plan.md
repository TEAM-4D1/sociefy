# Sociefy — Test Plan

## 1. Purpose & Scope

This document specifies the test plan for the Sociefy Flutter application
covering every unit of code in `lib/`. It defines the methodology used to
derive test cases, traces each test back to the functional requirement it
verifies, and records the input-partition coverage for every validated input.

The test plan is implemented by the Dart test files under `test/` and
exercised through `flutter test` (unit / widget) and
`flutter test integration_test/` (integration). Coverage is collected with
`flutter test --coverage` and exported to `coverage/lcov.info`.

## 2. Methodology

Three complementary techniques are used to derive test cases:

### 2.1 Equivalence Partitioning (EP)
For every input field the input domain is split into classes whose members
should behave identically. One representative case is selected per class.
Where a system requirement permits multiple invalid forms (e.g. empty,
whitespace-only, format-violating), each invalid sub-class is treated as a
distinct partition rather than collapsed into a single "invalid" case.

### 2.2 Boundary Value Analysis (BVA)
Defects cluster at partition edges. Boundaries that are explicitly tested:

| Boundary | Reason it is tested |
|----------|---------------------|
| Empty string | "no input" → "some input" transition |
| Whitespace-only string | Visually non-empty but logically empty after `trim()` |
| Length = N − 1 / N / N + 1 | Below / at / above any minimum-length validator (e.g. password ≥ 6, display name ≥ 2) |
| `@` with no domain | Minimum email format validator (`contains('@')`) |
| Single-digit vs two-digit date / time components | Zero-padding logic in date and time formatting |

### 2.3 User-Journey / Integration Testing
End-to-end flows are exercised against the real widget tree to catch
defects that only manifest from interaction between components — e.g. tab
state persistence in `IndexedStack`, navigation between sign-in and the
authenticated shell, and cross-screen state propagation through `AppState`.

### 2.4 Firebase Isolation
Widget tests construct `AppState(skipFirebase: true)` so the auth listener
is not registered during a test. `AuthService.currentUser` and the Firestore
loaders catch and `debugPrint` the "no Firebase app" error rather than
throwing, allowing screens that depend on them to render under test without
booting the Firebase SDK.

## 3. Tools

| Tool | Purpose |
|------|---------|
| `flutter_test` | Unit + widget test framework — `testWidgets`, `WidgetTester`, `find`, `expect` |
| `integration_test` | Full-app integration tests runnable on device or emulator |
| `flutter test` | Test runner; produces pass/fail report |
| `flutter test --coverage` | Generates line-level coverage in `coverage/lcov.info` |
| `genhtml` | Renders `lcov.info` as HTML for inspection |

```bash
flutter test                          # run everything
flutter test --coverage               # with coverage
genhtml coverage/lcov.info -o coverage/html
```

## 4. Units Under Test

| # | Unit | File | Type |
|---|------|------|------|
| U1 | `AppState` | `lib/providers/app_state.dart` | `ChangeNotifier` (state container) |
| U2 | `AuthService` | `lib/services/auth_service.dart` | Service (Firebase Auth wrapper) |
| U3 | `MessageService` | `lib/services/message_service.dart` | Service |
| U4 | `SocietyService` | `lib/services/society_service.dart` | Service (Firestore membership wrapper) |
| U5 | `MyApp` | `lib/main.dart` | Root `StatelessWidget` |
| U6 | `MainTabs` | `lib/main_tabs.dart` | `StatefulWidget` (bottom-nav shell) |
| U7 | `SignInScreen` | `lib/screens/sign_in_screen.dart` | `StatefulWidget` |
| U8 | `RegisterScreen` | `lib/screens/register_screen.dart` | `StatefulWidget` |
| U9 | `CommitteeSignInScreen` | `lib/screens/committee_sign_in_screen.dart` | `StatefulWidget` |
| U10 | `SocietyBrowserScreen` | `lib/screens/society_browser_screen.dart` | `StatelessWidget` |
| U11 | `SavedEventsScreen` | `lib/screens/saved_events_screen.dart` | `StatelessWidget` |
| U12 | `MessagesPage` | `lib/screens/messages_screen.dart` | `StatelessWidget` |
| U13 | `ProfileScreen` | `lib/screens/profile_screen.dart` | `StatelessWidget` |
| U14 | Domain models | `lib/models/{society,event,announcement,committee_member}.dart` | Plain Dart classes |

## 5. Requirements Traceability

Every functional requirement from Iteration 1 maps to one or more test
suites in this plan.

| Req | Description (Iteration 1) | Verified by |
|-----|--------------------------|-------------|
| FR-1 | Save events to a personal calendar | §6.1 (`AppState` save / unsave / persist), §6.11 (Saved Events screen) |
| FR-2 | Browse a list of available societies | §6.10 (`SocietyBrowserScreen`), §6.1 (`AppState.societies`) |
| FR-3 | Join / leave a society | §6.1 (`AppState.joinSociety`, `leaveSociety`, duplicate-guard) |
| FR-4 | Authenticate (sign in / register) | §6.7, §6.8, §6.9, §6.2 (`AuthService`) |
| FR-5 | Restrict actions to committee / admin | §6.1 (`isAdmin` flag), §6.9 (`CommitteeSignInScreen`) |
| FR-6 | Display invalid-action errors | §6.7–§6.9 (validation suites), §6.2 (auth-failure SnackBar) |
| FR-7 | Post announcements (committee) | §6.1 (`AppState.createAnnouncement`) |
| FR-8 | Browse joined societies | §6.13 (`ProfileScreen`), §6.1 (`mySocieties`) |

## 6. Test Cases

### 6.1 `AppState` — `test/app_state_unit_test.dart` (41 cases)

State-container logic is tested in isolation by constructing
`AppState(skipFirebase: true)` and exercising the public API.

| ID | Partition / Boundary | Scenario | Expected |
|----|----------------------|----------|----------|
| AS-01 | Default state | Fresh instance | `userId == null`, `isAdmin == false`, `isAuthenticated == false`, `isGuest == false` |
| AS-02 | EP: authenticated user | `login(userId: 'u1')` | `isAuthenticated == true`, `isGuest == false` |
| AS-03 | EP: guest user | `login(userId: 'guest')` | `isAuthenticated == true`, `isGuest == true` |
| AS-04 | EP: admin login | `login(userId: 'u1', isAdmin: true)` | `isAdmin == true` |
| AS-05 | BVA: empty userId | `login(userId: '')` | `isAuthenticated == false` |
| AS-06 | State reset | `login` then `logout` | All flags / lists / pendingAdmin reset |
| AS-07 | EP: join idempotency | `joinSociety('s1')` twice | `isJoined('s1') == true`, list contains exactly one entry |
| AS-08 | EP: leave when not joined | `leaveSociety('s1')` without prior join | No throw, list unchanged |
| AS-09 | EP: leave joined society | join then leave | `isJoined('s1') == false` |
| AS-10 | Filter: joined / available | join `s1`, leave `s2` from a populated list | `joinedSocieties` and `availableSocieties` are disjoint |
| AS-11 | EP: save event idempotency | `saveEvent('e1')` twice | One entry, `isEventSaved('e1') == true` |
| AS-12 | EP: unsave when not saved | `unsaveEvent('e1')` | No throw |
| AS-13 | Filter: saved events | save `e1` from a populated list | `savedEvents` contains only `e1` |
| AS-14 | Helper | `eventsForSociety(id)` with matching id | Returns only events for that society |
| AS-15 | Helper: societyNameById missing | Unknown id | Returns `'Society'` (sentinel) |
| AS-16 | EP: createSociety | Provide name / category / description | New society present in `societies`, ID is slugified |
| AS-17 | EP: createAnnouncement | Provide all fields | Inserted at index 0 of `announcements` |
| AS-18 | EP: createEvent | Provide all fields + date | Inserted at index 0 of `events` |
| AS-19 | EP: setAdminPending | Toggle | `isPendingAdminLogin` reflects value |
| AS-20 | Stream lifecycle | `dispose()` | No "stream still listening" error |
| (AS-21 – AS-41 cover further branches: refreshFeed clearing, multiple-society filtering, leave-then-rejoin, login-with-userId-already-set, eventsForSociety name-fallback, etc.) |

### 6.2 `AuthService` — covered indirectly via `register_screen_test.dart` and `sign_in_screen_test.dart`
| ID | Partition | Scenario | Expected |
|----|-----------|----------|----------|
| AU-01 | EP: Firebase unavailable | `register()` when Firebase not initialised | Returns `null`, does not throw |
| AU-02 | EP: Firebase unavailable | `signIn()` when Firebase not initialised | Returns `null`, does not throw |
| AU-03 | EP: Firebase unavailable | `currentUser` getter when Firebase not initialised | Returns `null`, does not throw (regression for the bug that broke the register-screen suite) |

### 6.3 `MessageService` — `test/message_service_test.dart`
Construction smoke test guarding the public API surface.

### 6.4 Domain models — `test/announcements_test.dart` (19 cases)
Pure-Dart formatter / equality / serialisation tests for `Announcement`.

| ID | Partition | Input | Expected |
|----|-----------|-------|----------|
| MD-01 | EP: AM time | `hour 9, min 30` | `"09:30 AM"` |
| MD-02 | EP: PM time | `hour 14, min 45` | `"02:45 PM"` |
| MD-03 | BVA: noon | `hour 12, min 0` | `"12:00 PM"` |
| MD-04 | BVA: midnight | `hour 0, min 0` | `"12:00 AM"` |
| MD-05 | BVA: single-digit minute | `min 5` | contains `":05"` |
| MD-06 | BVA: single-digit month/day | `2025-03-05` | contains `"2025-03-05"` |
| MD-07 | BVA: two-digit month/day | `2025-11-25` | contains `"2025-11-25"` |
| MD-08 | EP: multi-word venue | `"Main Hall Room 2A"` | string ends with `"@ Main Hall Room 2A"` |
| MD-09 | Equality | Two `Announcement`s with same ID | `==` returns true |
| MD-10 | Equality | Different IDs | `==` returns false |
| (MD-11 – MD-19 cover comment add / remove, like toggle, fromFirestore null-safety, etc.) |

### 6.5 `MyApp` — `test/main_test.dart` and `test/widget_test.dart`
| ID | Scenario | Expected |
|----|----------|----------|
| APP-01 | Renders | `MaterialApp` in tree |
| APP-02 | Material 3 enabled | `theme.useMaterial3 == true` |
| APP-03 | Title | `title == 'Society App'` |

### 6.6 `MainTabs` — `test/main_tabs_test.dart` (12 cases)
| ID | Partition | Scenario | Expected |
|----|-----------|----------|----------|
| MT-01 | Render | Initial render | `BottomNavigationBar` with labels `Home/Feed`, `Discover`, `Messages`, `Saved`, `Profile` |
| MT-02 | Render | Item count | `items.length == 5` |
| MT-03 | Default | Initial selection | `currentIndex == 0` |
| MT-04 | Page management | Page swapping | `IndexedStack` keeps inactive pages alive |
| MT-05 | Type | Bar layout | `BottomNavigationBarType.fixed` |
| MT-06 | Icons | All five | `dynamic_feed`, `search`, `message`, `bookmark`, `person` present |
| MT-07–10 | EP: tab switching | Tap each tab | `currentIndex` advances to 1, 2, 3, 4 respectively |
| MT-11 | EP: round-trip | Tap away then back to Home | `currentIndex == 0` |
| MT-12 | BVA: tap same tab | Tap Discover twice | `currentIndex` unchanged |

### 6.7 `SignInScreen` — `test/sign_in_screen_test.dart` (9 cases)
| ID | Partition | Input | Expected |
|----|-----------|-------|----------|
| SI-01 | Render | Initial | Email field, password field, `Sign In` button |
| SI-02 | EP: invalid — empty email | Email empty | `"Please enter your email"` |
| SI-03 | EP: invalid — empty password | Password empty | `"Please enter your password"` |
| SI-04 | EP: invalid — bad format | Email `"notanemail"` | `"Please enter a valid email"` |
| SI-05 | EP: valid | Email `"test@example.com"`, password `"pass123"` | No errors |
| SI-06 | BVA: whitespace email | Email `"   "` | `"Please enter your email"` (after `trim()`) |
| SI-07 | BVA: minimal email | Email `"a@b"` | No format error |
| SI-08 | EP: guest button | Tap "Continue as guest" | `AppState.isGuest == true` |
| SI-09 | EP: register link | Tap "Register" | `RegisterScreen` is pushed |

### 6.8 `RegisterScreen` — `test/register_screen_test.dart` (20 cases)
| ID | Partition | Input | Expected |
|----|-----------|-------|----------|
| RG-01 | Render | Initial | 3 form fields + Register button |
| RG-02 | EP: empty form | All blank | All three "Please enter…" errors |
| RG-03 | BVA: name = 1 char | `"J"` | `"Display name must be at least 2 characters"` |
| RG-04 | BVA: name = 2 chars | `"Jo"` | No error |
| RG-05 | EP: special chars in name | `"O'Brien-Smith"` | No error |
| RG-06 | EP: invalid email | `"invalidemail"` | `"Please enter a valid email"` |
| RG-07 | BVA: minimal email | `"a@"` | No format error (matches `contains('@')`) |
| RG-08 | EP: mixed-case email | `"John.Doe@Example.COM"` | No error |
| RG-09 | BVA: password = 5 chars | `"pass1"` | `"Password must be at least 6 characters"` |
| RG-10 | BVA: password = 6 chars | `"pass12"` | No error |
| RG-11 | EP: valid form, Firebase down | Submit valid form | `"Registration failed. Please try again."` SnackBar |
| RG-12 | Re-entry | Type, clear, retype | Form reflects last values |
| RG-13 | UX: password obscured | Inspect EditableText | `obscureText == true` |
| RG-14 | Multi-error | Submit with multiple invalid fields | All errors shown simultaneously |
| (RG-15 – RG-20 cover button enabled-state, AppBar back arrow, AppBar title, navigation back to sign-in.) |

### 6.9 `CommitteeSignInScreen` — `test/committee_sign_in_screen_test.dart` (19 cases)
Same EP / BVA pattern as `SignInScreen`, plus admin-pending flag verification:
form must set `AppState.setAdminPending(true)` before invoking auth so that
the auth listener marks the user as admin once Firebase confirms login.

### 6.10 `SocietyBrowserScreen` — `test/society_browser_screen_test.dart` (11 cases)
| ID | Partition | Scenario | Expected |
|----|-----------|----------|----------|
| SB-01 | Render | Empty list | "No societies available" placeholder |
| SB-02 | Render | Populated list | One card per society |
| SB-03 | EP: not joined | Society not in joined list | `Join` button visible |
| SB-04 | EP: joined | Society in joined list | `Joined` indicator visible |
| SB-05 | Action | Tap `Join` | `AppState.isJoined(id) == true` |
| SB-06 | Filter | Switch tab to "All" / "Joined" | List filtered correctly |
| SB-07 | Search | Enter query | Only matching societies remain |
| SB-08 | BVA: empty search | Empty query | All societies shown |
| SB-09 | BVA: no-match search | Random string | Empty-results placeholder |
| SB-10 | Navigation | Tap card | `SocietyDetailScreen` pushed |
| SB-11 | Render | Society image / icon | `SocietyImage` present |

### 6.11 `SavedEventsScreen` — covered by integration plus `app_state_unit_test`
| ID | Partition | Scenario | Expected |
|----|-----------|----------|----------|
| SE-01 | Render | No saved events, no events list | "No events available." |
| SE-02 | Render | Saved events present | One tile per saved event |
| SE-03 | Render | No saved but events available | Falls back to all events tab |
| SE-04 | Action | Tap tile | `EventDetailScreen` pushed |
| SE-05 | Lifecycle | Initial pump triggers `loadEvents` after first frame | No "setState during build" exception (regression) |

### 6.12 `MessagesPage` — `test/messages_screen_test.dart` (4 cases)
Render + AppBar + list-tile presence + tap navigation to a chat.

### 6.13 `ProfileScreen` — `test/profile_screen_test.dart` (15 cases)
| ID | Partition | Scenario | Expected |
|----|-----------|----------|----------|
| PR-01 | Render | Authenticated student | Display name + email + joined societies |
| PR-02 | Render | Guest | "Sign in to see your profile" placeholder |
| PR-03 | Render | Admin | "Committee" badge present |
| PR-04 | Action | Tap "Sign out" | `AppState.isAuthenticated == false` |
| (PR-05 – PR-15 cover joined-society list rendering, empty-state, edit-display-name flow.) |

### 6.14 Integration — `test/integration_test.dart`
| ID | Scenario | Expected |
|----|----------|----------|
| INT-01 | Cold launch reaches `SignInScreen` | `Sign In` button visible within 2s |
| INT-02 | Continue-as-guest reaches `MainTabs` | All 5 tab labels visible |
| INT-03 | Tab navigation Home → Discover → Saved → Profile | Each switch reflected in `BottomNavigationBar.currentIndex` |

## 7. Input-Partition Coverage Matrix

For every validated input, the table below records the EP classes and BVA
points covered, demonstrating that no partition for any input is left
untested.

| Input | Validator location | EP classes covered | BVA points covered |
|-------|--------------------|-------------------|--------------------|
| Display name | `register_screen.dart:165` | empty, whitespace, < 2 chars, ≥ 2 chars, special chars, very long | empty / 1 / 2 chars |
| Email (sign in) | `sign_in_screen.dart` | empty, whitespace, no `@`, contains `@`, mixed case | empty / `"   "` / `"a@b"` |
| Email (register) | `register_screen.dart:180` | empty, whitespace, no `@`, contains `@`, mixed case, special chars | empty / `"a@"` |
| Password | `register_screen.dart:208` | empty, < 6, = 6, > 6 | 0 / 5 / 6 / 7 chars |
| Society name (create) | `app_state.dart:createSociety` | empty (rejected by UI form), valid, slug-collision | 1-char minimum |
| Search query | `society_browser_screen.dart` | empty, no-match, partial-match, full-match, mixed-case | empty / 1 char |
| Date / time pickers | `create_announcement` flow | not picked, picked | midnight / noon |

## 8. Test Evidence

- **Pass / fail report**: output of `flutter test` — all 160 cases pass.
- **Coverage report**: `coverage/lcov.info` produced by
  `flutter test --coverage`; HTML report rendered to `coverage/html/`.
- **CI**: `.github/workflows/` runs the full suite on every push.

## 9. Limitations & Known Gaps

- Coverage is currently 30% line coverage. The bulk of uncovered code is in
  Firestore interaction paths (`AppState.loadAnnouncements` snapshot
  callback, `SocietyService.joinSociety`'s Firestore call). Raising
  coverage further requires a `fake_cloud_firestore` fixture; the current
  suite uses constructor injection (`skipFirebase: true`) instead.
- No on-device performance tests are automated. Performance scenarios
  (NFR-1: "list of societies displayed within 2 seconds") are validated
  manually using the Flutter DevTools timeline; results recorded in the
  Iteration 2 report.
