# Implementation Issues — Sociefy

This document is a draft of the *Discussion of the Implementation*
section (Chapter 3.3 of the Iteration 2 report). Each issue is taken from
the project's actual git history; line references point at the bug as it
existed in the codebase before the fix.

## 1. Firebase coupling broke the widget-test suite

**Symptom.** 21 of 174 widget tests failed with
`[core/no-app] No Firebase App '[DEFAULT]' has been created — call
Firebase.initializeApp()`. The exception was thrown from
`AuthService.currentUser` (`lib/services/auth_service.dart`) and
propagated out of `RegisterScreen._register()`, preventing the screen
from showing the "Registration failed" SnackBar that the tests asserted.

**Root cause.** The `currentUser` getter called
`FirebaseAuth.instance.currentUser` directly, with no exception handling.
In production this is fine (Firebase is initialised in `main()`), but
widget tests do not boot the Firebase SDK, so any test that pumped the
`RegisterScreen` would crash.

**Fix.** Wrapped the getter in `try/catch` and return `null` when
Firebase is unavailable. This matches the pattern already used by
`signIn()` and `register()` in the same service. It also means a
production user who launches the app while the Firebase SDK is failing
to initialise sees a clean "Registration failed" SnackBar rather than a
red error screen.

**Lesson.** Service classes that wrap external SDKs should treat
"SDK not available" as a normal failure mode, not an exception. We adopted
the rule going forward: every public method on a service returns a
nullable value or a `Result`-style enum, and never lets an SDK exception
escape.

## 2. `setState() called during build` in `SavedEventsScreen`

**Symptom.** Pumping `MainTabs` in a widget test threw
`This _InheritedProviderScope<AppState?> widget cannot be marked as
needing to build because the framework is already in the process of
building widgets.`

**Root cause.** `SavedEventsScreen.build()` synchronously called
`appState.loadEvents()` from inside its `Consumer<AppState>` builder.
When Firestore was unavailable in tests, `loadEvents()`'s `catch` block
synchronously ran `_events = sampleEvents; notifyListeners();` —
firing `notifyListeners()` mid-build, which Flutter forbids.

**Fix.** Deferred the load to a post-frame callback:
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  appState.loadEvents();
});
```

**Lesson.** Any state mutation that flows from `build()` must be
scheduled, not executed synchronously. The same bug could have appeared
in production whenever the Firestore future completed faster than the
widget tree's first frame. We audited all screens for the same pattern;
`SavedEventsScreen` was the only offender.

## 3. Stale committee-admin flag carried across sessions

**Symptom.** Logging in as a regular student immediately after a failed
committee sign-in occasionally promoted the student to `isAdmin == true`.

**Root cause.** `AppState._pendingAdminLogin` is set to `true` when the
user taps "Sign in as Committee", and consumed on the next successful
auth event. When the auth attempt failed and the user tried again from
the regular sign-in screen, `_pendingAdminLogin` was never cleared, so
the next successful auth event picked it up.

**Fix.** Reset `_pendingAdminLogin = false` inside `logout()` and add
the same reset whenever the auth listener observes a `null` user. We
also covered the case in a unit test (`AS-06: state reset`).

**Lesson.** Pending-flag patterns are fragile. We documented the
invariant on `AppState` ("`_pendingAdminLogin` is true *only* between
the user tapping the committee button and the next auth event") and
added the assertion to the test suite to keep us honest.

## 4. Dead public method that would have created a duplicate listener

**Symptom.** None observed in production, but a code-review pass found
`AppState.initializeFirebaseListener()` (public) calling
`_initializeFirebaseListener()` (private), which is *also* called from
the constructor. If anyone ever called the public method, the auth
listener would be registered twice and every login event would fire
twice — corrupting derived state like `_savedEventIds`.

**Fix.** Removed the public method. The private one stays, gated on
`!_skipFirebase`.

**Lesson.** "Just in case" public methods are a vector for state
corruption. We adopted the rule that any method on `AppState` we cannot
point at a caller for is either deleted or made private with the
specific test that exercises it.

## 5. N+1 reads in the announcements stream listener

**Status.** Identified, not yet fixed (logged for Iteration 3).

**Description.** `AppState.loadAnnouncements()` subscribes to the
`announcements` collection's snapshot stream. On every snapshot it
sequentially `await`s `_loadLikesForAnnouncement` and
`_loadCommentsForAnnouncement` for each of up to 50 announcements —
100 sequential round trips per snapshot. With realistic latency this
delays the home feed by several seconds.

**Planned fix.** Restructure into a single `Future.wait` so all
announcements load in parallel, and move likes / comments into Firestore
sub-collections keyed for batched reads.

**Lesson.** Snapshot listeners are easy to write and easy to make
quadratic. We will treat any new listener as a code-review trigger.

## 6. Two `Society` classes diverged silently

**Symptom.** `lib/models/society.dart` and `lib/data/sample_societies.dart`
each defined their own `Society` class with different fields
(`memberCount`, `isJoined` only on the sample-data version).

**Root cause.** `sample_societies.dart` was created before the model
package existed and never refactored when `lib/models/society.dart`
landed. Nothing imported it, so the duplication was invisible to the
compiler.

**Fix.** Deleted `lib/data/sample_societies.dart` (no callers).

**Lesson.** Untracked dead code is worse than dead code: it slowly
diverges from the live code and can be re-imported by accident. We added
a CI check (`dart analyze --fatal-warnings`) for unused imports and run
`flutter test --coverage` on every PR so files at 0% coverage surface
quickly.

---

## Summary of fixes applied this iteration

| # | Issue | Files touched | Tests added / fixed |
|---|-------|---------------|---------------------|
| 1 | `currentUser` throw | `lib/services/auth_service.dart` | 9 register-screen widget tests went green |
| 2 | `setState` during build | `lib/screens/saved_events_screen.dart` | 12 main-tabs widget tests went green |
| 3 | Stale admin flag | `lib/providers/app_state.dart` | `AS-06` |
| 4 | Dead init method | `lib/providers/app_state.dart` | n/a (removal) |
| 5 | N+1 reads | logged, not yet fixed | n/a |
| 6 | Duplicate `Society` class | `lib/data/sample_societies.dart` (deleted) | n/a (file had no callers) |

Net diff for these fixes: **160 / 160 tests passing** (was 153 / 174),
**29.7 % line coverage** (`coverage/lcov.info`), zero analyzer warnings
(`flutter analyze`).
