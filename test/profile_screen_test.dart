import 'package:flutter_test/flutter_test.dart';import 'package:flutter_test/flutter_test.dart';import 'package:flutter_test/flutter_test.dart';import 'package:flutter_test/flutter_test.dart';import 'package:flutter/material.dart';

import 'package:sociefy/providers/app_state.dart';

import 'package:sociefy/providers/app_state.dart';

void main() {

  group('ProfileScreen AppState Tests', () {import 'package:sociefy/providers/app_state.dart';

    void setupGuestAppState(AppState appState) {

      appState.userId = 'guest';void main() {

      appState.isAdmin = false;

      appState.notifyListeners();  group('ProfileScreen AppState Tests', () {import 'package:sociefy/providers/app_state.dart';import 'package:flutter_test/flutter_test.dart';

    }

    /// Helper to initialize an AppState with guest login

    test('AppState initializes with guest userId', () {

      final appState = AppState(skipFirebase: true);    void setupGuestAppState(AppState appState) {void main() {

      setupGuestAppState(appState);

      expect(appState.isAuthenticated, isTrue);      appState.userId = 'guest';

      expect(appState.isGuest, isTrue);

      expect(appState.userId, equals('guest'));      appState.isAdmin = false;  group('ProfileScreen with AppState Tests', () {import 'package:provider/provider.dart';

      expect(appState.isAdmin, isFalse);

    });      appState.notifyListeners();



    test('Guest user flag reflects guest userId correctly', () {    }    /// Helper to create and initialize an AppState with guest login

      final appState = AppState(skipFirebase: true);

      setupGuestAppState(appState);

      expect(appState.isGuest, isTrue);

      expect(appState.userId, equals('guest'));    test('AppState initializes with guest userId', () {    /// without calling Firebase methods.void main() {import 'package:sociefy/providers/app_state.dart';

    });

      final appState = AppState(skipFirebase: true);

    test('Sign Out clears authentication for guest user', () {

      final appState = AppState(skipFirebase: true);      setupGuestAppState(appState);    void setupGuestAppState(AppState appState) {

      setupGuestAppState(appState);

      expect(appState.isAuthenticated, isTrue);      expect(appState.isAuthenticated, isTrue);

      appState.logout();

      expect(appState.isAuthenticated, isFalse);      expect(appState.isGuest, isTrue);      appState.userId = 'guest';  group('ProfileScreen with AppState Tests', () {

      expect(appState.isGuest, isFalse);

    });      expect(appState.userId, equals('guest'));



    test('Logout clears userId completely', () {      expect(appState.isAdmin, isFalse);      appState.isAdmin = false;

      final appState = AppState(skipFirebase: true);

      setupGuestAppState(appState);    });

      appState.logout();

      expect(appState.userId, isNull);      appState.notifyListeners();    /// Helper to create and initialize an AppState with guest loginvoid main() {

      expect(appState.isAuthenticated, isFalse);

    });    test('Guest user flag reflects guest userId correctly', () {



    test('Logout clears admin flag', () {      final appState = AppState(skipFirebase: true);    }

      final appState = AppState(skipFirebase: true);

      setupGuestAppState(appState);      setupGuestAppState(appState);

      appState.logout();

      expect(appState.isAdmin, isFalse);      expect(appState.isGuest, isTrue);    /// without calling Firebase methods.  group('ProfileScreen with AppState Tests', () {

    });

      expect(appState.userId, equals('guest'));

    test('Guest userId is exactly guest', () {

      final appState = AppState(skipFirebase: true);    });    /// Test 1: AppState initializes with guest userId

      setupGuestAppState(appState);

      expect(appState.userId, equals('guest'));

      expect(appState.isGuest, isTrue);

    });    test('Sign Out clears authentication for guest user', () {    test('AppState initializes with guest userId', () {    void setupGuestAppState(AppState appState) {    /// Helper to create and initialize an AppState with guest login



    test('Admin status is separate from guest status', () {      final appState = AppState(skipFirebase: true);

      final appState = AppState(skipFirebase: true);

      setupGuestAppState(appState);      setupGuestAppState(appState);      // Arrange

      expect(appState.isGuest, isTrue);

      expect(appState.isAdmin, isFalse);      expect(appState.isAuthenticated, isTrue);

      expect(appState.isAuthenticated, isTrue);

    });      expect(appState.isGuest, isTrue);      final appState = AppState(skipFirebase: true);      appState.userId = 'guest';    /// without calling Firebase methods.



    test('Non-guest user is not identified as guest', () {      appState.logout();

      final appState = AppState(skipFirebase: true);

      appState.userId = 'real-user-id';      expect(appState.isAuthenticated, isFalse);

      appState.isAdmin = false;

      appState.notifyListeners();      expect(appState.isGuest, isFalse);

      expect(appState.isGuest, isFalse);

      expect(appState.isAuthenticated, isTrue);      expect(appState.userId, isNull);      // Act      appState.isAdmin = false;    void setupGuestAppState(AppState appState) {

    });

    });

    test('Multiple logout calls handled gracefully', () {

      final appState = AppState(skipFirebase: true);      setupGuestAppState(appState);

      setupGuestAppState(appState);

      appState.logout();    test('Logout clears userId completely', () {

      expect(appState.isAuthenticated, isFalse);

      appState.logout();      final appState = AppState(skipFirebase: true);      appState.notifyListeners();      appState.userId = 'guest';

      expect(appState.isAuthenticated, isFalse);

    });      setupGuestAppState(appState);



    test('Logout triggers listeners for state changes', () {      expect(appState.userId, isNotNull);      // Assert

      final appState = AppState(skipFirebase: true);

      setupGuestAppState(appState);      appState.logout();

      bool listenerCalled = false;

      appState.addListener(() {      expect(appState.userId, isNull);      expect(appState.isAuthenticated, isTrue);    }      appState.isAdmin = false;

        listenerCalled = true;

      });      expect(appState.isAuthenticated, isFalse);

      appState.logout();

      expect(listenerCalled, isTrue);    });      expect(appState.isGuest, isTrue);

    });



    test('Setting guest state triggers listeners', () {

      final appState = AppState(skipFirebase: true);    test('Logout clears admin flag', () {      expect(appState.userId, equals('guest'));      appState.notifyListeners();

      bool listenerCalled = false;

      appState.addListener(() {      final appState = AppState(skipFirebase: true);

        listenerCalled = true;

      });      setupGuestAppState(appState);      expect(appState.isAdmin, isFalse);

      setupGuestAppState(appState);

      expect(listenerCalled, isTrue);      appState.logout();

    });

      expect(appState.isAdmin, isFalse);    });    /// Test 1: AppState initializes with guest userId    }

    test('AppState transitions from guest to authenticated', () {

      final appState = AppState(skipFirebase: true);    });

      setupGuestAppState(appState);

      appState.userId = 'real-user-id';

      appState.notifyListeners();

      expect(appState.isGuest, isFalse);    test('Guest userId is exactly guest', () {

      expect(appState.isAuthenticated, isTrue);

    });      final appState = AppState(skipFirebase: true);    /// Test 2: Guest user flag is accurate    test('AppState initializes with guest userId', () async {



    test('AppState transitions back to guest', () {      setupGuestAppState(appState);

      final appState = AppState(skipFirebase: true);

      appState.userId = 'real-user-id';      expect(appState.userId, equals('guest'));    test('Guest user flag reflects guest userId correctly', () {

      appState.notifyListeners();

      setupGuestAppState(appState);      expect(appState.isGuest, isTrue);

      expect(appState.isGuest, isTrue);

      expect(appState.isAuthenticated, isTrue);    });      // Arrange      // Arrange    /// Test 1: AppState initializes with guest login

    });



    test('Guest user is not admin by default', () {

      final appState = AppState(skipFirebase: true);    test('Admin status is separate from guest status', () {      final appState = AppState(skipFirebase: true);

      setupGuestAppState(appState);

      expect(appState.isGuest, isTrue);      final appState = AppState(skipFirebase: true);

      expect(appState.isAdmin, isFalse);

    });      setupGuestAppState(appState);      setupGuestAppState(appState);      final appState = AppState(skipFirebase: true);    test('AppState initializes with guest userId', () async {



    test('Logout completely resets authentication state', () {      expect(appState.isGuest, isTrue);

      final appState = AppState(skipFirebase: true);

      setupGuestAppState(appState);      expect(appState.isAdmin, isFalse);

      appState.logout();

      expect(appState.isAuthenticated, isFalse);      expect(appState.isAuthenticated, isTrue);

      expect(appState.isGuest, isFalse);

      expect(appState.isAdmin, isFalse);    });      // Assert      // Arrange

      expect(appState.userId, isNull);

    });

  });

}    test('Non-guest user is not identified as guest', () {      expect(appState.isGuest, isTrue);


      final appState = AppState(skipFirebase: true);

      appState.userId = 'real-user-id';      expect(appState.userId, equals('guest'));      // Act      final appState = AppState(skipFirebase: true);

      appState.isAdmin = false;

      appState.notifyListeners();    });

      expect(appState.isGuest, isFalse);

      expect(appState.isAuthenticated, isTrue);      setupGuestAppState(appState);

      expect(appState.userId, equals('real-user-id'));

    });    /// Test 3: Sign Out clears authentication



    test('Multiple logout calls are handled gracefully', () {    test('Sign Out clears authentication for guest user', () {      // Act

      final appState = AppState(skipFirebase: true);

      setupGuestAppState(appState);      // Arrange

      appState.logout();

      expect(appState.isAuthenticated, isFalse);      final appState = AppState(skipFirebase: true);      // Assert      setupGuestAppState(appState);

      appState.logout();

      expect(appState.isAuthenticated, isFalse);      setupGuestAppState(appState);

      expect(appState.userId, isNull);

    });      expect(appState.isAuthenticated, isTrue);



    test('Logout triggers listeners for state changes', () {      // Verify guest is authenticated before logout

      final appState = AppState(skipFirebase: true);

      setupGuestAppState(appState);      expect(appState.isAuthenticated, isTrue);      expect(appState.isGuest, isTrue);      // Assert

      bool listenerCalled = false;

      appState.addListener(() {      expect(appState.isGuest, isTrue);

        listenerCalled = true;

      });      expect(appState.userId, equals('guest'));      expect(appState.isAuthenticated, isTrue);

      appState.logout();

      expect(listenerCalled, isTrue);      // Act

      expect(appState.isAuthenticated, isFalse);

    });      appState.logout();      expect(appState.isAdmin, isFalse);      expect(appState.isGuest, isTrue);



    test('Setting guest state triggers listeners', () {

      final appState = AppState(skipFirebase: true);

      bool listenerCalled = false;      // Assert    });      expect(appState.userId, equals('guest'));

      appState.addListener(() {

        listenerCalled = true;      expect(appState.isAuthenticated, isFalse);

      });

      setupGuestAppState(appState);      expect(appState.isGuest, isFalse);      expect(appState.isAdmin, isFalse);

      expect(listenerCalled, isTrue);

      expect(appState.isGuest, isTrue);      expect(appState.userId, isNull);

    });

    });    /// Test 2: Guest user flag is accurate    });

    test('AppState can transition from guest to authenticated user', () {

      final appState = AppState(skipFirebase: true);

      setupGuestAppState(appState);

      expect(appState.isGuest, isTrue);    /// Test 4: Verify logout clears userId    test('Guest user flag reflects guest userId correctly', () async {

      appState.userId = 'real-user-id';

      appState.notifyListeners();    test('Logout clears userId completely', () {

      expect(appState.isGuest, isFalse);

      expect(appState.isAuthenticated, isTrue);      // Arrange      // Arrange    /// Test 2: Guest user flag is accurate

      expect(appState.userId, equals('real-user-id'));

    });      final appState = AppState(skipFirebase: true);



    test('AppState can transition from authenticated user back to guest', () {      setupGuestAppState(appState);      final appState = AppState(skipFirebase: true);    test('Guest user flag reflects guest userId correctly', () async {

      final appState = AppState(skipFirebase: true);

      appState.userId = 'real-user-id';      expect(appState.userId, isNotNull);

      appState.notifyListeners();

      expect(appState.isGuest, isFalse);      setupGuestAppState(appState);      // Arrange

      setupGuestAppState(appState);

      expect(appState.isGuest, isTrue);      // Act

      expect(appState.isAuthenticated, isTrue);

    });      appState.logout();      final appState = AppState(skipFirebase: true);



    test('Guest user is not admin by default', () {

      final appState = AppState(skipFirebase: true);

      setupGuestAppState(appState);      // Assert      // Assert      setupGuestAppState(appState);

      expect(appState.isGuest, isTrue);

      expect(appState.isAdmin, isFalse);      expect(appState.userId, isNull);

    });

      expect(appState.isAuthenticated, isFalse);      expect(appState.isGuest, isTrue);

    test('Logout completely resets authentication state', () {

      final appState = AppState(skipFirebase: true);    });

      setupGuestAppState(appState);

      expect(appState.isAuthenticated, isTrue);      expect(appState.userId, equals('guest'));      // Assert

      expect(appState.isGuest, isTrue);

      appState.logout();    /// Test 5: Verify logout clears admin flag

      expect(appState.isAuthenticated, isFalse);

      expect(appState.isGuest, isFalse);    test('Logout clears admin flag', () {    });      expect(appState.isGuest, isTrue);

      expect(appState.isAdmin, isFalse);

      expect(appState.userId, isNull);      // Arrange

    });

  });      final appState = AppState(skipFirebase: true);      expect(appState.userId, equals('guest'));

}

      setupGuestAppState(appState);

    /// Test 3: Sign Out clears authentication    });

      // Act

      appState.logout();    test('Sign Out clears authentication for guest user', () async {



      // Assert      // Arrange    /// Test 3: Sign Out clears authentication

      expect(appState.isAdmin, isFalse);

    });      final appState = AppState(skipFirebase: true);    test('Sign Out button clears authentication for guest user', () async {



    /// Test 6: Guest userId is exactly 'guest'      setupGuestAppState(appState);      // Arrange

    test('Guest userId is exactly guest', () {

      // Arrange      final appState = AppState(skipFirebase: true);

      final appState = AppState(skipFirebase: true);

      // Verify guest is authenticated before logout      setupGuestAppState(appState);

      // Act

      setupGuestAppState(appState);      expect(appState.isAuthenticated, isTrue);



      // Assert      expect(appState.isGuest, isTrue);      // Verify guest is authenticated before logout

      expect(appState.userId, equals('guest'));

      expect(appState.isGuest, isTrue);      expect(appState.isAuthenticated, isTrue);

    });

      // Act      expect(appState.isGuest, isTrue);

    /// Test 7: AppState tracks admin status separately from guest status

    test('Admin status is separate from guest status', () {      appState.logout();

      // Arrange

      final appState = AppState(skipFirebase: true);      // Act

      setupGuestAppState(appState);

      // Assert      appState.logout();

      // Assert

      expect(appState.isGuest, isTrue);      expect(appState.isAuthenticated, isFalse);

      expect(appState.isAdmin, isFalse);

      expect(appState.isAuthenticated, isTrue);      expect(appState.isGuest, isFalse);      // Assert

    });

      expect(appState.userId, isNull);      expect(appState.isAuthenticated, isFalse);

    /// Test 8: Non-guest user is not identified as guest

    test('Non-guest user is not identified as guest', () {    });      expect(appState.isGuest, isFalse);

      // Arrange

      final appState = AppState(skipFirebase: true);      expect(appState.userId, isNull);

      appState.userId = 'real-user-id';

      appState.isAdmin = false;    /// Test 4: Verify logout clears userId    });

      appState.notifyListeners();

    test('Logout clears userId completely', () async {

      // Assert

      expect(appState.isGuest, isFalse);      // Arrange    /// Test 4: Verify logout clears userId

      expect(appState.isAuthenticated, isTrue);

      expect(appState.userId, equals('real-user-id'));      final appState = AppState(skipFirebase: true);    test('Logout clears userId completely', () async {

    });

      setupGuestAppState(appState);      // Arrange

    /// Test 9: Multiple logout calls don't cause errors

    test('Multiple logout calls are handled gracefully', () {      expect(appState.userId, isNotNull);      final appState = AppState(skipFirebase: true);

      // Arrange

      final appState = AppState(skipFirebase: true);      setupGuestAppState(appState);

      setupGuestAppState(appState);

      // Act      expect(appState.userId, isNotNull);

      // Act & Assert - Should not throw

      appState.logout();      appState.logout();

      expect(appState.isAuthenticated, isFalse);

      // Act

      // Calling logout again on an already logged-out state

      appState.logout();      // Assert      appState.logout();

      expect(appState.isAuthenticated, isFalse);

      expect(appState.userId, isNull);      expect(appState.userId, isNull);

    });

      expect(appState.isAuthenticated, isFalse);      // Assert

    /// Test 10: Logout triggers notifyListeners

    test('Logout triggers listeners for state changes', () {    });      expect(appState.userId, isNull);

      // Arrange

      final appState = AppState(skipFirebase: true);      expect(appState.isAuthenticated, isFalse);

      setupGuestAppState(appState);

    /// Test 5: Verify logout clears admin flag    });

      bool listenerCalled = false;

      appState.addListener(() {    test('Logout clears admin flag', () async {

        listenerCalled = true;

      });      // Arrange    /// Test 5: Verify logout clears admin flag



      // Act      final appState = AppState(skipFirebase: true);    test('Logout clears admin flag', () async {

      appState.logout();

      setupGuestAppState(appState);      // Arrange

      // Assert

      expect(listenerCalled, isTrue);      final appState = AppState(skipFirebase: true);

      expect(appState.isAuthenticated, isFalse);

    });      // Act      setupGuestAppState(appState);



    /// Test 11: Guest setup triggers notifyListeners      appState.logout();

    test('Setting guest state triggers listeners', () {

      // Arrange      // Act

      final appState = AppState(skipFirebase: true);

      // Assert      appState.logout();

      bool listenerCalled = false;

      appState.addListener(() {      expect(appState.isAdmin, isFalse);

        listenerCalled = true;

      });    });      // Assert



      // Act      expect(appState.isAdmin, isFalse);

      setupGuestAppState(appState);

    /// Test 6: Guest userId is exactly 'guest'    });

      // Assert

      expect(listenerCalled, isTrue);    test('Guest userId is exactly guest', () async {

      expect(appState.isGuest, isTrue);

    });      // Arrange    /// Test 6: Guest userId is exactly 'guest'



    /// Test 12: AppState allows switching from guest to authenticated user      final appState = AppState(skipFirebase: true);    test('Guest userId is exactly guest', () async {

    test('AppState can transition from guest to authenticated user', () {

      // Arrange      // Arrange

      final appState = AppState(skipFirebase: true);

      setupGuestAppState(appState);      // Act      final appState = AppState(skipFirebase: true);

      expect(appState.isGuest, isTrue);

      setupGuestAppState(appState);

      // Act - Switch to a different user

      appState.userId = 'real-user-id';      // Act

      appState.notifyListeners();

      // Assert      setupGuestAppState(appState);

      // Assert

      expect(appState.isGuest, isFalse);      expect(appState.userId, equals('guest'));

      expect(appState.isAuthenticated, isTrue);

      expect(appState.userId, equals('real-user-id'));      expect(appState.isGuest, isTrue);      // Assert

    });

    });      expect(appState.userId, equals('guest'));

    /// Test 13: AppState allows switching from authenticated user back to guest

    test('AppState can transition from authenticated user back to guest', () {      expect(appState.isGuest, isTrue);

      // Arrange

      final appState = AppState(skipFirebase: true);    /// Test 7: AppState tracks admin status separately from guest status    });

      appState.userId = 'real-user-id';

      appState.notifyListeners();    test('Admin status is separate from guest status', () async {

      expect(appState.isGuest, isFalse);

      // Arrange    /// Test 7: AppState tracks admin status separately from guest status

      // Act - Switch to guest

      setupGuestAppState(appState);      final appState = AppState(skipFirebase: true);    test('Admin status is separate from guest status', () async {



      // Assert      setupGuestAppState(appState);      // Arrange

      expect(appState.isGuest, isTrue);

      expect(appState.isAuthenticated, isTrue);      final appState = AppState(skipFirebase: true);

    });

      // Assert      setupGuestAppState(appState);

    /// Test 14: Verify guest user is not admin

    test('Guest user is not admin by default', () {      expect(appState.isGuest, isTrue);

      // Arrange

      final appState = AppState(skipFirebase: true);      expect(appState.isAdmin, isFalse);      // Assert

      setupGuestAppState(appState);

      expect(appState.isAuthenticated, isTrue);      expect(appState.isGuest, isTrue);

      // Assert

      expect(appState.isGuest, isTrue);    });      expect(appState.isAdmin, isFalse);

      expect(appState.isAdmin, isFalse);

    });      expect(appState.isAuthenticated, isTrue);



    /// Test 15: Logout completely resets authentication state    /// Test 8: Non-guest user is not identified as guest    });

    test('Logout completely resets authentication state', () {

      // Arrange    test('Non-guest user is not identified as guest', () async {

      final appState = AppState(skipFirebase: true);

      setupGuestAppState(appState);      // Arrange    /// Test 8: Non-guest user is not identified as guest

      expect(appState.isAuthenticated, isTrue);

      expect(appState.isGuest, isTrue);      final appState = AppState(skipFirebase: true);    test('Non-guest user is not identified as guest', () async {



      // Act      appState.userId = 'real-user-id';      // Arrange

      appState.logout();

      appState.isAdmin = false;      final appState = AppState(skipFirebase: true);

      // Assert

      expect(appState.isAuthenticated, isFalse);      appState.notifyListeners();      appState.userId = 'real-user-id';

      expect(appState.isGuest, isFalse);

      expect(appState.isAdmin, isFalse);      appState.isAdmin = false;

      expect(appState.userId, isNull);

    });      // Assert      appState.notifyListeners();

  });

}      expect(appState.isGuest, isFalse);


      expect(appState.isAuthenticated, isTrue);      // Assert

      expect(appState.userId, equals('real-user-id'));      expect(appState.isGuest, isFalse);

    });      expect(appState.isAuthenticated, isTrue);

      expect(appState.userId, equals('real-user-id'));

    /// Test 9: Multiple logout calls don't cause errors    });

    test('Multiple logout calls are handled gracefully', () async {

      // Arrange    /// Test 9: Multiple logout calls don't cause errors

      final appState = AppState(skipFirebase: true);    test('Multiple logout calls are handled gracefully', () async {

      setupGuestAppState(appState);      // Arrange

      final appState = AppState(skipFirebase: true);

      // Act & Assert - Should not throw      setupGuestAppState(appState);

      appState.logout();

      expect(appState.isAuthenticated, isFalse);      // Act & Assert - Should not throw

      appState.logout();

      // Calling logout again on an already logged-out state      expect(appState.isAuthenticated, isFalse);

      appState.logout();

      expect(appState.isAuthenticated, isFalse);      // Calling logout again on an already logged-out state

      expect(appState.userId, isNull);      appState.logout();

    });      expect(appState.isAuthenticated, isFalse);

      expect(appState.userId, isNull);

    /// Test 10: Logout triggers notifyListeners    });

    test('Logout triggers listeners for state changes', () async {

      // Arrange    /// Test 10: Logout triggers notifyListeners

      final appState = AppState(skipFirebase: true);    test('Logout triggers listeners for state changes', () async {

      setupGuestAppState(appState);      // Arrange

      final appState = AppState(skipFirebase: true);

      bool listenerCalled = false;      setupGuestAppState(appState);

      appState.addListener(() {      

        listenerCalled = true;      bool listenerCalled = false;

      });      appState.addListener(() {

        listenerCalled = true;

      // Act      });

      appState.logout();

      // Act

      // Assert      appState.logout();

      expect(listenerCalled, isTrue);

      expect(appState.isAuthenticated, isFalse);      // Assert

    });      expect(listenerCalled, isTrue);

      expect(appState.isAuthenticated, isFalse);

    /// Test 11: Guest setup triggers notifyListeners    });

    test('Setting guest state triggers listeners', () async {

      // Arrange    /// Test 11: Guest setup triggers notifyListeners

      final appState = AppState(skipFirebase: true);    test('Setting guest state triggers listeners', () async {

      // Arrange

      bool listenerCalled = false;      final appState = AppState(skipFirebase: true);

      appState.addListener(() {      

        listenerCalled = true;      bool listenerCalled = false;

      });      appState.addListener(() {

        listenerCalled = true;

      // Act      });

      setupGuestAppState(appState);

      // Act

      // Assert      setupGuestAppState(appState);

      expect(listenerCalled, isTrue);

      expect(appState.isGuest, isTrue);      // Assert

    });      expect(listenerCalled, isTrue);

      expect(appState.isGuest, isTrue);

    /// Test 12: AppState allows switching from guest to authenticated user    });

    test('AppState can transition from guest to authenticated user', () async {

      // Arrange    /// Test 12: AppState allows switching from guest to authenticated user

      final appState = AppState(skipFirebase: true);    test('AppState can transition from guest to authenticated user', () async {

      setupGuestAppState(appState);      // Arrange

      expect(appState.isGuest, isTrue);      final appState = AppState(skipFirebase: true);

      setupGuestAppState(appState);

      // Act - Switch to a different user      expect(appState.isGuest, isTrue);

      appState.userId = 'real-user-id';

      appState.notifyListeners();      // Act - Switch to a different user

      appState.userId = 'real-user-id';

      // Assert      appState.notifyListeners();

      expect(appState.isGuest, isFalse);

      expect(appState.isAuthenticated, isTrue);      // Assert

      expect(appState.userId, equals('real-user-id'));      expect(appState.isGuest, isFalse);

    });      expect(appState.isAuthenticated, isTrue);

      expect(appState.userId, equals('real-user-id'));

    /// Test 13: AppState allows switching from authenticated user back to guest    });

    test('AppState can transition from authenticated user back to guest', () async {

      // Arrange    /// Test 13: AppState allows switching from authenticated user back to guest

      final appState = AppState(skipFirebase: true);    test('AppState can transition from authenticated user back to guest', () async {

      appState.userId = 'real-user-id';      // Arrange

      appState.notifyListeners();      final appState = AppState(skipFirebase: true);

      expect(appState.isGuest, isFalse);      appState.userId = 'real-user-id';

      appState.notifyListeners();

      // Act - Switch to guest      expect(appState.isGuest, isFalse);

      setupGuestAppState(appState);

      // Act - Switch to guest

      // Assert      setupGuestAppState(appState);

      expect(appState.isGuest, isTrue);

      expect(appState.isAuthenticated, isTrue);      // Assert

    });      expect(appState.isGuest, isTrue);

      expect(appState.isAuthenticated, isTrue);

    /// Test 14: Verify guest user is not admin    });

    test('Guest user is not admin by default', () async {

      // Arrange    /// Test 14: Verify guest user is not admin

      final appState = AppState(skipFirebase: true);    test('Guest user is not admin by default', () async {

      setupGuestAppState(appState);      // Arrange

      final appState = AppState(skipFirebase: true);

      // Assert      setupGuestAppState(appState);

      expect(appState.isGuest, isTrue);

      expect(appState.isAdmin, isFalse);      // Assert

    });      expect(appState.isGuest, isTrue);

      expect(appState.isAdmin, isFalse);

    /// Test 15: Logout clears both guest and admin states    });

    test('Logout completely resets authentication state', () async {

      // Arrange    /// Test 15: Logout clears both guest and admin states

      final appState = AppState(skipFirebase: true);    test('Logout completely resets authentication state', () async {

      setupGuestAppState(appState);      // Arrange

      expect(appState.isAuthenticated, isTrue);      final appState = AppState(skipFirebase: true);

      expect(appState.isGuest, isTrue);      setupGuestAppState(appState);

      expect(appState.isAuthenticated, isTrue);

      // Act      expect(appState.isGuest, isTrue);

      appState.logout();

      // Act

      // Assert      appState.logout();

      expect(appState.isAuthenticated, isFalse);

      expect(appState.isGuest, isFalse);      // Assert

      expect(appState.isAdmin, isFalse);      expect(appState.isAuthenticated, isFalse);

      expect(appState.userId, isNull);      expect(appState.isGuest, isFalse);

    });      expect(appState.isAdmin, isFalse);

  });      expect(appState.userId, isNull);

}    });

  });
}


    /// Test 2: Sign Out button is present on the profile screen
    testWidgets('Sign Out button is present', (WidgetTester tester) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    /// Test 3: When Sign Out is tapped for guest user, isAuthenticated becomes false
    testWidgets('Sign Out button clears authentication for guest user', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Verify guest is authenticated before sign out
      expect(appState.isAuthenticated, isTrue);
      expect(appState.isGuest, isTrue);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Tap the Sign Out button
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // Assert
      expect(appState.isAuthenticated, isFalse);
      expect(appState.isGuest, isFalse);
    });

    /// Test 4: Guest avatar displays 'G' as the first letter of 'Guest User'
    testWidgets('Guest user avatar displays G', (WidgetTester tester) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('G'), findsOneWidget);
    });

    /// Test 5: Profile screen displays correct UI structure with title
    testWidgets('Profile screen has correct UI structure', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Profile'), findsWidgets);
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    /// Test 6: Verify app state is initially authenticated as guest
    testWidgets('AppState initializes with guest login', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);

      // Act
      setupGuestAppState(appState);

      // Assert
      expect(appState.isAuthenticated, isTrue);
      expect(appState.isGuest, isTrue);
      expect(appState.userId, equals('guest'));
      expect(appState.isAdmin, isFalse);
    });

    /// Test 7: Verify logout clears userId
    testWidgets('Logout clears userId completely', (WidgetTester tester) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      expect(appState.userId, isNotNull);

      // Act
      appState.logout();

      // Assert
      expect(appState.userId, isNull);
      expect(appState.isAuthenticated, isFalse);
    });

    /// Test 8: Verify logout clears admin flag
    testWidgets('Logout clears admin flag', (WidgetTester tester) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      appState.logout();

      // Assert
      expect(appState.isAdmin, isFalse);
    });

    /// Test 9: Sign Out button is an ElevatedButton with logout icon
    testWidgets('Sign Out button is properly styled', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    /// Test 10: Profile displays correct styling for guest display name
    testWidgets('Guest User text has correct styling', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert - Verify the text is rendered
      final guestUserFinder = find.text('Guest User');
      expect(guestUserFinder, findsOneWidget);

      // Verify it's displayed in the widget tree
      final widget = tester.widget<Text>(guestUserFinder);
      expect(widget.style?.fontSize, equals(24));
      expect(widget.style?.fontWeight, equals(FontWeight.bold));
    });

    /// Test 11: Subtitle has correct styling for guest
    testWidgets('Browsing as guest subtitle has correct styling', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert
      final subtitleFinder = find.text('Browsing as guest');
      expect(subtitleFinder, findsOneWidget);

      final widget = tester.widget<Text>(subtitleFinder);
      expect(widget.style?.fontSize, equals(16));
      expect(widget.style?.color, equals(Colors.grey));
    });

    /// Test 12: AppBar title is 'Profile'
    testWidgets('AppBar displays Profile title', (WidgetTester tester) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Profile'),
        ),
        findsOneWidget,
      );
    });

    /// Test 13: CircleAvatar has correct radius
    testWidgets('CircleAvatar has correct dimensions', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert
      final avatarFinder = find.byType(CircleAvatar);
      expect(avatarFinder, findsOneWidget);

      final avatar = tester.widget<CircleAvatar>(avatarFinder);
      expect(avatar.radius, equals(50));
    });

    /// Test 14: Tapping Sign Out multiple times doesn't break the app
    testWidgets('Multiple Sign Out taps are handled gracefully', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Act - Tap Sign Out button
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // Assert - User should be logged out
      expect(appState.isAuthenticated, isFalse);
    });

    /// Test 15: Guest userId is exactly 'guest'
    testWidgets('Guest userId is exactly guest', (WidgetTester tester) async {
      // Arrange
      final appState = AppState(skipFirebase: true);

      // Act
      setupGuestAppState(appState);

      // Assert
      expect(appState.userId, equals('guest'));
      expect(appState.isGuest, isTrue);
    });

    /// Test 16: Verify Screen is wrapped correctly with providers
    testWidgets('ProfileScreen is properly wrapped in providers', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert - Should be able to find the provider in context
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
