# Test Plan for Sociefy App

## 1. Performance
### Requirement:
The app should respond within 2 seconds for key actions (e.g., loading the Messages tab, joining a society).

### Test Scenario 1: Loading the Messages Tab
- **Purpose**: Verify that the Messages tab loads within 2 seconds.
- **Steps**:
  1. Open the app.
  2. Navigate to the Messages tab.
- **Expected Result**: The Messages tab loads within 2 seconds.
- **Actual Result**: [To be filled after testing]

### Test Scenario 2: Joining a Society
- **Purpose**: Verify that joining a society completes within 2 seconds.
- **Steps**:
  1. Open the app.
  2. Join a society.
- **Expected Result**: The operation completes within 2 seconds.
- **Actual Result**: [To be filled after testing]

## 2. Scalability
### Requirement:
The system should handle 100 concurrent users.

### Test Scenario 1: Concurrent Users Joining Societies
- **Purpose**: Verify that 100 users can join societies simultaneously without errors.
- **Steps**:
  1. Simulate 100 users joining societies concurrently using Firebase Emulator.
- **Expected Result**: All users successfully join societies without errors.
- **Actual Result**: [To be filled after testing]

## 3. Usability
### Requirement:
The UI should be intuitive and accessible.

### Test Scenario 1: Accessibility Compliance
- **Purpose**: Verify that the app meets accessibility standards (e.g., WCAG 2.1).
- **Steps**:
  1. Use an accessibility testing tool (e.g., Flutter's Semantics Tester).
- **Expected Result**: The app passes all accessibility checks.
- **Actual Result**: [To be filled after testing]

## 4. Security
### Requirement:
Unauthorized users should not access restricted data.

### Test Scenario 1: Firestore Rules Enforcement
- **Purpose**: Verify that Firestore rules prevent unauthorized access.
- **Steps**:
  1. Attempt to access restricted data as an unauthorized user.
- **Expected Result**: Access is denied.
- **Actual Result**: [To be filled after testing]

### Test Scenario 2: Cloud Function Authorization
- **Purpose**: Verify that Cloud Functions enforce authentication.
- **Steps**:
  1. Call a Cloud Function without authentication.
- **Expected Result**: The function returns an authentication error.
- **Actual Result**: [To be filled after testing]

---

# Automated Testing
## Flutter Integration Tests
- **Performance**: Measure response times for key actions.
- **Usability**: Verify UI elements and navigation.

## Firebase Emulator Tests
- **Scalability**: Simulate 100 concurrent users.
- **Security**: Test Firestore rules and Cloud Functions.

---

# Evidence of Testing
- **Screenshots**: Include screenshots of test results.
- **Logs**: Provide logs from automated tests.
- **Summary**: Document findings and conclusions.

---

# Functional Test Plan for Sociefy App

## 1. Overview
This test plan outlines the test cases for the Sociefy app, covering all components and features. The goal is to ensure correctness, reliability, and full code coverage.

## 2. Methodology
The following methodologies will be used:
- **Equivalence Partitioning**: Dividing input data into valid, invalid, and edge case partitions.
- **Boundary Value Analysis**: Testing at the boundaries of input ranges.
- **User Journey Testing**: Verifying end-to-end workflows.

## 3. Test Cases

### 3.1 Login/Registration Screen
#### Test Cases:
1. **Valid Login**:
   - Input: Correct email and password.
   - Expected Result: User is logged in successfully.
2. **Invalid Login**:
   - Input: Incorrect email or password.
   - Expected Result: Error message is displayed.
3. **Edge Case**:
   - Input: Empty fields, special characters.
   - Expected Result: Validation errors.

### 3.2 Society Listing and Detail Screens
#### Test Cases:
1. **Join Society**:
   - Input: Tap "Join" on a society.
   - Expected Result: User is added to the society.
2. **Leave Society**:
   - Input: Tap "Leave" on a joined society.
   - Expected Result: User is removed from the society.
3. **Edge Case**:
   - Input: Rapidly tap "Join" and "Leave".
   - Expected Result: No inconsistent state.

### 3.3 Event Creation and Management Screen
#### Test Cases:
1. **Create Event**:
   - Input: Valid event details.
   - Expected Result: Event is created successfully.
2. **Edit Event**:
   - Input: Modify event details.
   - Expected Result: Changes are saved.
3. **Delete Event**:
   - Input: Delete an event.
   - Expected Result: Event is removed.
4. **Edge Case**:
   - Input: Empty fields, invalid dates.
   - Expected Result: Validation errors.

### 3.4 Calendar Screen
#### Test Cases:
1. **Save Event to Calendar**:
   - Input: Select an event and save to calendar.
   - Expected Result: Event appears in the calendar.
2. **View Events**:
   - Input: Open the calendar.
   - Expected Result: Events are displayed.
3. **Edge Case**:
   - Input: Overlapping events.
   - Expected Result: No conflicts.

### 3.5 User Profile Screen
#### Test Cases:
1. **View Profile**:
   - Input: Open profile screen.
   - Expected Result: User details are displayed.
2. **Edit Profile**:
   - Input: Modify user details.
   - Expected Result: Changes are saved.
3. **Edge Case**:
   - Input: Invalid email, empty fields.
   - Expected Result: Validation errors.

## 4. Tools
- **JUnit**: For unit testing.
- **Espresso**: For UI testing.
- **JaCoCo**: For code coverage reporting.

## 5. Test Coverage
The automated tests will cover all components and features, ensuring full code coverage. A JaCoCo report will be generated to verify coverage.

## 6. Test Report
The test results and code coverage report will be included in the submission.