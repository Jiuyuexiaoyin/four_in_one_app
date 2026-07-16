import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

const _requiredVectors = <String>[
  'get_ready_mark.svg',
  'get_ready_mark_dark.svg',
  'get_ready_mark_light.svg',
  'get_ready_mark_monochrome.svg',
  'get_ready_wordmark_horizontal.svg',
  'get_ready_logo_vertical.svg',
  'get_ready_splash_logo.svg',
  'get_ready_notification_mark.svg',
];

const _obsoleteProductionVectors = <String>[
  'getready_mark.svg',
  'getready_mark_dark.svg',
  'getready_mark_light.svg',
  'getready_mark_monochrome.svg',
  'getready_wordmark_horizontal.svg',
  'getready_logo_vertical.svg',
  'getready_splash_logo.svg',
  'getready_notification_mark.svg',
];

const _requiredRasterDimensions = <String, (int, int)>{
  'get_ready_mark_1024.png': (1024, 1024),
  'get_ready_mark_512.png': (512, 512),
  'get_ready_mark_256.png': (256, 256),
  'get_ready_mark_128.png': (128, 128),
  'get_ready_mark_64.png': (64, 64),
  'get_ready_mark_32.png': (32, 32),
  'get_ready_mark_24.png': (24, 24),
  'get_ready_mark_16.png': (16, 16),
  'get_ready_wordmark_horizontal.png': (1600, 400),
  'get_ready_splash_dark.png': (1440, 2560),
  'get_ready_splash_light.png': (1440, 2560),
};

const _requiredProofDimensions = <String, (int, int)>{
  'get_ready_master_contact_sheet.png': (2400, 1600),
  'get_ready_launcher_mask_preview.png': (2200, 780),
  'get_ready_dark_light_preview.png': (2200, 1100),
  'get_ready_small_size_preview.png': (2304, 1900),
  'get_ready_notification_preview.png': (1800, 900),
  'get_ready_splash_preview.png': (2200, 1400),
  'get_ready_wordmark_preview.png': (2200, 1200),
  'old_vs_new_brand_comparison.png': (2200, 1100),
  'get_ready_geometry_before_after.png': (2240, 1240),
  'get_ready_corrected_small_size_preview.png': (2304, 1900),
  'get_ready_corrected_contact_sheet.png': (2400, 1600),
  'get_ready_same_scale_comparison.png': (2240, 1240),
  'get_ready_reference_vector_overlay.png': (1200, 1280),
  'get_ready_landmark_comparison.png': (2200, 1360),
  'get_ready_silhouette_corrected_contact_sheet.png': (2400, 1600),
  'get_ready_silhouette_small_size_preview.png': (2304, 1900),
};

const _requiredReferenceCropDimensions = <String, (int, int)>{
  'reference_primary_mark.png': (840, 856),
  'reference_construction_mark.png': (988, 1008),
  'reference_launcher_mark.png': (608, 600),
};

void main() {
  group('Get Ready 2.6 production brand assets', () {
    test('required SVG masters use the approved controlled vector grammar', () {
      for (final name in _requiredVectors) {
        final file = File('assets/branding/$name');
        expect(file.existsSync(), isTrue, reason: name);
        final svg = file.readAsStringSync();
        expect(svg, contains('<svg'), reason: name);
        expect(svg, isNot(contains('<image')), reason: name);
        expect(svg, isNot(contains('<filter')), reason: name);
        expect(svg, isNot(contains('<linearGradient')), reason: name);
        expect(svg, isNot(contains('<radialGradient')), reason: name);
        expect(svg, isNot(contains('href=')), reason: name);
        expect(svg, isNot(contains('transform=')), reason: name);
        expect(svg, isNot(contains('#0D1117')), reason: name);
        expect(svg, isNot(contains('#1A1F28')), reason: name);
        expect(svg, isNot(contains('#22C55E')), reason: name);
        expect(svg, isNot(contains('#F1F3F5')), reason: name);
        expect(svg, isNot(contains('step-top')), reason: name);
        expect(svg, isNot(contains('step-middle')), reason: name);
        expect(svg, isNot(contains('step-bottom')), reason: name);
      }

      for (final name in _obsoleteProductionVectors) {
        expect(
          File('assets/branding/$name').existsSync(),
          isFalse,
          reason: 'obsolete P10 production master must be removed: $name',
        );
      }
    });

    test('master geometry is the approved open arc, status bar, and dot', () {
      final primary = File(
        'assets/branding/get_ready_mark.svg',
      ).readAsStringSync();

      expect(primary, contains('viewBox="0 0 1000 1000"'));
      expect(primary, contains('id="open-arc"'));
      expect(
        primary,
        contains(
          'M675 300 C660 240 552 218 472 226 C326 236 230 351 230 497 C230 637 330 744 460 750',
        ),
      );
      expect(primary, isNot(contains('M556.187 680.213')));
      expect(primary, contains('stroke-width="80"'));
      expect(primary, contains('stroke-linecap="round"'));
      expect(
        primary,
        contains(
          'id="status-bar" x="583" y="538" width="225" height="75" rx="37.5"',
        ),
      );
      expect(primary, contains('id="readiness-dot" cx="719" cy="735" r="75"'));
      expect(RegExp(r'id="open-arc"').allMatches(primary), hasLength(1));
      expect(RegExp(r'id="status-bar"').allMatches(primary), hasLength(1));
      expect(RegExp(r'id="readiness-dot"').allMatches(primary), hasLength(1));

      final barX = _svgNumber(primary, 'status-bar', 'x');
      final barY = _svgNumber(primary, 'status-bar', 'y');
      final barWidth = _svgNumber(primary, 'status-bar', 'width');
      final barHeight = _svgNumber(primary, 'status-bar', 'height');
      final dotX = _svgNumber(primary, 'readiness-dot', 'cx');
      final dotY = _svgNumber(primary, 'readiness-dot', 'cy');
      final dotRadius = _svgNumber(primary, 'readiness-dot', 'r');
      final dotDiameter = dotRadius * 2;
      expect(barWidth / dotDiameter, closeTo(1.5, 0.000001));
      expect(barHeight / dotDiameter, closeTo(0.5, 0.000001));
      expect(
        ((dotY - dotRadius) - (barY + barHeight)) / dotDiameter,
        closeTo(47 / 150, 0.000001),
      );
      expect(
        (dotX - (barX + barWidth / 2)) / dotDiameter,
        closeTo(23.5 / 150, 0.000001),
      );
      expect(525 / 605, closeTo(0.868, 0.001));
      expect(80 / 525, closeTo(0.145, 0.02));
      expect((460 - 190) / 525, closeTo(0.520, 0.03));
      expect((750 - 185) / 605, closeTo(0.934, 0.03));
      expect((barX + barWidth / 2 - 190) / 525, closeTo(0.957, 0.03));
      expect((barY + barHeight / 2 - 185) / 605, closeTo(0.644, 0.03));
      expect((dotX - 190) / 525, closeTo(1.003, 0.03));
      expect((dotY - 185) / 605, closeTo(0.914, 0.03));
    });

    test('approved naming, tagline, and light/dark colors are exact', () {
      final wordmark = File(
        'assets/branding/get_ready_wordmark_horizontal.svg',
      ).readAsStringSync();
      final splash = File(
        'assets/branding/get_ready_splash_logo.svg',
      ).readAsStringSync();
      final light = File(
        'assets/branding/get_ready_mark_light.svg',
      ).readAsStringSync();
      final dark = File(
        'assets/branding/get_ready_mark_dark.svg',
      ).readAsStringSync();

      expect(wordmark, contains('>Get</text>'));
      expect(wordmark, contains('>Ready</text>'));
      expect(wordmark, isNot(contains('>get</text>')));
      expect(wordmark, isNot(contains('>ready</text>')));
      expect(splash, contains('随时准备，迎接每一次机会。'));
      expect(splash, isNot(contains('一步一个脚印，持续前进')));
      expect(light, contains('stroke="#111111"'));
      expect(light, contains('fill="#16A34A"'));
      expect(dark, contains('stroke="#F6F7F8"'));
      expect(dark, contains('fill="#16A34A"'));
    });

    test('required generated PNGs have exact dimensions, RGBA, and sRGB', () {
      for (final entry in _requiredRasterDimensions.entries) {
        final file = File('assets/branding/generated/${entry.key}');
        expect(file.existsSync(), isTrue, reason: entry.key);
        expect(_pngDimensions(file), entry.value, reason: entry.key);
        expect(_pngColorType(file), 6, reason: '${entry.key} must be RGBA');
        expect(_pngChunkTypes(file), contains('sRGB'), reason: entry.key);
      }

      expect(
        File(
          'assets/branding/generated/get_ready_asset_manifest.json',
        ).existsSync(),
        isTrue,
      );
    });

    test('all sixteen P11 brand proofs and three reference crops are stable', () {
      for (final entry in _requiredProofDimensions.entries) {
        final name = entry.key;
        final file = File('reports/p11_get_ready_brand_assets/$name');
        expect(file.existsSync(), isTrue, reason: name);
        expect(_pngDimensions(file), entry.value, reason: name);
        expect(_pngChunkTypes(file), contains('sRGB'), reason: name);
      }
      for (final entry in _requiredReferenceCropDimensions.entries) {
        final file = File(
          'reports/p11_get_ready_brand_assets/reference_crops/${entry.key}',
        );
        expect(file.existsSync(), isTrue, reason: entry.key);
        expect(_pngDimensions(file), entry.value, reason: entry.key);
        expect(_pngChunkTypes(file), contains('sRGB'), reason: entry.key);
      }

      final readmeBrand = File('docs/screenshots/get_ready_branding.png');
      expect(readmeBrand.existsSync(), isTrue);
      expect(_pngDimensions(readmeBrand), (2400, 1600));
      expect(
        readmeBrand.readAsBytesSync(),
        File(
          'reports/p11_get_ready_brand_assets/get_ready_silhouette_corrected_contact_sheet.png',
        ).readAsBytesSync(),
      );
    });

    test('legacy launcher and round icons cover every Android density', () {
      const densities = <String, int>{
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
      };
      for (final entry in densities.entries) {
        for (final name in const ['ic_launcher.png', 'ic_launcher_round.png']) {
          final file = File(
            'android/app/src/main/res/mipmap-${entry.key}/$name',
          );
          expect(file.existsSync(), isTrue, reason: file.path);
          expect(_pngDimensions(file), (
            entry.value,
            entry.value,
          ), reason: file.path);
          expect(_pngChunkTypes(file), contains('sRGB'), reason: file.path);
        }
      }
    });

    test('adaptive launcher separates background and includes themed icon', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      final foreground = File(
        'android/app/src/main/res/drawable/ic_launcher_foreground.xml',
      ).readAsStringSync();
      final monochrome = File(
        'android/app/src/main/res/drawable/ic_launcher_monochrome.xml',
      ).readAsStringSync();

      expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
      expect(
        manifest,
        contains('android:roundIcon="@mipmap/ic_launcher_round"'),
      );
      expect(foreground, contains('android:strokeWidth="8.64"'));
      expect(foreground, contains('@color/getready_brand_green'));
      expect(
        foreground,
        contains('M72.9,32.4C71.28,25.92 59.616,23.544 50.976,24.408'),
      );
      expect(
        foreground,
        contains('M67.014,58.104H83.214A4.05,4.05 0,0 1,87.264 62.154'),
      );
      expect(foreground, contains('M77.652,71.28A8.1,8.1 0,1 1,77.652 87.48'));
      expect(foreground, isNot(contains('M60.068,73.463')));
      expect(foreground, isNot(contains('<shape')));
      expect(monochrome, contains('android:strokeColor="#FFFFFFFF"'));
      expect(monochrome, isNot(contains('@color/getready_brand_green')));

      for (final name in const ['ic_launcher.xml', 'ic_launcher_round.xml']) {
        final adaptive = File(
          'android/app/src/main/res/mipmap-anydpi-v26/$name',
        ).readAsStringSync();
        expect(adaptive, contains('@color/getready_ink_black'));
        expect(adaptive, contains('@drawable/ic_launcher_foreground'));

        final themed = File(
          'android/app/src/main/res/mipmap-anydpi-v33/$name',
        ).readAsStringSync();
        expect(themed, contains('@drawable/ic_launcher_monochrome'));
      }
    });

    test(
      'notification icon is the new monochrome mark and keeps P9 fallback',
      () {
        final icon = File(
          'android/app/src/main/res/drawable/ic_stat_getready.xml',
        ).readAsStringSync();
        final keep = File(
          'android/app/src/main/res/raw/keep.xml',
        ).readAsStringSync();
        final service = File(
          'lib/core/notifications/app_local_notification_service.dart',
        ).readAsStringSync();

        expect(RegExp('android:pathData=').allMatches(icon), hasLength(3));
        expect(icon, contains('android:strokeColor="#FFFFFFFF"'));
        expect(icon, contains('android:fillColor="#FFFFFFFF"'));
        expect(icon, contains('android:strokeLineCap="round"'));
        expect(icon, contains('M16.693,6.733C16.293,5.133'));
        expect(icon, contains('M15.24,13.08H19.24A1,1'));
        expect(icon, contains('M17.867,16.333A2,2'));
        expect(icon, isNot(contains('M13.228,17.324')));
        expect(icon, isNot(contains('#16A34A')));
        expect(icon, isNot(contains('@color/')));
        expect(icon, isNot(contains('gradient')));
        expect(keep, contains('@drawable/ic_stat_getready'));
        expect(keep, contains('@drawable/ic_stat_checkin'));
        expect(
          service,
          contains("static const notificationIcon = 'ic_stat_getready';"),
        );
        expect(
          service,
          isNot(contains("notificationIcon = 'ic_stat_checkin'")),
        );
      },
    );

    test(
      'Android legacy and Android 12 splash use the new stable resources',
      () {
        for (final path in const [
          'android/app/src/main/res/drawable/launch_background.xml',
          'android/app/src/main/res/drawable-v21/launch_background.xml',
        ]) {
          final splash = File(path).readAsStringSync();
          expect(splash, contains('@color/getready_ink_black'));
          expect(splash, contains('@drawable/getready_splash_brand'));
        }
        for (final path in const [
          'android/app/src/main/res/values-v31/styles.xml',
          'android/app/src/main/res/values-night-v31/styles.xml',
        ]) {
          final styles = File(path).readAsStringSync();
          expect(styles, contains('android:windowSplashScreenBackground'));
          expect(styles, contains('@color/getready_ink_black'));
          expect(styles, contains('@drawable/ic_splash_getready'));
        }
        final splashVector = File(
          'android/app/src/main/res/drawable/ic_splash_getready.xml',
        ).readAsStringSync();
        expect(splashVector, contains('android:strokeWidth="8.64"'));
        expect(splashVector, contains('@color/getready_brand_green'));
        expect(
          File(
            'android/app/src/main/res/drawable-nodpi/getready_splash_brand.png',
          ).existsSync(),
          isTrue,
        );
      },
    );

    test('Android color resources contain only the approved brand palette', () {
      final colors = File(
        'android/app/src/main/res/values/colors.xml',
      ).readAsStringSync();
      for (final color in const [
        '#111111',
        '#16A34A',
        '#6B7280',
        '#E5E7EB',
        '#F6F7F8',
      ]) {
        expect(colors, contains(color), reason: color);
      }
      for (final stale in const ['#0D1117', '#1A1F28', '#22C55E', '#F1F3F5']) {
        expect(colors, isNot(contains(stale)), reason: stale);
      }
    });

    test('visible product naming and version are exactly Get Ready 2.6.0', () {
      final strings = File(
        'android/app/src/main/res/values/strings.xml',
      ).readAsStringSync();
      final app = File('lib/app/app.dart').readAsStringSync();
      final settings = File(
        'lib/features/settings/presentation/pages/settings_page.dart',
      ).readAsStringSync();
      final pubspec = File('pubspec.yaml').readAsStringSync();

      expect(strings, contains('<string name="app_name">Get Ready</string>'));
      expect(app, contains("title: 'Get Ready'"));
      expect(settings, contains("semanticsLabel: 'Get Ready'"));
      expect(settings, contains('随时准备，迎接每一次机会。'));
      expect(settings, contains('版本 2.6.0'));
      expect(settings, isNot(contains('版本 1.1.5+17')));
      expect(pubspec, contains('name: four_in_one_app'));
      expect(pubspec, contains('version: 2.6.0+18'));
      expect(
        pubspec,
        contains('assets/branding/generated/get_ready_mark_64.png'),
      );
    });

    test('generator is constrained to new P11 output paths and geometry', () {
      final generator = File(
        'tools/branding/GenerateGetreadyAssets.java',
      ).readAsStringSync();
      expect(generator, contains('"svg", "g", "rect", "circle", "path"'));
      expect(generator, contains('reports/p11_get_ready_brand_assets/'));
      expect(
        generator,
        contains('new int[] {1024, 512, 256, 128, 64, 32, 24, 16}'),
      );
      expect(generator, contains('old_vs_new_brand_comparison.png'));
      expect(generator, contains('get_ready_geometry_before_after.png'));
      expect(generator, contains('get_ready_same_scale_comparison.png'));
      expect(generator, contains('get_ready_reference_vector_overlay.png'));
      expect(generator, contains('get_ready_landmark_comparison.png'));
      expect(generator, contains('reference_primary_mark.png'));
      expect(generator, contains('MASTER_ARC_PATH'));
      expect(generator, isNot(contains('M556.187 680.213')));
      expect(generator, contains('assertCorrectedGeometry(masters)'));
      expect(generator, isNot(contains('reports/p10_getready_brand_assets/')));
    });
  });
}

double _svgNumber(String svg, String id, String attribute) {
  final match = RegExp('id="$id"[^>]*\\b$attribute="([^"]+)"').firstMatch(svg);
  expect(match, isNotNull, reason: '#$id $attribute');
  return double.parse(match!.group(1)!);
}

(int, int) _pngDimensions(File file) {
  final bytes = file.readAsBytesSync();
  expect(bytes.length, greaterThanOrEqualTo(26), reason: file.path);
  expect(bytes.sublist(0, 8), const [
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
  ], reason: file.path);
  final data = ByteData.sublistView(Uint8List.fromList(bytes));
  return (data.getUint32(16), data.getUint32(20));
}

int _pngColorType(File file) {
  final bytes = file.readAsBytesSync();
  expect(bytes.length, greaterThanOrEqualTo(26), reason: file.path);
  return bytes[25];
}

Set<String> _pngChunkTypes(File file) {
  final bytes = Uint8List.fromList(file.readAsBytesSync());
  final data = ByteData.sublistView(bytes);
  final chunks = <String>{};
  var offset = 8;
  while (offset + 12 <= bytes.length) {
    final length = data.getUint32(offset);
    final type = ascii.decode(bytes.sublist(offset + 4, offset + 8));
    chunks.add(type);
    offset += 12 + length;
    if (type == 'IEND') {
      break;
    }
  }
  return chunks;
}
