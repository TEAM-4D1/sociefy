How to Run the App 
==================
This guide provides step-by-step instructions on how to set up and run the Sociefy application on your local machine.

Prerequisites
==============
Before you begin, ensure you have the following installed:
* Flutter SDK: Version 3.0 or higher.
* Dart SDK: Version 2.14 or higher.
* An IDE such as Android Studio, Visual Studio Code, or IntelliJ IDEA with Flutter and Dart plugins.
* Emulator: An active Android or iOS emulator, or a physical device connected via USB.

Installation Steps
===================
1. Clone the Repository:
   Open your terminal and run:
.. code-block:: bash
    git clone <https://github.com/TEAM-4D1/sociefy.git>
    cd sociefy-main

2. Install Dependencies:
Fetch all the required Flutter and Firebase packages by running:
.. code-block:: bash
    flutter pub get

3. Run the application 
Make sure your emulator is running, then build and launch the app:

.. code-block:: bash
    flutter run

Troubleshooting
=================
* If you encounter connection errors, ensure your emulator has internet access to connect to the Firebase backend.
* Run flutter doctor in your terminal if the app refuses to build; this will verify your environment is set up correctly.
