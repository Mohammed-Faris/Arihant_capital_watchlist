#ACML

To build/Run the application using flavor

For IOS
eg:- 
flutter build ios --release --no-codesign --flavor dev -t lib/main_dev.dart 
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor qa -t lib/main_qa.dart
[here dev refer to one of the Targets]

For Android
eg:-
flutter build apk --flavor dev -t lib/main_dev.dart
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor qa -t lib/main_qa.dart 
Android - comment to create aab
flutter build appbundle --flavor cug -t lib/main_cug.dart
[here dev refer to one of the flavors, which is found in build.gradle]


Localization setup

1. Create a file called app_localization.dart
2. Add corresponding package in pubspec.yaml
3. Add new string object in app_localization.dart file, like below 
    String get exitAppMsg {
    return Intl.message('Are you sure want to exit from the app?');
  }
    exitAppMsg is the reference object for 'Are you sure want to exit from the app?' string.

4. Run the below command in terminal for generate an arb template.
    flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/src/localization lib/src/localization/app_localization.dart

 This command will generate a file called intl_messages.arb file into lib/src/localization and this file serves as a template for the English.

5. create a file in the name  of intl_en.arb (for refering to English).

6. Copy the newly created block into intl_en.arb from intl_messages.arb
   ex: {
  "@@last_modified": "2020-07-30T11:18:18.467092",
  "Are you sure want to exit from the app?": "Are you sure want to exit from the app?",
  "@Are you sure want to exit from the app?": {
    "type": "text",
    "placeholders": {}
  }
} 

7. Run the below command to link the initializeMessages.
    flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/src/localization \ --no-use-deferred-loading lib/src/localization/app_localization.dart lib/src/localization/intl_*.arb
    This command will generate message_*.dart files. 

8. Create a file for app_localization_delegate.dart 



To use localization string into your class
1. import the app_localization.dart file like below
   import 'package:acml/src/localization/app_localization.dart';

2. Then you can use localization string like below
   AppLocalizations.of(context).exitAppMsg
   This will retrun the 'Are you sure want to exit from the app?' string. 

Reference url : https://proandroiddev.com/flutter-localization-step-by-step-30f95d06018d
