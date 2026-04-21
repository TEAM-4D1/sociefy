# Test Plan for Non-Functional Requirements

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