# Dive

This is the codebase for the Dive front end application.

## Pre-requisites

1. Install flutter from the following link : [Install flutter](https://flutter.dev/docs/get-started/install).
2. Install either Android Studio (preferred) or VS code. You can use any other text editor but a fully powered IDE makes the development easier. You can get Android Studio from the following link : [Install Android Studio](https://developer.android.com/studio/install).
3. Install an android emulator from the following link if you want to test the app on an android device : [Install emulator](https://developer.android.com/studio/run/emulator). Alternatively you can use a physical device.
4. Install Xcode from the Mac App store if you are using Mac and configure the Xcode command line tools by following the instructions in this link : [Configure Xcode command line tools](https://flutter.dev/docs/get-started/install/macos#install-xcode).
5. Set up the iOS simulator if you are using Mac from [here](https://flutter.dev/docs/get-started/install/macos#set-up-the-ios-simulator).

For a comprehensive guide by the flutter team, follow this :
- [Guide for windows](https://flutter.dev/docs/get-started/install/windows)
- [Guide for macOS](https://flutter.dev/docs/get-started/install/macos)

## Getting Started
1. To get started with the app, first clone the app.
    ```
    git clone https://github.com/Prajval/dive-front-end.git
    ```
2. To install all the dependencies, use the `pub get` command, like so :
    ```
    flutter pub get
    ```
3. To run the application on an emulator or a device, use the following command : 
    ```
    flutter run
    ```

## Running unit tests and widget tests
1. To run both the unit tests and the widget tests, run the following command :
    ```
    flutter test
    ```
2. To run both the unit tests and the widget tests and generate coverage info for the same, use :
    ```
    flutter test --coverage
    ```
3. Coverage info is generate in the /coverage folder in the project's root directory.
4. In order to get a pictorial coverage report from the coverage files generated in `#Step 2`, you need to install lcov, by running,
    ```
    brew install lcov
    ```
5. To generate the coverage report, run : 
    ```
    genhtml coverage/lcov.info -o coverage/html
    ```
6. The generated report is present in the file `index.html`.

## Running integration tests
1. To run integration tests, a physical device or an emulator needs to be running.
2. Then, run the following command :
    ```
    flutter drive --target=test_driver/app.dar
    ```
