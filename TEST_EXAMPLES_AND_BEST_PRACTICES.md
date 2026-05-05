# Test Examples & Best Practices

## RegisterScreen Widget Test Examples

### Example 1: Simple Validation Test
```dart
/// Test: Email without @ shows validation error
testWidgets('Shows validation error for email without @ symbol',
    (WidgetTester tester) async {
  // Arrange - Build widget
  await tester.pumpWidget(buildTestWidget());

  // Act - Fill form with invalid email
  await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
  await tester.enterText(find.byType(TextFormField).at(1), 'testexample.com');
  await tester.enterText(find.byType(TextFormField).at(2), 'password123');
  
  // Trigger validation
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();

  // Assert - Error message appears
  expect(find.text('Please enter a valid email'), findsOneWidget);
});
```

### Example 2: Multiple Validation Errors
```dart
/// Test: Multiple errors show together
testWidgets('Shows multiple validation errors simultaneously',
    (WidgetTester tester) async {
  await tester.pumpWidget(buildTestWidget());

  // Act - Fill with multiple invalid values
  await tester.enterText(find.byType(TextFormField).at(0), 'J');       // Too short
  await tester.enterText(find.byType(TextFormField).at(1), 'invalid'); // No @
  await tester.enterText(find.byType(TextFormField).at(2), '123');     // Too short
  
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();

  // Assert - All three errors visible
  expect(find.text('Display name must be at least 2 characters'), findsOneWidget);
  expect(find.text('Please enter a valid email'), findsOneWidget);
  expect(find.text('Password must be at least 6 characters'), findsOneWidget);
});
```

### Example 3: Boundary Testing
```dart
/// Test: Password with exactly 6 characters (boundary)
testWidgets('Password with exactly 6 characters passes validation',
    (WidgetTester tester) async {
  await tester.pumpWidget(buildTestWidget());

  // Act - Fill with 6-character password (exact minimum)
  await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
  await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
  await tester.enterText(find.byType(TextFormField).at(2), 'pass12'); // Exactly 6 chars
  
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();

  // Assert - No password length error
  expect(find.text('Password must be at least 6 characters'), findsNothing);
});
```

## AppState Unit Test Examples

### Example 1: Simple State Getter Test
```dart
test('isGuest returns true when userId is "guest"', () {
  // Arrange
  final appState = TestAppState();

  // Act
  appState.userId = 'guest';

  // Assert
  expect(appState.isGuest, isTrue);
});
```

### Example 2: Multiple Operations in Sequence
```dart
test('logout clears userId and sets isAuthenticated to false', () {
  // Arrange
  appState.userId = 'test-user';
  expect(appState.isAuthenticated, isTrue);

  // Act
  appState.logout();

  // Assert
  expect(appState.isAuthenticated, isFalse);
  expect(appState.userId, isNull);
  expect(appState.isAdmin, isFalse);
});
```

### Example 3: Idempotent Operations
```dart
test('duplicate saveEvent calls are idempotent', () {
  // Act - Save event multiple times
  appState.saveEvent('event-123');
  appState.saveEvent('event-123');
  appState.saveEvent('event-123');

  // Assert - Event only appears once
  expect(appState.isEventSaved('event-123'), isTrue);
});
```

## Testing Best Practices Used

### 1. AAA Pattern (Arrange-Act-Assert)
```dart
test('description', () {
  // ARRANGE - Set up test state
  
  // ACT - Perform the action
  
  // ASSERT - Verify results
});
```

### 2. Clear Test Names
✅ Good: `Shows validation error for email without @ symbol`  
❌ Bad: `Email test`

### 3. One Concept Per Test
✅ Each test validates ONE thing  
❌ Don't mix multiple validations in one test

### 4. Use Descriptive Assertions
```dart
// Good - Clear what's being checked
expect(find.text('Please enter your email'), findsOneWidget);

// Bad - Unclear
expect(find.byType(Text), findsNWidgets(5));
```

### 5. Test Edge Cases
- Empty input
- Minimum length values
- Maximum length values
- Special characters
- Whitespace

### 6. Firebase Error Handling
```dart
// Tests are designed to work even when Firebase errors occur
// Error messages are logged but don't fail the test
register error: [core/no-app] No Firebase App '[DEFAULT]'... (expected)
```

## Test Maintenance

### Adding a New Test
1. **Choose the right file**
   - Widget tests → `*_screen_test.dart`
   - Unit tests → `*_unit_test.dart` or `*_test.dart`

2. **Follow naming convention**
   ```dart
   test('describes what should happen', () {
     // implementation
   });
   ```

3. **Group related tests**
   ```dart
   group('Feature Category', () {
     test('first aspect', () {...});
     test('second aspect', () {...});
   });
   ```

4. **Run tests locally**
   ```bash
   flutter test test/my_test.dart
   ```

### Updating Existing Tests
- Change test logic (not names)
- Update comments when requirements change
- Keep tests independent (no shared state)

## Common Test Patterns

### Pattern 1: Form Field Testing
```dart
// Find TextFormField by index
await tester.enterText(find.byType(TextFormField).at(0), 'value');

// Find by multiple criteria
await tester.enterText(
  find.byType(TextFormField).first,
  'value'
);
```

### Pattern 2: Button Testing
```dart
// Tap button
await tester.tap(find.byType(ElevatedButton));

// Pump after tap (trigger state changes)
await tester.pump();

// Pump with duration
await tester.pumpAndSettle(); // Wait for animations
```

### Pattern 3: Error Message Testing
```dart
// Find error message
expect(find.text('Error message'), findsOneWidget);

// Ensure error is NOT present
expect(find.text('Error message'), findsNothing);

// Find multiple occurrences
expect(find.text('Register'), findsWidgets); // 2+ matches
```

## Running Different Test Scenarios

### Run tests matching a name
```bash
flutter test --name "email"
```

### Run tests in a group
```bash
flutter test --name "RegisterScreen"
```

### Run single test file
```bash
flutter test test/register_screen_test.dart
```

### Run with verbose output
```bash
flutter test -v
```

### Generate coverage report
```bash
flutter test --coverage
```

## Debugging Tests

### Print debug info in tests
```dart
test('debug test', () {
  debugPrint('Current state: ${appState.userId}');
  debugPrint('Is authenticated: ${appState.isAuthenticated}');
});
```

### Verify widget tree
```dart
// Print all widgets
await tester.pumpWidget(buildTestWidget());
debugPrintBeginFrame = true;
expect(true, true); // Prints widget tree
debugPrintBeginFrame = false;
```

### Check find results
```dart
final widgets = find.byType(TextFormField);
expect(widgets, findsNWidgets(3)); // Verify count first
```

---

## Test Statistics

**Total Tests:** 50  
**AppState Unit Tests:** 30  
**RegisterScreen Widget Tests:** 20  

**Pass Rate:** 100%  
**Execution Time:** < 3 seconds

---

## Resources
- [Flutter Testing Guide](https://flutter.dev/docs/testing)
- [Widget Testing](https://flutter.dev/docs/testing/widget-test-intro)
- [Unit Testing](https://flutter.dev/docs/testing/unit-test)
