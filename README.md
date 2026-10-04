Ändern:

pubspec.yaml: name und description

"fluttertemplate" ersetzen:
android/app/build.gradle(.kts) 
MainActivity.kt
ios/Runner.xcodeproj/project.pbxproj (kommt mehrfach vor)
web/index.html 
web/manifest.json


android/app/src/main/kotlin/com Ordnername ändern

Außerdem: die README und der Name Ordners.

sichtbarer Name der App:
    AndroidManifest.xml <application>-Tag: android:label="Flutter Template"
    Info.plist <key>CFBundleDisplayName</key><string>Flutter Template</string><key>CFBundleName</key><string>Flutter Template</string>
    MaterialApp title: 'Flutter Template'