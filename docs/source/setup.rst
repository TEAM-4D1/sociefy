How to Run the App 
==================

This guide provides step-by-step instructions on how to set up and run the Sociefy application on your local machine.

Prerequisites
==============

Before you begin, ensure you have the following installed:

* **Flutter SDK:** Version 3.0 or higher (includes Dart SDK)
* **Dart SDK:** Version 3.9 or higher
* **IDE:** Android Studio, Visual Studio Code, or IntelliJ IDEA with Flutter and Dart plugins
* **Emulator or Device:** An active Android or iOS emulator, or a physical device connected via USB
* **Firebase CLI:** Install via ``npm install -g firebase-tools`` (optional but recommended)
* **Google Account:** Required for Firebase project creation and configuration

You can verify your Flutter installation by running:

.. code-block:: bash

    flutter doctor

This command will check all dependencies and alert you to any issues.

Firebase Setup
==============

Sociefy uses Firebase as its backend for authentication, database, and storage. Follow these steps to configure Firebase for the project:

1. **Create a Firebase Project**

   a. Go to `Firebase Console <https://console.firebase.google.com/>`_
   b. Click "Create a new project" and enter "sociefy" as the project name
   c. Follow the setup wizard to create the project
   d. Select your Google account and agree to the terms

2. **Enable Authentication**

   a. In the Firebase Console, navigate to "Authentication" in the left sidebar
   b. Click "Get started"
   c. Select "Email/Password" and enable it
   d. (Optional) Enable "Google Sign-In" for additional login options
   e. Go to "Sign-in method" and verify Email/Password is enabled

3. **Create a Firestore Database**

   a. Navigate to "Firestore Database" in the left sidebar
   b. Click "Create database"
   c. Select "Start in test mode" (for development; switch to production rules before deploying)
   d. Choose a location closest to your users (default is fine for development)
   e. Click "Create"

4. **Enable Storage**

   a. Navigate to "Storage" in the left sidebar
   b. Click "Get started"
   c. Select "Start in test mode" for development
   d. Choose a location matching your Firestore location
   e. Click "Done"

5. **Download Configuration Files**

   a. Navigate to "Project Settings" (gear icon in top-left)
   b. Click "Your apps" and select your Android/iOS app
   c. Download the ``google-services.json`` file (for Android)
   d. Place the file in ``android/app/`` directory
   e. For iOS, download ``GoogleService-Info.plist`` and add to Xcode

6. **Configure Flutter with Firebase**

   a. Run the Firebase CLI setup:

   .. code-block:: bash

       firebase login
       firebase init

   b. When prompted, select your Sociefy project
   c. This generates necessary configuration files automatically

Installation Steps
==================

1. **Clone the Repository**

   Open your terminal and run:

   .. code-block:: bash

       git clone https://github.com/TEAM-4D1/sociefy.git
       cd sociefy

2. **Install Dependencies**

   Fetch all the required Flutter and Firebase packages:

   .. code-block:: bash

       flutter pub get

   This will download:
   - Flutter and Dart SDK dependencies
   - Firebase packages (firebase_core, cloud_firestore, firebase_auth, etc.)
   - Provider for state management
   - Other required packages (intl, image_picker, file_picker, etc.)

3. **Ensure Firebase Configuration**

   Make sure your Firebase configuration files are in place:
   - ``android/app/google-services.json`` (Android)
   - ``ios/GoogleService-Info.plist`` (iOS)

Running the App
===============

Make sure your emulator is running or a physical device is connected, then build and launch the app:

.. code-block:: bash

    flutter run

This command will:
- Compile the Dart code
- Build the native Android/iOS application
- Install it on your connected device/emulator
- Launch the app with hot-reload enabled

**For Android emulator:**

.. code-block:: bash

    flutter emulators --launch Pixel_4_API_30
    flutter run

**For iOS simulator:**

.. code-block:: bash

    open -a Simulator
    flutter run -d iPhone

**For physical device:**

.. code-block:: bash

    # List connected devices
    flutter devices

    # Run on specific device
    flutter run -d <device_id>

Once the app is running, you can use hot-reload (press ``r`` in terminal) to see changes instantly without rebuilding.

Running Tests
=============

Sociefy includes comprehensive unit and widget tests. Run tests with the following commands:

**Run all tests:**

.. code-block:: bash

    flutter test

This will execute all test files in the ``test/`` directory and display results.

**Run specific test file:**

.. code-block:: bash

    flutter test test/profile_screen_test.dart

**Run tests with coverage:**

.. code-block:: bash

    flutter test --coverage

This generates a coverage report at ``coverage/lcov.info`` showing which code paths are tested.

**View test results:**

Test results in JSON format are available in ``test_report.json`` after running tests:

.. code-block:: bash

    flutter test --reporter json > test_report.json

**Run tests with verbose output:**

.. code-block:: bash

    flutter test --verbose

This shows detailed output for each test case as it runs, useful for debugging test failures.

Test Files
==========

Sociefy has test coverage for:

* ``test/profile_screen_test.dart`` - Tests for ProfileScreen AppState behavior and guest user flows
* ``test/society_browser_screen_test.dart`` - Tests for SocietyBrowserScreen search and filtering
* ``test/committee_sign_in_screen_test.dart`` - Tests for CommitteeSignInScreen authentication
* ``test/app_state_unit_test.dart`` - Comprehensive unit tests for AppState state management
* Additional integration and widget tests

Troubleshooting
===============

**Connection Errors to Firebase:**
- Ensure your emulator or device has internet access
- Verify your Firebase configuration files (google-services.json, GoogleService-Info.plist) are in the correct locations
- Check that your Firebase project is enabled and accessible

**Build Failures:**

Run the following to diagnose environment issues:

.. code-block:: bash

    flutter doctor -v

This detailed output will help identify missing dependencies or configuration issues.

**Gradle or CocoaPods Issues:**

For Android:

.. code-block:: bash

    cd android
    ./gradlew clean
    cd ..
    flutter clean
    flutter pub get
    flutter run

For iOS:

.. code-block:: bash

    cd ios
    rm -rf Pods
    rm Podfile.lock
    cd ..
    flutter clean
    flutter pub get
    flutter run

**Hot Reload Not Working:**

Hot reload may not work for certain changes (native code, pubspec.yaml). In these cases, use hot restart:

.. code-block:: bash

    flutter run
    # Press 'R' for restart instead of 'r' for reload
