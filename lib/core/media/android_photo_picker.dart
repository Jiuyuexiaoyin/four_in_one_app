import 'package:flutter/foundation.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

/// Opts Android into the system Photo Picker while preserving the plugin's
/// platform fallback on devices where the picker is unavailable.
void configureAndroidPhotoPicker() {
  if (kIsWeb) {
    return;
  }

  final implementation = ImagePickerPlatform.instance;
  if (implementation is ImagePickerAndroid) {
    implementation.useAndroidPhotoPicker = true;
  }
}
