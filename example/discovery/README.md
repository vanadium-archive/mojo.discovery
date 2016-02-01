# Discovery

A simple Flutter app that uses v23 discovery.

# Prerequisites

## Flutter

A clone of https://github.com/flutter/flutter/ at the commit # specified in FLUTTER_VERSION file must be available in a directory
called `flutter` at the same level as $JIRI_ROOT directory.

## Mojo

Mojo profile for Android target must be installed. You can run `jiri v23-profile install --target=arm-android mojo` to install it.

## Dart

Mojo profile must be installed. You can run `jiri v23-profile install dart` to install it.

## Android Setup

Currently Flutter requires an Android device running the Lollipop (or newer) version of the Android operating system.
`adb` tool from Android SDK needs to be installed. Please follow instructions on setting up your android device [here](http://flutter.io/getting-started/#setting-up-your-android-device)

# Running Discovery Demo

Connect your Android device via USB and ensure `Android debugging` is enabled, then execute:
```
make run
```

If you have multiple Android devices connected, you can set the DEVICE_NUM enviroment variable to choose the device
