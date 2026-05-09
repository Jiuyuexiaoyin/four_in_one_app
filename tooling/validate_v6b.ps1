Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Set-Location "D:\AI\Projects\four_in_one_app"

$env:ANDROID_SDK_ROOT = "D:\AI\SDKs\Android"
$env:ANDROID_HOME = "D:\AI\SDKs\Android"
$env:JAVA_HOME = "D:\AI\Tools\AndroidStudio\android-studio\jbr"
$env:PUB_CACHE = "D:\AI\Cache\Pub"
$env:GRADLE_USER_HOME = "D:\AI\Cache\Gradle"
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
$env:DART_SUPPRESS_ANALYTICS = "true"
$env:FLUTTER_SUPPRESS_ANALYTICS = "true"

$dart = "D:\AI\Tools\Flutter\flutter\bin\cache\dart-sdk\bin\dart.exe"
$flutter = "D:\AI\Tools\Flutter\flutter\bin\flutter.bat"

Write-Host "Dart version"
& $dart --version

Write-Host "Flutter version"
& $flutter --version

Write-Host "Formatting V6B files"
& $dart format --set-exit-if-changed "lib/features/goals/domain/models/goal_item.dart"
& $dart format --set-exit-if-changed "lib/features/goals/application/goals_store.dart"
& $dart format --set-exit-if-changed "lib/features/goals/data/goals_local_storage.dart"
& $dart format --set-exit-if-changed "lib/features/goals/presentation/pages/goals_page.dart"
& $dart format --set-exit-if-changed "lib/shared/widgets/product/plan_tree_row.dart"
& $dart format --set-exit-if-changed "test/goals_persistence_test.dart"
& $dart format --set-exit-if-changed "test/goals_flow_test.dart"

Write-Host "Focused Plan tests"
& $flutter test --no-pub "test/goals_persistence_test.dart"
& $flutter test --no-pub "test/goals_flow_test.dart"

Write-Host "Targeted analyze"
& $flutter analyze --no-pub "lib/features/goals" "test/goals_persistence_test.dart" "test/goals_flow_test.dart"

Write-Host "Full analyze"
& $flutter analyze --no-pub

Write-Host "Full tests"
& $flutter test --no-pub

Write-Host "Debug build"
& $flutter build apk --debug --no-pub

Write-Host "V6B validation completed"

