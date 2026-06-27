# CONTEXTO COMPLETO DEL PROYECTO

Generado automáticamente por export_context_flutter.dart


# ANÁLISIS DE ARQUITECTURA

## ACIERTOS

✅ Feature "auth" contiene data/domain/presentation.


# ESTRUCTURA DEL PROYECTO

📄 .env
📄 .flutter-plugins
📄 .flutter-plugins-dependencies
📄 .gitignore
📄 .metadata
📄 README.md
📄 analysis_options.yaml
📁 android
    📄 .gitignore
    📁 app
        📄 build.gradle
        📁 src
            📁 debug
                📄 AndroidManifest.xml
            📁 main
                📄 AndroidManifest.xml
                📁 java
                    📁 io
                        📁 flutter
                            📁 plugins
                                📄 GeneratedPluginRegistrant.java
                📁 kotlin
                    📁 com
                        📁 example
                            📁 elecciones
                                📄 MainActivity.kt
                📁 res
                    📁 drawable
                        📄 launch_background.xml
                    📁 drawable-v21
                        📄 launch_background.xml
                    📁 mipmap-hdpi
                        📄 ic_launcher.png
                    📁 mipmap-mdpi
                        📄 ic_launcher.png
                    📁 mipmap-xhdpi
                        📄 ic_launcher.png
                    📁 mipmap-xxhdpi
                        📄 ic_launcher.png
                    📁 mipmap-xxxhdpi
                        📄 ic_launcher.png
                    📁 values
                        📄 styles.xml
                    📁 values-night
                        📄 styles.xml
            📁 profile
                📄 AndroidManifest.xml
    📄 build.gradle
    📄 elecciones_android.iml
    📁 gradle
        📁 wrapper
            📄 gradle-wrapper.jar
            📄 gradle-wrapper.properties
    📄 gradle.properties
    📄 gradlew
    📄 gradlew.bat
    📄 local.properties
    📄 settings.gradle
📄 context.dart
📄 elecciones.iml
📁 ios
    📄 .gitignore
    📁 Flutter
        📄 AppFrameworkInfo.plist
        📄 Debug.xcconfig
        📄 Generated.xcconfig
        📄 Release.xcconfig
        📄 flutter_export_environment.sh
    📁 Runner
        📄 AppDelegate.swift
        📁 Assets.xcassets
            📁 AppIcon.appiconset
                📄 Contents.json
                📄 Icon-App-1024x1024@1x.png
                📄 Icon-App-20x20@1x.png
                📄 Icon-App-20x20@2x.png
                📄 Icon-App-20x20@3x.png
                📄 Icon-App-29x29@1x.png
                📄 Icon-App-29x29@2x.png
                📄 Icon-App-29x29@3x.png
                📄 Icon-App-40x40@1x.png
                📄 Icon-App-40x40@2x.png
                📄 Icon-App-40x40@3x.png
                📄 Icon-App-60x60@2x.png
                📄 Icon-App-60x60@3x.png
                📄 Icon-App-76x76@1x.png
                📄 Icon-App-76x76@2x.png
                📄 Icon-App-83.5x83.5@2x.png
            📁 LaunchImage.imageset
                📄 Contents.json
                📄 LaunchImage.png
                📄 LaunchImage@2x.png
                📄 LaunchImage@3x.png
                📄 README.md
        📁 Base.lproj
            📄 LaunchScreen.storyboard
            📄 Main.storyboard
        📄 GeneratedPluginRegistrant.h
        📄 GeneratedPluginRegistrant.m
        📄 Info.plist
        📄 Runner-Bridging-Header.h
    📁 Runner.xcodeproj
        📄 project.pbxproj
        📁 project.xcworkspace
            📄 contents.xcworkspacedata
            📁 xcshareddata
                📄 IDEWorkspaceChecks.plist
                📄 WorkspaceSettings.xcsettings
        📁 xcshareddata
            📁 xcschemes
                📄 Runner.xcscheme
    📁 Runner.xcworkspace
        📄 contents.xcworkspacedata
        📁 xcshareddata
            📄 IDEWorkspaceChecks.plist
            📄 WorkspaceSettings.xcsettings
    📁 RunnerTests
        📄 RunnerTests.swift
📁 lib
    📁 core
        📁 constants
            📄 supabase_constants.dart
        📁 errors
            📄 failure.dart
        📁 utils
            📄 cedula_validator.dart
    📁 features
        📁 auth
            📁 data
                📁 datasources
                    📄 supabase_client_provider.dart
                📁 models
                    📄 acta_model.dart
                    📄 candidato_model.dart
                    📄 mesa_jrv_model.dart
                    📄 organizacion_politica_model.dart
                    📄 recinto_model.dart
                    📄 usuario_model.dart
                    📄 voto_candidato_model.dart
                📁 repositories
                    📄 acta_repository_impl.dart
                    📄 acta_repository_provider.dart
                    📄 auth_repository_impl.dart
                    📄 auth_repository_provider.dart
            📁 domain
                📁 entities
                    📄 acta.dart
                    📄 candidato.dart
                    📄 mesa_jrv.dart
                    📄 organizacion_politica.dart
                    📄 recinto.dart
                    📄 usuario.dart
                    📄 voto_candidato.dart
                📁 repositories
                    📄 acta_repository.dart
                    📄 auth_repository.dart
                📁 usecases
                    📄 registrar_acta_usecase.dart
            📁 presentation
                📁 auth
                    📄 cambiar_password_screen.dart
                    📄 login_screen.dart
                    📄 olvide_password_screen.dart
                📁 controller
                    📄 login_controller.dart
                📁 coordinador_provincial
                    📄 coordinador_provincial_panel_screen.dart
                    📄 coordinador_provincial_providers.dart
                📁 coordinador_recinto
                    📄 coordinador_recinto_panel_screen.dart
                    📄 coordinador_recinto_providers.dart
                📁 shared
                📁 veedor
                    📄 acta_form_controller.dart
                    📄 acta_form_screen.dart
                    📄 veedor_panel_screen.dart
                    📄 veedor_providers.dart
            📁 providers
                📄 auth_providers.dart
    📄 main.dart
📄 pubspec.yaml
📁 test
    📄 widget_test.dart


# CONTENIDO DE LOS ARCHIVOS

          
================================================
📄 ARCHIVO: test/widget_test.dart
================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:elecciones/main.dart';

void main() {
  testWidgets('App muestra la pantalla de login', (WidgetTester tester) async {
    await tester.pumpWidget(const ControlElectoralApp());

    expect(find.text('Acceda a su portal de votación'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}


          
================================================
📄 ARCHIVO: .metadata
================================================

# This file tracks properties of this Flutter project.
# Used by Flutter tool to assess capabilities and perform upgrades etc.
#
# This file should be version controlled and should not be manually edited.

version:
  revision: "54e66469a933b60ddf175f858f82eaeb97e48c8d"
  channel: "[user-branch]"

project_type: app

# Tracks metadata for the flutter migrate command
migration:
  platforms:
    - platform: root
      create_revision: 54e66469a933b60ddf175f858f82eaeb97e48c8d
      base_revision: 54e66469a933b60ddf175f858f82eaeb97e48c8d
    - platform: android
      create_revision: 54e66469a933b60ddf175f858f82eaeb97e48c8d
      base_revision: 54e66469a933b60ddf175f858f82eaeb97e48c8d
    - platform: ios
      create_revision: 54e66469a933b60ddf175f858f82eaeb97e48c8d
      base_revision: 54e66469a933b60ddf175f858f82eaeb97e48c8d
    - platform: linux
      create_revision: 54e66469a933b60ddf175f858f82eaeb97e48c8d
      base_revision: 54e66469a933b60ddf175f858f82eaeb97e48c8d
    - platform: macos
      create_revision: 54e66469a933b60ddf175f858f82eaeb97e48c8d
      base_revision: 54e66469a933b60ddf175f858f82eaeb97e48c8d
    - platform: web
      create_revision: 54e66469a933b60ddf175f858f82eaeb97e48c8d
      base_revision: 54e66469a933b60ddf175f858f82eaeb97e48c8d
    - platform: windows
      create_revision: 54e66469a933b60ddf175f858f82eaeb97e48c8d
      base_revision: 54e66469a933b60ddf175f858f82eaeb97e48c8d

  # User provided section

  # List of Local paths (relative to this file) that should be
  # ignored by the migrate tool.
  #
  # Files that are not part of the templates will be ignored by default.
  unmanaged_files:
    - 'lib/main.dart'
    - 'ios/Runner.xcodeproj/project.pbxproj'


          
================================================
📄 ARCHIVO: ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md
================================================

# Launch Screen Assets

You can customize the launch screen with your own desired assets by replacing the image files in this directory.

You can also do it by opening your Flutter project's Xcode project with `open ios/Runner.xcworkspace`, selecting `Runner/Assets.xcassets` in the Project Navigator and dropping in the desired images.

          
================================================
📄 ARCHIVO: ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json
================================================

{
  "images" : [
    {
      "idiom" : "universal",
      "filename" : "LaunchImage.png",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "filename" : "LaunchImage@2x.png",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "filename" : "LaunchImage@3x.png",
      "scale" : "3x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}


          
================================================
📄 ARCHIVO: ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json
================================================

{
  "images" : [
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-App-20x20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "20x20",
      "idiom" : "iphone",
      "filename" : "Icon-App-20x20@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-App-29x29@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-App-29x29@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "iphone",
      "filename" : "Icon-App-29x29@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-App-40x40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "iphone",
      "filename" : "Icon-App-40x40@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-App-60x60@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "60x60",
      "idiom" : "iphone",
      "filename" : "Icon-App-60x60@3x.png",
      "scale" : "3x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "Icon-App-20x20@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "20x20",
      "idiom" : "ipad",
      "filename" : "Icon-App-20x20@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "Icon-App-29x29@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "29x29",
      "idiom" : "ipad",
      "filename" : "Icon-App-29x29@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "Icon-App-40x40@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "40x40",
      "idiom" : "ipad",
      "filename" : "Icon-App-40x40@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "Icon-App-76x76@1x.png",
      "scale" : "1x"
    },
    {
      "size" : "76x76",
      "idiom" : "ipad",
      "filename" : "Icon-App-76x76@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "83.5x83.5",
      "idiom" : "ipad",
      "filename" : "Icon-App-83.5x83.5@2x.png",
      "scale" : "2x"
    },
    {
      "size" : "1024x1024",
      "idiom" : "ios-marketing",
      "filename" : "Icon-App-1024x1024@1x.png",
      "scale" : "1x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}


          
================================================
📄 ARCHIVO: ios/Flutter/Debug.xcconfig
================================================

#include "Generated.xcconfig"


          
================================================
📄 ARCHIVO: ios/Flutter/Release.xcconfig
================================================

#include "Generated.xcconfig"


          
================================================
📄 ARCHIVO: ios/Flutter/Generated.xcconfig
================================================

// This is a generated file; do not edit or check into version control.
FLUTTER_ROOT=/Users/dam/development/flutter
FLUTTER_APPLICATION_PATH=/Users/dam/Downloads/elecciones
COCOAPODS_PARALLEL_CODE_SIGN=true
FLUTTER_TARGET=lib/main.dart
FLUTTER_BUILD_DIR=build
FLUTTER_BUILD_NAME=1.0.0
FLUTTER_BUILD_NUMBER=1
EXCLUDED_ARCHS[sdk=iphonesimulator*]=i386
EXCLUDED_ARCHS[sdk=iphoneos*]=armv7
DART_OBFUSCATION=false
TRACK_WIDGET_CREATION=true
TREE_SHAKE_ICONS=false
PACKAGE_CONFIG=.dart_tool/package_config.json


          
================================================
📄 ARCHIVO: ios/.gitignore
================================================

**/dgph
*.mode1v3
*.mode2v3
*.moved-aside
*.pbxuser
*.perspectivev3
**/*sync/
.sconsign.dblite
.tags*
**/.vagrant/
**/DerivedData/
Icon?
**/Pods/
**/.symlinks/
profile
xcuserdata
**/.generated/
Flutter/App.framework
Flutter/Flutter.framework
Flutter/Flutter.podspec
Flutter/Generated.xcconfig
Flutter/ephemeral/
Flutter/app.flx
Flutter/app.zip
Flutter/flutter_assets/
Flutter/flutter_export_environment.sh
ServiceDefinitions.json
Runner/GeneratedPluginRegistrant.*

# Exceptions to above rules.
!default.mode1v3
!default.mode2v3
!default.pbxuser
!default.perspectivev3


          
================================================
📄 ARCHIVO: context.dart
================================================

import 'dart:io';

// Nombre del archivo de salida
const outputFile = 'contexto_proyecto.md';

final rootDir = Directory.current.path;

// Carpetas a ignorar
const ignoreDirs = [
  '.dart_tool',
  '.idea',
  '.vscode',
  '.git',
  'build',
  '.flutter-plugins',
  '.flutter-plugins-dependencies',
  'android/.gradle',
  'ios/Pods',
  'ios/.symlinks',
  'linux',
  'macos',
  'windows',
  'web',
];

// Archivos a ignorar
const ignoreFiles = ['pubspec.lock', outputFile, 'export_context_flutter.dart'];

// Extensiones permitidas
const allowedExtensions = ['.dart', '.yaml', '.yml', '.json', '.md', '.arb'];

final architectureWarnings = <String>[];
final architectureSuccess = <String>[];

bool shouldIgnoreDirectory(Directory dir) {
  final path = dir.path.replaceAll('\\', '/');
  final name = path.split('/').last;

  return ignoreDirs.any((ignored) => path.endsWith(ignored)) ||
      (name.startsWith('.') && !ignoreDirs.contains(name));
}

bool shouldIgnoreFile(String fileName) {
  return ignoreFiles.contains(fileName);
}

/// ===========================================
/// GENERAR ÁRBOL DE CARPETAS
/// ===========================================
void generateTree(Directory dir, IOSink sink, {String prefix = ''}) {
  final items = dir.listSync()..sort((a, b) => a.path.compareTo(b.path));

  for (final item in items) {
    final name = item.path.split(Platform.pathSeparator).last;

    if (item is Directory) {
      if (shouldIgnoreDirectory(item)) continue;

      sink.writeln('$prefix📁 $name');
      generateTree(item, sink, prefix: '$prefix    ');
    } else if (item is File) {
      if (shouldIgnoreFile(name)) continue;

      sink.writeln('$prefix📄 $name');
    }
  }
}

/// ===========================================
/// ANALIZAR CLEAN ARCHITECTURE
/// ===========================================
void analyzeArchitecture() {
  final libDir = Directory('$rootDir/lib');

  if (!libDir.existsSync()) {
    architectureWarnings.add('No se encontró la carpeta lib/');
    return;
  }

  final featuresDir = Directory('${libDir.path}/features');

  if (!featuresDir.existsSync()) {
    architectureWarnings.add(
      'No existe lib/features (estructura Clean Architecture no detectada).',
    );
    return;
  }

  final features = featuresDir.listSync().whereType<Directory>();

  for (final feature in features) {
    final featureName = feature.path.split(Platform.pathSeparator).last;

    final data = Directory('${feature.path}/data').existsSync();

    final domain = Directory('${feature.path}/domain').existsSync();

    final presentation = Directory('${feature.path}/presentation').existsSync();

    if (data && domain && presentation) {
      architectureSuccess.add(
        'Feature "$featureName" contiene data/domain/presentation.',
      );
    } else {
      architectureWarnings.add(
        'Feature "$featureName" está incompleta '
        '(data:$data domain:$domain presentation:$presentation).',
      );
    }
  }

  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final file in dartFiles) {
    final path = file.path.replaceAll('\\', '/');

    if (path.contains('/domain/')) {
      try {
        final content = file.readAsStringSync();

        if (content.contains('package:flutter/material.dart')) {
          architectureWarnings.add(
            'Flutter UI encontrada dentro de DOMAIN:\n$path',
          );
        }

        if (content.contains('Widget') ||
            content.contains('StatelessWidget') ||
            content.contains('StatefulWidget')) {
          architectureWarnings.add(
            'Widget encontrado dentro de DOMAIN:\n$path',
          );
        }
      } catch (_) {}
    }
  }
}

/// ===========================================
/// EXPORTAR CONTENIDO DE ARCHIVOS
/// ===========================================
void buildContext(Directory currentDir, IOSink outputSink) {
  final items = currentDir.listSync();

  for (final item in items) {
    final name = item.path.split(Platform.pathSeparator).last;

    if (item is Directory) {
      if (shouldIgnoreDirectory(item)) continue;

      buildContext(item, outputSink);
    } else if (item is File) {
      final ext = name.contains('.') ? '.${name.split('.').last}' : '';

      final isAllowedExtension = allowedExtensions.contains(ext);

      final isConfigFile =
          name.startsWith('.') ||
          name.contains('config') ||
          name == 'pubspec.yaml';

      if (shouldIgnoreFile(name)) continue;

      if (isAllowedExtension || isConfigFile) {
        try {
          final content = item.readAsStringSync();

          final relativePath = item.path.replaceFirst(
            '$rootDir${Platform.pathSeparator}',
            '',
          );

          outputSink.write('''
          
================================================
📄 ARCHIVO: $relativePath
================================================

$content

''');
        } catch (e) {
          stderr.writeln('Error leyendo ${item.path}: $e');
        }
      }
    }
  }
}

/// ===========================================
/// MAIN
/// ===========================================
void main() async {
  final outputFileObj = File('$rootDir${Platform.pathSeparator}$outputFile');

  final sink = outputFileObj.openWrite();

  stdout.writeln('⏳ Analizando proyecto Flutter...');

  analyzeArchitecture();

  sink.writeln('# CONTEXTO COMPLETO DEL PROYECTO');
  sink.writeln('\nGenerado automáticamente por export_context_flutter.dart');

  sink.writeln('\n\n# ANÁLISIS DE ARQUITECTURA\n');

  if (architectureSuccess.isNotEmpty) {
    sink.writeln('## ACIERTOS\n');

    for (final item in architectureSuccess) {
      sink.writeln('✅ $item');
    }
  }

  if (architectureWarnings.isNotEmpty) {
    sink.writeln('\n## ADVERTENCIAS\n');

    for (final item in architectureWarnings) {
      sink.writeln('⚠️ $item');
    }
  }

  sink.writeln('\n\n# ESTRUCTURA DEL PROYECTO\n');

  generateTree(Directory(rootDir), sink);

  sink.writeln('\n\n# CONTENIDO DE LOS ARCHIVOS\n');

  buildContext(Directory(rootDir), sink);

  await sink.close();

  stdout.writeln('');
  stdout.writeln('✅ Contexto generado correctamente');
  stdout.writeln('📄 Archivo creado: $outputFile');
  stdout.writeln('📂 Ubicación: $rootDir');
}

          
================================================
📄 ARCHIVO: README.md
================================================

# elecciones

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


          
================================================
📄 ARCHIVO: pubspec.yaml
================================================

name: elecciones
description: "A new Flutter project."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: '>=3.3.4 <4.0.0'

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  flutter:
    sdk: flutter


  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.6
  fpdart: ^1.2.0
  flutter_riverpod: ^2.6.1
  geolocator: ^12.0.0
  camera: ^0.11.0+2
  image: ^4.8.0
  permission_handler: ^11.3.1
  connectivity_plus: ^6.1.5
  sqflite: ^2.3.3+1
  path_provider: ^2.1.4
  supabase_flutter: ^2.14.2

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^3.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/assets-and-images/#resolution-aware

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/assets-and-images/#from-packages

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/custom-fonts/#from-packages


          
================================================
📄 ARCHIVO: .gitignore
================================================

# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# The .vscode folder contains launch configuration and tasks you configure in
# VS Code which you may wish to be included in version control, so this line
# is commented out by default.
#.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.pub-cache/
.pub/
/build/

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release


          
================================================
📄 ARCHIVO: .env
================================================

SUPABASE_URL=https://xxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6...

          
================================================
📄 ARCHIVO: android/.gitignore
================================================

gradle-wrapper.jar
/.gradle
/captures/
/gradlew
/gradlew.bat
/local.properties
GeneratedPluginRegistrant.java

# Remember to never publicly share your keystore.
# See https://flutter.dev/docs/deployment/android#reference-the-keystore-from-the-app
key.properties
**/*.keystore
**/*.jks


          
================================================
📄 ARCHIVO: .flutter-plugins-dependencies
================================================

{"info":"This is a generated file; do not edit or check into version control.","plugins":{"ios":[{"name":"app_links","path":"/Users/dam/.pub-cache/hosted/pub.dev/app_links-6.4.0/","native_build":true,"dependencies":[]},{"name":"camera_avfoundation","path":"/Users/dam/.pub-cache/hosted/pub.dev/camera_avfoundation-0.9.17+5/","native_build":true,"dependencies":[]},{"name":"connectivity_plus","path":"/Users/dam/.pub-cache/hosted/pub.dev/connectivity_plus-6.1.5/","native_build":true,"dependencies":[]},{"name":"geolocator_apple","path":"/Users/dam/.pub-cache/hosted/pub.dev/geolocator_apple-2.3.9/","native_build":true,"dependencies":[]},{"name":"path_provider_foundation","path":"/Users/dam/.pub-cache/hosted/pub.dev/path_provider_foundation-2.4.1/","shared_darwin_source":true,"native_build":true,"dependencies":[]},{"name":"permission_handler_apple","path":"/Users/dam/.pub-cache/hosted/pub.dev/permission_handler_apple-9.4.10/","native_build":true,"dependencies":[]},{"name":"shared_preferences_foundation","path":"/Users/dam/.pub-cache/hosted/pub.dev/shared_preferences_foundation-2.5.3/","shared_darwin_source":true,"native_build":true,"dependencies":[]},{"name":"sqflite","path":"/Users/dam/.pub-cache/hosted/pub.dev/sqflite-2.3.3+1/","shared_darwin_source":true,"native_build":true,"dependencies":[]},{"name":"url_launcher_ios","path":"/Users/dam/.pub-cache/hosted/pub.dev/url_launcher_ios-6.3.2/","native_build":true,"dependencies":[]}],"android":[{"name":"app_links","path":"/Users/dam/.pub-cache/hosted/pub.dev/app_links-6.4.0/","native_build":true,"dependencies":[]},{"name":"camera_android_camerax","path":"/Users/dam/.pub-cache/hosted/pub.dev/camera_android_camerax-0.6.5+2/","native_build":true,"dependencies":[]},{"name":"connectivity_plus","path":"/Users/dam/.pub-cache/hosted/pub.dev/connectivity_plus-6.1.5/","native_build":true,"dependencies":[]},{"name":"flutter_plugin_android_lifecycle","path":"/Users/dam/.pub-cache/hosted/pub.dev/flutter_plugin_android_lifecycle-2.0.19/","native_build":true,"dependencies":[]},{"name":"geolocator_android","path":"/Users/dam/.pub-cache/hosted/pub.dev/geolocator_android-4.6.1/","native_build":true,"dependencies":[]},{"name":"path_provider_android","path":"/Users/dam/.pub-cache/hosted/pub.dev/path_provider_android-2.2.4/","native_build":true,"dependencies":[]},{"name":"permission_handler_android","path":"/Users/dam/.pub-cache/hosted/pub.dev/permission_handler_android-12.0.13/","native_build":true,"dependencies":[]},{"name":"shared_preferences_android","path":"/Users/dam/.pub-cache/hosted/pub.dev/shared_preferences_android-2.2.2/","native_build":true,"dependencies":[]},{"name":"sqflite","path":"/Users/dam/.pub-cache/hosted/pub.dev/sqflite-2.3.3+1/","native_build":true,"dependencies":[]},{"name":"url_launcher_android","path":"/Users/dam/.pub-cache/hosted/pub.dev/url_launcher_android-6.3.2/","native_build":true,"dependencies":[]}],"macos":[{"name":"app_links","path":"/Users/dam/.pub-cache/hosted/pub.dev/app_links-6.4.0/","native_build":true,"dependencies":[]},{"name":"connectivity_plus","path":"/Users/dam/.pub-cache/hosted/pub.dev/connectivity_plus-6.1.5/","native_build":true,"dependencies":[]},{"name":"geolocator_apple","path":"/Users/dam/.pub-cache/hosted/pub.dev/geolocator_apple-2.3.9/","native_build":true,"dependencies":[]},{"name":"path_provider_foundation","path":"/Users/dam/.pub-cache/hosted/pub.dev/path_provider_foundation-2.4.1/","shared_darwin_source":true,"native_build":true,"dependencies":[]},{"name":"shared_preferences_foundation","path":"/Users/dam/.pub-cache/hosted/pub.dev/shared_preferences_foundation-2.5.3/","shared_darwin_source":true,"native_build":true,"dependencies":[]},{"name":"sqflite","path":"/Users/dam/.pub-cache/hosted/pub.dev/sqflite-2.3.3+1/","shared_darwin_source":true,"native_build":true,"dependencies":[]},{"name":"url_launcher_macos","path":"/Users/dam/.pub-cache/hosted/pub.dev/url_launcher_macos-3.2.2/","native_build":true,"dependencies":[]}],"linux":[{"name":"app_links_linux","path":"/Users/dam/.pub-cache/hosted/pub.dev/app_links_linux-1.0.3/","native_build":false,"dependencies":["gtk"]},{"name":"connectivity_plus","path":"/Users/dam/.pub-cache/hosted/pub.dev/connectivity_plus-6.1.5/","native_build":false,"dependencies":[]},{"name":"gtk","path":"/Users/dam/.pub-cache/hosted/pub.dev/gtk-2.2.0/","native_build":true,"dependencies":[]},{"name":"path_provider_linux","path":"/Users/dam/.pub-cache/hosted/pub.dev/path_provider_linux-2.2.1/","native_build":false,"dependencies":[]},{"name":"shared_preferences_linux","path":"/Users/dam/.pub-cache/hosted/pub.dev/shared_preferences_linux-2.4.1/","native_build":false,"dependencies":["path_provider_linux"]},{"name":"url_launcher_linux","path":"/Users/dam/.pub-cache/hosted/pub.dev/url_launcher_linux-3.2.1/","native_build":true,"dependencies":[]}],"windows":[{"name":"app_links","path":"/Users/dam/.pub-cache/hosted/pub.dev/app_links-6.4.0/","native_build":true,"dependencies":[]},{"name":"connectivity_plus","path":"/Users/dam/.pub-cache/hosted/pub.dev/connectivity_plus-6.1.5/","native_build":true,"dependencies":[]},{"name":"geolocator_windows","path":"/Users/dam/.pub-cache/hosted/pub.dev/geolocator_windows-0.2.3/","native_build":true,"dependencies":[]},{"name":"path_provider_windows","path":"/Users/dam/.pub-cache/hosted/pub.dev/path_provider_windows-2.3.0/","native_build":false,"dependencies":[]},{"name":"permission_handler_windows","path":"/Users/dam/.pub-cache/hosted/pub.dev/permission_handler_windows-0.2.1/","native_build":true,"dependencies":[]},{"name":"shared_preferences_windows","path":"/Users/dam/.pub-cache/hosted/pub.dev/shared_preferences_windows-2.4.1/","native_build":false,"dependencies":["path_provider_windows"]},{"name":"url_launcher_windows","path":"/Users/dam/.pub-cache/hosted/pub.dev/url_launcher_windows-3.1.3/","native_build":true,"dependencies":[]}],"web":[{"name":"app_links_web","path":"/Users/dam/.pub-cache/hosted/pub.dev/app_links_web-1.0.4/","dependencies":[]},{"name":"camera_web","path":"/Users/dam/.pub-cache/hosted/pub.dev/camera_web-0.3.5/","dependencies":[]},{"name":"connectivity_plus","path":"/Users/dam/.pub-cache/hosted/pub.dev/connectivity_plus-6.1.5/","dependencies":[]},{"name":"geolocator_web","path":"/Users/dam/.pub-cache/hosted/pub.dev/geolocator_web-4.0.0/","dependencies":[]},{"name":"permission_handler_html","path":"/Users/dam/.pub-cache/hosted/pub.dev/permission_handler_html-0.1.3+5/","dependencies":[]},{"name":"shared_preferences_web","path":"/Users/dam/.pub-cache/hosted/pub.dev/shared_preferences_web-2.4.1/","dependencies":[]},{"name":"url_launcher_web","path":"/Users/dam/.pub-cache/hosted/pub.dev/url_launcher_web-2.3.3/","dependencies":[]}]},"dependencyGraph":[{"name":"app_links","dependencies":["app_links_linux","app_links_web"]},{"name":"app_links_linux","dependencies":["gtk"]},{"name":"app_links_web","dependencies":[]},{"name":"camera","dependencies":["camera_android_camerax","camera_avfoundation","camera_web","flutter_plugin_android_lifecycle"]},{"name":"camera_android_camerax","dependencies":[]},{"name":"camera_avfoundation","dependencies":[]},{"name":"camera_web","dependencies":[]},{"name":"connectivity_plus","dependencies":[]},{"name":"flutter_plugin_android_lifecycle","dependencies":[]},{"name":"geolocator","dependencies":["geolocator_android","geolocator_apple","geolocator_web","geolocator_windows"]},{"name":"geolocator_android","dependencies":[]},{"name":"geolocator_apple","dependencies":[]},{"name":"geolocator_web","dependencies":[]},{"name":"geolocator_windows","dependencies":[]},{"name":"gtk","dependencies":[]},{"name":"path_provider","dependencies":["path_provider_android","path_provider_foundation","path_provider_linux","path_provider_windows"]},{"name":"path_provider_android","dependencies":[]},{"name":"path_provider_foundation","dependencies":[]},{"name":"path_provider_linux","dependencies":[]},{"name":"path_provider_windows","dependencies":[]},{"name":"permission_handler","dependencies":["permission_handler_android","permission_handler_apple","permission_handler_html","permission_handler_windows"]},{"name":"permission_handler_android","dependencies":[]},{"name":"permission_handler_apple","dependencies":[]},{"name":"permission_handler_html","dependencies":[]},{"name":"permission_handler_windows","dependencies":[]},{"name":"shared_preferences","dependencies":["shared_preferences_android","shared_preferences_foundation","shared_preferences_linux","shared_preferences_web","shared_preferences_windows"]},{"name":"shared_preferences_android","dependencies":[]},{"name":"shared_preferences_foundation","dependencies":[]},{"name":"shared_preferences_linux","dependencies":["path_provider_linux"]},{"name":"shared_preferences_web","dependencies":[]},{"name":"shared_preferences_windows","dependencies":["path_provider_windows"]},{"name":"sqflite","dependencies":[]},{"name":"url_launcher","dependencies":["url_launcher_android","url_launcher_ios","url_launcher_linux","url_launcher_macos","url_launcher_web","url_launcher_windows"]},{"name":"url_launcher_android","dependencies":[]},{"name":"url_launcher_ios","dependencies":[]},{"name":"url_launcher_linux","dependencies":[]},{"name":"url_launcher_macos","dependencies":[]},{"name":"url_launcher_web","dependencies":[]},{"name":"url_launcher_windows","dependencies":[]}],"date_created":"2026-06-26 19:19:17.061450","version":"3.19.6"}

          
================================================
📄 ARCHIVO: lib/core/constants/supabase_constants.dart
================================================

class SupabaseConstants {
  static const String url = 'https://uybfmnfiqwrweddvvtfw.supabase.co';
  static const String anonKey = 'sb_publishable_nWW-Ans65TY9fcpGL9MTMw_9UcdBvHG';

  // Tablas
  static const String usuariosTable = 'usuarios';
  static const String recintosTable = 'recintos';
  static const String mesasJrvTable = 'mesas_jrv';
  static const String organizacionesPoliticasTable = 'organizaciones_politicas';
  static const String candidatosTable = 'candidatos';
  static const String actasTable = 'actas';
  static const String votosCandidatosTable = 'votos_candidatos';

  // Storage
  static const String actasBucket = 'actas_fotos';
}

          
================================================
📄 ARCHIVO: lib/core/utils/cedula_validator.dart
================================================

class CedulaValidator {
  /// Valida un número de cédula ecuatoriano.
  ///
  /// Requiere 10 dígitos y aplica la regla de verificación.
  static bool isValid(String cedula) {
    final sanitized = cedula.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(sanitized)) return false;

    final digits = sanitized.split('').map(int.parse).toList();
    final province = int.parse(sanitized.substring(0, 2));
    if (province < 1 || province > 24) return false;

    final lastDigit = digits[9];
    int sum = 0;
    for (var i = 0; i < 9; i++) {
      final value = digits[i] * (i % 2 == 0 ? 2 : 1);
      sum += value > 9 ? value - 9 : value;
    }

    final validator = (10 - (sum % 10)) % 10;
    return validator == lastDigit;
  }
}

          
================================================
📄 ARCHIVO: lib/core/errors/failure.dart
================================================

abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

          
================================================
📄 ARCHIVO: lib/features/auth/providers/auth_providers.dart
================================================

// lib/features/auth/providers/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/supabase_client_provider.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(supabase);
});

          
================================================
📄 ARCHIVO: lib/features/auth/data/datasources/supabase_client_provider.dart
================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client; // mismo cliente inicializado en main.dart
});

final supabaseAuthProvider =
    Provider<GoTrueClient>((ref) => ref.watch(supabaseClientProvider).auth);

final supabaseStorageProvider = Provider<SupabaseStorageClient>(
  (ref) => ref.watch(supabaseClientProvider).storage,
);

          
================================================
📄 ARCHIVO: lib/features/auth/data/repositories/acta_repository_impl.dart
================================================

// lib/features/auth/data/repositories/acta_repository_impl.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../domain/entities/acta.dart';
import '../../domain/repositories/acta_repository.dart';
import '../models/acta_model.dart';

class ActaRepositoryImpl implements ActaRepository {
  final SupabaseClient _supabase;

  ActaRepositoryImpl(this._supabase);

  @override
  Future<String> subirFotoActa(File foto) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${foto.path.split('/').last}';

    await _supabase.storage
        .from(SupabaseConstants.actasBucket)
        .upload(fileName, foto);

    // Devuelve la URL pública (o usa createSignedUrl si el bucket es privado)
    return _supabase.storage
        .from(SupabaseConstants.actasBucket)
        .getPublicUrl(fileName);
  }

  @override
  Future<void> guardarActa(Acta acta) async {
    final data = ActaModel.toMap(acta);

    if (acta.id == 0) {
      // Acta nueva: dejamos que Supabase genere el id (BIGSERIAL)
      await _supabase.from(SupabaseConstants.actasTable).insert(data);
    } else {
      await _supabase
          .from(SupabaseConstants.actasTable)
          .update(data)
          .eq('id', acta.id);
    }
  }

  @override
  Future<List<Acta>> obtenerActasPorMesa(int mesaId) async {
    final resultado = await _supabase
        .from(SupabaseConstants.actasTable)
        .select()
        .eq('mesa_id', mesaId);

    return (resultado as List)
        .map((row) => ActaModel.fromMap(row as Map<String, dynamic>))
        .toList();
  }
}

          
================================================
📄 ARCHIVO: lib/features/auth/data/repositories/auth_repository_provider.dart
================================================

// lib/features/auth/data/repositories/auth_repository_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/supabase_client_provider.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(supabase);
});

          
================================================
📄 ARCHIVO: lib/features/auth/data/repositories/auth_repository_impl.dart
================================================

// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/usuario_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  AuthRepositoryImpl(this._supabase);

  @override
  Future<Either<Failure, Usuario>> login(String cedula, String password) async {
  try {
    final email = '$cedula@controlelectoral.local';
    print('🔐 Intentando login con: $email'); // ← agrega esto

    final authResponse = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    print('✅ Auth response: ${authResponse.user?.id}'); // ← y esto

    if (authResponse.user == null) {
      return Left(ServerFailure('Error en la autenticación'));
    }

    print('📋 Buscando perfil...'); // ← y esto
    final resultado = await _supabase
        .from(SupabaseConstants.usuariosTable)
        .select()
        .eq('id', authResponse.user!.id)
        .maybeSingle();

    print('👤 Perfil encontrado: $resultado'); // ← y esto

    if (resultado == null) {
      await _supabase.auth.signOut();
      return Left(ServerFailure('Usuario no registrado'));
    }

    final usuario = UsuarioModel.fromMap(
      resultado,
      correo: authResponse.user!.email ?? '',
    );
    return Right(usuario);

  } on AuthException catch (e) {
    print('❌ AuthException: ${e.message}'); // ← y esto
    return Left(ServerFailure(e.message));
  } catch (e) {
    print('💥 Error inesperado: $e'); // ← y esto
    try { await _supabase.auth.signOut(); } catch (_) {}
    return Left(ServerFailure('Error inesperado: ${e.toString()}'));
  }
}
}

          
================================================
📄 ARCHIVO: lib/features/auth/data/repositories/acta_repository_provider.dart
================================================

// lib/features/auth/data/repositories/acta_repository_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/supabase_client_provider.dart';
import '../../domain/repositories/acta_repository.dart';
import '../../domain/usecases/registrar_acta_usecase.dart';
import 'acta_repository_impl.dart';

final actaRepositoryProvider = Provider<ActaRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ActaRepositoryImpl(supabase);
});

final registrarActaUseCaseProvider = Provider<RegistrarActaUseCase>((ref) {
  return RegistrarActaUseCase(ref.watch(actaRepositoryProvider));
});

          
================================================
📄 ARCHIVO: lib/features/auth/data/models/recinto_model.dart
================================================

// data/models/recinto_model.dart
import '../../domain/entities/recinto.dart';

class RecintoModel {
  static Map<String, dynamic> toMap(Recinto recinto) {
    return {
      'nombre': recinto.nombre,
      'provincia': recinto.provincia,
      'canton': recinto.canton,
      'parroquia': recinto.parroquia,
      'direccion': recinto.direccion,
    };
  }

  static Recinto fromMap(Map<String, dynamic> data) {
    return Recinto(
      id: data['id'] as int,
      nombre: data['nombre'] as String,
      provincia: data['provincia'] as String,
      canton: data['canton'] as String,
      parroquia: data['parroquia'] as String,
      direccion: data['direccion'] as String?,
    );
  }
}

          
================================================
📄 ARCHIVO: lib/features/auth/data/models/mesa_jrv_model.dart
================================================

// data/models/mesa_jrv_model.dart
import '../../domain/entities/mesa_jrv.dart';

class MesaJrvModel {
  static Map<String, dynamic> toMap(MesaJrv mesa) {
    return {
      'recinto_id': mesa.recintoId,
      'numero_mesa': mesa.numeroMesa,
      'genero': mesa.genero.dbValue,
    };
  }

  static MesaJrv fromMap(Map<String, dynamic> data) {
    return MesaJrv(
      id: data['id'] as int,
      recintoId: data['recinto_id'] as int,
      numeroMesa: data['numero_mesa'] as int,
      genero: GeneroMesaX.fromDb(data['genero'] as String),
    );
  }
}

          
================================================
📄 ARCHIVO: lib/features/auth/data/models/candidato_model.dart
================================================



          
================================================
📄 ARCHIVO: lib/features/auth/data/models/usuario_model.dart
================================================

// lib/features/auth/data/models/usuario_model.dart
import '../../domain/entities/usuario.dart';

class UsuarioModel {
  static Map<String, dynamic> toMap(Usuario usuario) {
    return {
      'id': usuario.id,
      'cedula': usuario.cedula,
      'nombre': usuario.nombres,
      'apellido': usuario.apellidos,
      'telefono': usuario.telefono,
      'rol': usuario.rol.dbValue,
      'debe_cambiar_password': usuario.debeCambiarPassword,
      'recinto_id': usuario.recintoId,
    };
  }

  static Usuario fromMap(Map<String, dynamic> data, {required String correo}) {
    return Usuario(
      id: data['id'] as String,
      cedula: data['cedula'] as String,
      nombres: data['nombre'] as String,
      apellidos: data['apellido'] as String,
      telefono: data['telefono'] as String? ?? '',
      correo: correo,
      rol: RolUsuarioX.fromDb(data['rol'] as String),
      debeCambiarPassword: data['debe_cambiar_password'] as bool? ?? false,
      recintoId: data['recinto_id'] as int?,
    );
  }
}

          
================================================
📄 ARCHIVO: lib/features/auth/data/models/organizacion_politica_model.dart
================================================

// data/models/organizacion_politica_model.dart
import '../../domain/entities/organizacion_politica.dart';

class OrganizacionPoliticaModel {
  static Map<String, dynamic> toMap(OrganizacionPolitica org) {
    return {
      'nombre': org.nombre,
      'lista_numero': org.listaNumero,
    };
  }

  static OrganizacionPolitica fromMap(Map<String, dynamic> data) {
    return OrganizacionPolitica(
      id: data['id'] as int,
      nombre: data['nombre'] as String,
      listaNumero: data['lista_numero'] as String,
    );
  }
}

          
================================================
📄 ARCHIVO: lib/features/auth/data/models/voto_candidato_model.dart
================================================

// data/models/voto_candidato_model.dart
import '../../domain/entities/voto_candidato.dart';

class VotoCandidatoModel {
  static Map<String, dynamic> toMap(VotoCandidato voto) {
    return {
      'acta_id': voto.actaId,
      'candidato_id': voto.candidatoId,
      'cantidad_votos': voto.cantidadVotos,
    };
  }

  static VotoCandidato fromMap(Map<String, dynamic> data) {
    return VotoCandidato(
      id: data['id'] as int,
      actaId: data['acta_id'] as int,
      candidatoId: data['candidato_id'] as int,
      cantidadVotos: data['cantidad_votos'] as int,
    );
  }
}

          
================================================
📄 ARCHIVO: lib/features/auth/data/models/acta_model.dart
================================================

// data/models/acta_model.dart
import '../../domain/entities/acta.dart';

class ActaModel {
  static Map<String, dynamic> toMap(Acta acta) {
    return {
      'mesa_id': acta.mesaId,
      'usuario_id': acta.usuarioId,
      'dignidad': acta.dignidad?.name,
      'votos_por_organizacion': acta.votosPorOrganizacion,
      'votos_blancos': acta.votosBlancos,
      'votos_nulos': acta.votosNulos,
      'total_sufragantes': acta.totalSufragantes,
      'url_foto_acta': acta.urlFotoActa,
      'gps_lat': acta.gpsLat,
      'gps_lng': acta.gpsLng,
      'estado': acta.estado.dbValue,
    };
  }

  static Acta fromMap(Map<String, dynamic> data) {
    return Acta(
      id: data['id'] as int,
      mesaId: data['mesa_id'] as int,
      usuarioId: data['usuario_id'] as String?,
      dignidad: data['dignidad'] != null
          ? Dignidad.values.byName(data['dignidad'] as String)
          : null,
      votosPorOrganizacion: data['votos_por_organizacion'] != null
          ? Map<String, int>.from(data['votos_por_organizacion'] as Map)
          : null,
      votosBlancos: data['votos_blancos'] as int,
      votosNulos: data['votos_nulos'] as int,
      totalSufragantes: data['total_sufragantes'] as int?,
      urlFotoActa: data['url_foto_acta'] as String?,
      gpsLat: (data['gps_lat'] as num?)?.toDouble(),
      gpsLng: (data['gps_lng'] as num?)?.toDouble(),
      estado: EstadoActaX.fromDb(data['estado'] as String),
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }
}

          
================================================
📄 ARCHIVO: lib/features/auth/domain/repositories/acta_repository.dart
================================================

// lib/features/auth/domain/repositories/acta_repository.dart
import 'dart:io';
import '../entities/acta.dart';

abstract class ActaRepository {
  /// Sube la foto del acta al storage y devuelve la URL pública del archivo.
  Future<String> subirFotoActa(File foto);

  /// Crea o actualiza el registro del acta.
  Future<void> guardarActa(Acta acta);

  /// Útil para detectar si una mesa ya tiene actas registradas
  /// (evita doble registro) y para la pantalla de revisión.
  Future<List<Acta>> obtenerActasPorMesa(int mesaId);
}

          
================================================
📄 ARCHIVO: lib/features/auth/domain/repositories/auth_repository.dart
================================================

import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/usuario.dart';

abstract class AuthRepository {
  Future<Either<Failure, Usuario>> login(String cedula, String password);
}

          
================================================
📄 ARCHIVO: lib/features/auth/domain/usecases/registrar_acta_usecase.dart
================================================

// lib/features/auth/domain/usecases/registrar_acta_usecase.dart
import 'dart:io';
import '../entities/acta.dart';
import '../repositories/acta_repository.dart';

class ActaInconsistenteException implements Exception {
  final String message;
  ActaInconsistenteException(this.message);
  @override
  String toString() => message;
}

class RegistrarActaUseCase {
  final ActaRepository repository;
  RegistrarActaUseCase(this.repository);

  /// [foto] es opcional aquí para poder testear el usecase sin
  /// depender de dart:io File en pantallas que no la tengan aún.
  Future<void> call({required Acta acta, File? foto}) async {
    if (!acta.esConsistente) {
      throw ActaInconsistenteException(
        'La suma de votos supera el total de sufragantes registrados.',
      );
    }

    String? urlFotoActa = acta.urlFotoActa;
    if (foto != null) {
      urlFotoActa = await repository.subirFotoActa(foto);
    }

    final actaFinal = acta.copyWith(urlFotoActa: urlFotoActa);
    await repository.guardarActa(actaFinal);
  }
}

          
================================================
📄 ARCHIVO: lib/features/auth/domain/entities/organizacion_politica.dart
================================================

// domain/entities/organizacion_politica.dart
class OrganizacionPolitica {
  final int id;
  final String nombre;
  final String listaNumero;

  OrganizacionPolitica({
    required this.id,
    required this.nombre,
    required this.listaNumero,
  });
}

          
================================================
📄 ARCHIVO: lib/features/auth/domain/entities/voto_candidato.dart
================================================

// domain/entities/voto_candidato.dart
class VotoCandidato {
  final int id;
  final int actaId;
  final int candidatoId;
  final int cantidadVotos;

  VotoCandidato({
    required this.id,
    required this.actaId,
    required this.candidatoId,
    required this.cantidadVotos,
  });
}

          
================================================
📄 ARCHIVO: lib/features/auth/domain/entities/mesa_jrv.dart
================================================

// domain/entities/mesa_jrv.dart
enum GeneroMesa { masculino, femenino, unica }

extension GeneroMesaX on GeneroMesa {
  String get dbValue {
    switch (this) {
      case GeneroMesa.masculino:
        return 'MASCULINO';
      case GeneroMesa.femenino:
        return 'FEMENINO';
      case GeneroMesa.unica:
        return 'UNICA';
    }
  }

  static GeneroMesa fromDb(String value) {
    switch (value) {
      case 'MASCULINO':
        return GeneroMesa.masculino;
      case 'FEMENINO':
        return GeneroMesa.femenino;
      case 'UNICA':
        return GeneroMesa.unica;
      default:
        throw ArgumentError('Género desconocido: $value');
    }
  }
}

class MesaJrv {
  final int id;
  final int recintoId;
  final int numeroMesa;
  final GeneroMesa genero;

  MesaJrv({
    required this.id,
    required this.recintoId,
    required this.numeroMesa,
    required this.genero,
  });
}

          
================================================
📄 ARCHIVO: lib/features/auth/domain/entities/acta.dart
================================================

// lib/features/auth/domain/entities/acta.dart
// ─── REEMPLAZA tu archivo actual con este ────────────────────────────────────

// CAMBIO: dignidades reales del proyecto (alcalde y prefecto)
enum Dignidad { alcalde, prefecto }

extension DignidadX on Dignidad {
  String get dbValue {
    switch (this) {
      case Dignidad.alcalde:
        return 'Alcalde';
      case Dignidad.prefecto:
        return 'Prefecto';
    }
  }

  String get etiqueta {
    switch (this) {
      case Dignidad.alcalde:
        return 'Alcalde';
      case Dignidad.prefecto:
        return 'Prefecto';
    }
  }

  static Dignidad fromDb(String value) {
    switch (value) {
      case 'Alcalde':
        return Dignidad.alcalde;
      case 'Prefecto':
        return Dignidad.prefecto;
      default:
        throw ArgumentError('Dignidad desconocida: $value');
    }
  }
}

enum EstadoActa { ingresada, revisada, conNovedad }

extension EstadoActaX on EstadoActa {
  String get dbValue {
    switch (this) {
      case EstadoActa.ingresada:
        return 'INGRESADA';
      case EstadoActa.revisada:
        return 'REVISADA';
      case EstadoActa.conNovedad:
        return 'CON NVEDAD'; // typo intencional para coincidir con el CHECK de la BD
    }
  }

  static EstadoActa fromDb(String value) {
    switch (value) {
      case 'INGRESADA':
        return EstadoActa.ingresada;
      case 'REVISADA':
        return EstadoActa.revisada;
      case 'CON NVEDAD':
        return EstadoActa.conNovedad;
      default:
        throw ArgumentError('Estado desconocido: $value');
    }
  }
}

class Acta {
  final int id;
  final int mesaId;
  final String? usuarioId;
  final Dignidad? dignidad;
  final Map<String, int>? votosPorOrganizacion;
  final int votosBlancos;
  final int votosNulos;
  final int? totalSufragantes;
  final String? urlFotoActa;
  final double? gpsLat;
  final double? gpsLng;
  final EstadoActa estado;
  final DateTime createdAt;

  const Acta({
    required this.id,
    required this.mesaId,
    this.usuarioId,
    this.dignidad,
    this.votosPorOrganizacion,
    required this.votosBlancos,
    required this.votosNulos,
    this.totalSufragantes,
    this.urlFotoActa,
    this.gpsLat,
    this.gpsLng,
    required this.estado,
    required this.createdAt,
  });

  bool get esConsistente {
    if (totalSufragantes == null) return true;
    final sumaOrganizaciones =
        votosPorOrganizacion?.values.fold<int>(0, (a, b) => a + b) ?? 0;
    return (sumaOrganizaciones + votosBlancos + votosNulos) <= totalSufragantes!;
  }

  Acta copyWith({
    int? id,
    int? mesaId,
    String? usuarioId,
    Dignidad? dignidad,
    Map<String, int>? votosPorOrganizacion,
    int? votosBlancos,
    int? votosNulos,
    int? totalSufragantes,
    String? urlFotoActa,
    double? gpsLat,
    double? gpsLng,
    EstadoActa? estado,
    DateTime? createdAt,
  }) {
    return Acta(
      id: id ?? this.id,
      mesaId: mesaId ?? this.mesaId,
      usuarioId: usuarioId ?? this.usuarioId,
      dignidad: dignidad ?? this.dignidad,
      votosPorOrganizacion: votosPorOrganizacion ?? this.votosPorOrganizacion,
      votosBlancos: votosBlancos ?? this.votosBlancos,
      votosNulos: votosNulos ?? this.votosNulos,
      totalSufragantes: totalSufragantes ?? this.totalSufragantes,
      urlFotoActa: urlFotoActa ?? this.urlFotoActa,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

          
================================================
📄 ARCHIVO: lib/features/auth/domain/entities/usuario.dart
================================================

// lib/features/auth/domain/entities/usuario.dart
class Usuario {
  final String id; // UUID de auth.users
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;
  final RolUsuario rol;
  final bool debeCambiarPassword;
  final int? recintoId;

  Usuario({
    required this.id,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
    required this.rol,
    required this.debeCambiarPassword,
    this.recintoId,
  });
}

enum RolUsuario { veedor, coordinadorRecinto, coordinadorProvincial }

extension RolUsuarioX on RolUsuario {
  String get dbValue {
    switch (this) {
      case RolUsuario.veedor:
        return 'veedor';
      case RolUsuario.coordinadorRecinto:
        return 'coordinador_recinto';
      case RolUsuario.coordinadorProvincial:
        return 'coordinador_provincial';
    }
  }

  static RolUsuario fromDb(String value) {
    switch (value) {
      case 'veedor':
        return RolUsuario.veedor;
      case 'coordinador_recinto':
        return RolUsuario.coordinadorRecinto;
      case 'coordinador_provincial':
        return RolUsuario.coordinadorProvincial;
      default:
        throw ArgumentError('Rol desconocido: $value');
    }
  }
}

          
================================================
📄 ARCHIVO: lib/features/auth/domain/entities/candidato.dart
================================================

// domain/entities/candidato.dart
class Candidato {
  final int id;
  final int organizacionId;
  final String nombre;
  final String dignidad;

  Candidato({
    required this.id,
    required this.organizacionId,
    required this.nombre,
    required this.dignidad,
  });
}

          
================================================
📄 ARCHIVO: lib/features/auth/domain/entities/recinto.dart
================================================

// domain/entities/recinto.dart
class Recinto {
  final int id;
  final String nombre;
  final String provincia;
  final String canton;
  final String parroquia;
  final String? direccion;

  Recinto({
    required this.id,
    required this.nombre,
    required this.provincia,
    required this.canton,
    required this.parroquia,
    this.direccion,
  });
}

          
================================================
📄 ARCHIVO: lib/features/auth/presentation/auth/cambiar_password_screen.dart
================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/supabase_client_provider.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../controller/login_controller.dart';

class CambiarPasswordScreen extends ConsumerStatefulWidget {
  const CambiarPasswordScreen({super.key});

  @override
  ConsumerState<CambiarPasswordScreen> createState() =>
      _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends ConsumerState<CambiarPasswordScreen> {
  final _nuevaCtrl = TextEditingController();
  final _actualCtrl = TextEditingController();
  bool _cargando = false;
  String? _error;

  Future<void> _guardar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      final usuario = ref.read(usuarioActualProvider)!;

      // 1. Re-autenticamos con la contraseña actual para validarla
      //    (Supabase no valida la "old password" dentro de updateUser)
      await supabase.auth.signInWithPassword(
        email: '${usuario.cedula}@controlelectoral.local',
        password: _actualCtrl.text,
      );

      // 2. Cambia la contraseña en Supabase Auth
      await supabase.auth.updateUser(
        UserAttributes(password: _nuevaCtrl.text),
      );

      // 3. Marca el registro como ya no pendiente
      await supabase
          .from(SupabaseConstants.usuariosTable)
          .update({'debe_cambiar_password': false})
          .eq('id', usuario.id);

      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cambia tu contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _actualCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña actual'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nuevaCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nueva contraseña'),
            ),
            const SizedBox(height: 24),
            if (_cargando)
              const CircularProgressIndicator()
            else
              ElevatedButton(onPressed: _guardar, child: const Text('Guardar')),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}

          
================================================
📄 ARCHIVO: lib/features/auth/presentation/auth/olvide_password_screen.dart
================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/supabase_client_provider.dart';

class OlvidePasswordScreen extends ConsumerStatefulWidget {
  const OlvidePasswordScreen({super.key});

  @override
  ConsumerState<OlvidePasswordScreen> createState() =>
      _OlvidePasswordScreenState();
}

class _OlvidePasswordScreenState extends ConsumerState<OlvidePasswordScreen> {
  final _correoCtrl = TextEditingController();
  bool _cargando = false;
  bool _enviado = false;
  String? _error;

  @override
  void dispose() {
    _correoCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarRecuperacion() async {
    final correo = _correoCtrl.text.trim();
    if (correo.isEmpty || !correo.contains('@')) {
      setState(() => _error = 'Ingresa un correo válido.');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.auth.resetPasswordForEmail(
        correo,
        redirectTo: 'https://controlelectoral.app/reset-password',
      );
      setState(() => _enviado = true);
    } on AuthException catch (e) {
      setState(() => _error = _mensajeError(e.message));
    } catch (e) {
      setState(() => _error = _mensajeError(e.toString()));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _mensajeError(String e) {
    final lower = e.toLowerCase();
    if (lower.contains('user_not_found') || lower.contains('invalid')) {
      return 'No existe una cuenta con ese correo.';
    }
    if (lower.contains('rate limit') || lower.contains('too many requests')) {
      return 'Demasiados intentos. Espera unos minutos.';
    }
    return 'No se pudo enviar el correo. Intenta de nuevo.';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC), // Fondo claro del mockup
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark, // Íconos de estado oscuros
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height - 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Contenedor tipo Tarjeta Blanca
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE4E7EC),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Encabezado institucional
                        Row(
                          children: const [
                            Icon(
                              Icons.verified_user_outlined,
                              color: Color(0xFF1D4ED8),
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Voter Portal',
                              style: TextStyle(
                                color: Color(0xFF1D4ED8),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Control de estados visuales
                        _enviado ? _buildSuccessState() : _buildFormState(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Footer institucional de la Comisión Electoral
                  Column(
                    children: [
                      const Text(
                        'Election Commission',
                        style: TextStyle(
                          color: Color(0xFF344054),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Privacy Policy', style: TextStyle(color: Color(0xFF475467), fontSize: 12)),
                          SizedBox(width: 12),
                          Text('Technical Support', style: TextStyle(color: Color(0xFF475467), fontSize: 12)),
                          SizedBox(width: 12),
                          Text('Terms of Service', style: TextStyle(color: Color(0xFF475467), fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '© 2024 Election Commission. All rights reserved.',
                        style: TextStyle(
                          color: Color(0xFF039855),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ícono central redondeado azul claro
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E7FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: Color(0xFF1D4ED8),
            size: 28,
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Recuperar\nContraseña',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF101828),
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Ingresa tu correo para recibir un enlace de recuperación',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF475467),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),

        // Etiquetas del campo
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Correo de Usuario',
              style: TextStyle(
                color: Color(0xFF344054),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'REQUERIDO',
              style: TextStyle(
                color: Color(0xFF1D4ED8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Input con el icono de la carta incorporado
        TextField(
          controller: _correoCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Color(0xFF101828), fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Escribe tu correo',
            hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
            prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF667085), size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 1.5),
            ),
          ),
        ),

        // Manejo de errores adaptado al diseño limpio
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFECDCA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFD92D20), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFB42318), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Botón Enviar Instrucciones
        SizedBox(
          width: double.infinity,
          height: 48,
          child: _cargando
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1D4ED8),
                    strokeWidth: 2.5,
                  ),
                )
              : ElevatedButton(
                  onPressed: _enviarRecuperacion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F43CD),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Enviar Instrucciones',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.send_rounded, color: Colors.white, size: 16),
                    ],
                  ),
                ),
        ),

        const SizedBox(height: 24),
        const Divider(color: Color(0xFFE4E7EC), thickness: 1),
        const SizedBox(height: 16),

        // Volver al inicio de sesión
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF1D4ED8)),
          label: const Text(
            'Volver al inicio de sesión',
            style: TextStyle(
              color: Color(0xFF1D4ED8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Banner informativo inferior azul grisáceo sutil
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.info_outline_rounded, color: Color(0xFF344054), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Por seguridad, si el correo de usuario es válido, recibirás un correo con las instrucciones de recuperación en la dirección registrada en el padrón electoral.',
                  style: TextStyle(
                    color: Color(0xFF344054),
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFD1FADF),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: Color(0xFF039855),
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '¡Correo enviado!',
          style: TextStyle(
            color: Color(0xFF101828),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Revisa tu bandeja de entrada y sigue el enlace enviado para restablecer las credenciales.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF475467),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Si no lo encuentras, no olvides revisar tu carpeta de spam.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF98A2B3),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD0D5DD)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Volver al login',
              style: TextStyle(
                color: Color(0xFF344054),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

          
================================================
📄 ARCHIVO: lib/features/auth/presentation/auth/login_screen.dart
================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/login_controller.dart';
import '../../domain/entities/usuario.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _cedulaCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // NUEVO: Variable para manejar el rol seleccionado (Simulado o adaptado a tu lógica si es necesario)
  String? _selectedRol;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _passwordCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    FocusScope.of(context).unfocus();

    final usuario = await ref
        .read(loginControllerProvider.notifier)
        .login(
          _cedulaCtrl.text.trim(),
          _passwordCtrl.text,
        );

    if (!mounted || usuario == null) return;

    if (usuario.debeCambiarPassword) {
      Navigator.of(context).pushReplacementNamed('/cambiar-password');
      return;
    }

    switch (usuario.rol) {
      case RolUsuario.coordinadorProvincial:
        Navigator.of(context).pushReplacementNamed('/provincial');
        break;

      case RolUsuario.coordinadorRecinto:
        Navigator.of(context).pushReplacementNamed('/coordinador-recinto');
        break;

      case RolUsuario.veedor:
        Navigator.of(context).pushReplacementNamed('/veedor');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Fondo ultra claro con textura de puntos sutil (Color base del mockup)
      backgroundColor: const Color(0xFFF8F9FC), 
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark, // Íconos de la barra de estado oscuros
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height - 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Card Principal Contenedor del Login
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE4E7EC),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Header con el Escudo/Check y Texto Voter Portal
                          Row(
                            children: [
                              const Icon(
                                Icons.verified_user_outlined,
                                color: Color(0xFF3422CD),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Voter Portal',
                                style: TextStyle(
                                  color: Color(0xFF3422CD),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Ícono central flotante del mockup
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E7FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.unarchive_outlined,
                              color: Color(0xFF3422CD),
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Título y Subtítulo
                          const Text(
                            'Acceda a su portal de votación',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF101828),
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Ingrese sus credenciales oficiales para continuar de forma segura.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF475467),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // --- FORMULARIO DE ENTRADA ---
                          
                          // 1. Dropdown de Selección de Rol
                          _buildLabel('Seleccionar Rol'),
                          const SizedBox(height: 6),
                          _buildDropdownField(),
                          const SizedBox(height: 20),

                          // 2. ID de Usuario (Cédula)
                          _buildLabel('ID del Usuario'),
                          const SizedBox(height: 6),
                          _buildTextField(
                            controller: _cedulaCtrl,
                            hint: '10 dígitos numéricos',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 3. Contraseña + Enlace "¿Olvidó su contraseña?" alineados
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLabel('Contraseña'),
                              GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .pushNamed('/olvide-password'),
                                child: const Text(
                                  '¿Olvidó su contraseña?',
                                  style: TextStyle(
                                    color: Color(0xFF3422CD),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _buildTextField(
                            controller: _passwordCtrl,
                            hint: '••••••••',
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF98A2B3),
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Manejo de Error de tu lógica original
                          if (state.hasError)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3F2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFECDCA)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Color(0xFFD92D20), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _mensajeError('${state.error}'),
                                      style: const TextStyle(
                                          color: Color(0xFFB42318),
                                          fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Botón Iniciar Sesión (Azul/Violeta Eléctrico de la captura)
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: state.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF3422CD),
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: _onLoginPressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2B1CB1),
                                      elevation: 2,
                                      shadowColor: const Color(0xFF3422CD).withOpacity(0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),

                          // Opción de registrarse/solicitar acceso adaptada al estilo claro
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '¿No tienes cuenta? ',
                                style: TextStyle(
                                  color: Color(0xFF667085),
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .pushNamed('/solicitar-acceso'),
                                child: const Text(
                                  'Solicitar acceso',
                                  style: TextStyle(
                                    color: Color(0xFF3422CD),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- BANNER DE INFORMACIÓN INFERIOR (Verde Menta del Mockup) ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FADF), // Fondo menta exacto
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF6EE7B7).withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info,
                            color: Color(0xFF065F46),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Este sistema utiliza encriptación de grado militar y autenticación de dos factores para proteger su integridad democrática.',
                              style: TextStyle(
                                color: Color(0xFF065F46),
                                fontSize: 12,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper para las etiquetas oscuras del diseño claro
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF344054),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Input fields limpios con bordes grises y focus violeta
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Color(0xFF101828), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
        prefixIcon: Icon(icon, color: const Color(0xFF667085), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3422CD), width: 1.5),
        ),
      ),
    );
  }

  // Selector de Rol Estilizado (Dropdown) según la captura
  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedRol,
      hint: Row(
        children: const [
          Icon(Icons.account_circle_outlined, color: Color(0xFF667085), size: 20),
          SizedBox(width: 10),
          Text('Seleccionar un rol', style: TextStyle(color: Color(0xFF98A2B3), fontSize: 14)),
        ],
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF667085)),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3422CD), width: 1.5),
        ),
      ),
      items: <String>['Coordinador Provincial', 'Coordinador Recinto', 'Veedor']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Color(0xFF101828), fontSize: 14)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedRol = newValue;
        });
      },
    );
  }

  String _mensajeError(String error) {
    if (error.contains('Cédula inválida')) return 'Cédula inválida. Verifica el número.';
    if (error.contains('Invalid credentials')) return 'Cédula o contraseña incorrectos.';
    if (error.contains('rate_limit')) return 'Demasiados intentos. Espera un momento.';
    if (error.contains('No se encontró un perfil')) return 'Usuario no registrado en el sistema.';
    return 'Error al ingresar. Intenta de nuevo.';
  }
}

          
================================================
📄 ARCHIVO: lib/features/auth/presentation/controller/login_controller.dart
================================================

// lib/features/auth/presentation/controller/login_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../data/datasources/supabase_client_provider.dart';
import '../../../../core/utils/cedula_validator.dart';
import '../../domain/entities/usuario.dart';

// 🔥 Proveedor global para conocer el usuario logueado en cualquier pantalla
final usuarioActualProvider = StateProvider<Usuario?>((ref) => null);

final loginControllerProvider =
    AsyncNotifierProvider<LoginController, Usuario?>(() => LoginController());

class LoginController extends AsyncNotifier<Usuario?> {
  @override
  Future<Usuario?> build() async {
    return null;
  }

  Future<Usuario?> login(String cedula, String password) async {
    // 1. Validación de cédula ecuatoriana antes de ir al servidor
    if (!CedulaValidator.isValid(cedula)) {
      state = AsyncError('La cédula ingresada no es válida', StackTrace.current);
      return null;
    }

    // 2. Cambiamos el estado a cargando para la UI
    state = const AsyncLoading();

    // 3. Capturamos el resultado del repositorio (ya migrado a Supabase)
    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.login(cedula, password);

      return result.fold(
        (failure) {
          state = AsyncError(failure.message, StackTrace.current);
          return null;
        },
        (usuario) {
          // Guardamos el usuario en el estado global
          ref.read(usuarioActualProvider.notifier).state = usuario;

          // Seteamos el estado final como exitoso
          state = AsyncData(usuario);
          return usuario;
        },
      );
    } catch (e) {
      state = AsyncError('Error de conexión: ${e.toString()}', StackTrace.current);
      return null;
    }
  }

  // 🚪 Método útil para cuando el usuario cierre sesión
  Future<void> logout() async {
    try {
      await ref.read(supabaseClientProvider).auth.signOut();
    } catch (_) {
      // si falla el signOut remoto, igual limpiamos el estado local
    }
    ref.read(usuarioActualProvider.notifier).state = null;
    state = const AsyncData(null);
  }
}

          
================================================
📄 ARCHIVO: lib/features/auth/presentation/veedor/acta_form_controller.dart
================================================

// lib/features/auth/presentation/veedor/acta_form_controller.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/acta.dart';
import '../../domain/entities/organizacion_politica.dart';
import '../../data/repositories/acta_repository_provider.dart';

// ─────────────────────────────────────────
// Estado del formulario
// ─────────────────────────────────────────
class ActaFormState {
  final int mesaId;
  final Dignidad dignidad;
  final int totalSufragantes;
  final List<OrganizacionPolitica> organizaciones;
  final Map<int, int> votosPorOrganizacion;
  final int votosNulos;
  final int votosBlancos;
  final File? fotoFile;
  final double? gpsLat;
  final double? gpsLng;
  final bool cargandoGps;
  final bool guardando;
  final String? error;
  final bool guardadoExito;
  final int? actaId; // null = nueva, int = edición

  const ActaFormState({
    required this.mesaId,
    required this.dignidad,
    required this.totalSufragantes,
    required this.organizaciones,
    required this.votosPorOrganizacion,
    this.votosNulos = 0,
    this.votosBlancos = 0,
    this.fotoFile,
    this.gpsLat,
    this.gpsLng,
    this.cargandoGps = false,
    this.guardando = false,
    this.error,
    this.guardadoExito = false,
    this.actaId,
  });

  int get totalContabilizado =>
      votosPorOrganizacion.values.fold(0, (a, b) => a + b) +
      votosNulos +
      votosBlancos;

  bool get esConsistente => totalContabilizado <= totalSufragantes;

  // En edición permitimos guardar aunque no haya nueva foto (conservamos la URL existente)
  bool get puedeGuardar =>
      gpsLat != null && gpsLng != null && esConsistente && !guardando;

  ActaFormState copyWith({
    Map<int, int>? votosPorOrganizacion,
    int? votosNulos,
    int? votosBlancos,
    File? fotoFile,
    double? gpsLat,
    double? gpsLng,
    bool? cargandoGps,
    bool? guardando,
    String? error,
    bool? guardadoExito,
    int? actaId,
  }) {
    return ActaFormState(
      mesaId: mesaId,
      dignidad: dignidad,
      totalSufragantes: totalSufragantes,
      organizaciones: organizaciones,
      votosPorOrganizacion: votosPorOrganizacion ?? this.votosPorOrganizacion,
      votosNulos: votosNulos ?? this.votosNulos,
      votosBlancos: votosBlancos ?? this.votosBlancos,
      fotoFile: fotoFile ?? this.fotoFile,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      cargandoGps: cargandoGps ?? this.cargandoGps,
      guardando: guardando ?? this.guardando,
      error: error,
      guardadoExito: guardadoExito ?? this.guardadoExito,
      actaId: actaId ?? this.actaId,
    );
  }
}

// ─────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────
class ActaFormNotifier extends StateNotifier<ActaFormState> {
  final Ref _ref;

  ActaFormNotifier(this._ref, ActaFormState initialState) : super(initialState) {
    _obtenerGpsAutomatico();
  }

  void actualizarVotosOrganizacion(int orgId, int votos) {
    final mapa = Map<int, int>.from(state.votosPorOrganizacion);
    mapa[orgId] = votos < 0 ? 0 : votos;
    state = state.copyWith(votosPorOrganizacion: mapa, error: null);
  }

  void actualizarVotosNulos(int valor) =>
      state = state.copyWith(votosNulos: valor < 0 ? 0 : valor, error: null);

  void actualizarVotosBlancos(int valor) =>
      state = state.copyWith(votosBlancos: valor < 0 ? 0 : valor, error: null);

  Future<void> _obtenerGpsAutomatico() => obtenerGps();

  Future<void> obtenerGps() async {
    state = state.copyWith(cargandoGps: true, error: null);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        state = state.copyWith(
          cargandoGps: false,
          error: 'El servicio GPS está desactivado en el dispositivo.',
        );
        return;
      }

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        state = state.copyWith(
          cargandoGps: false,
          error: 'Permiso de ubicación denegado. Actívalo en Configuración.',
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      state = state.copyWith(
        gpsLat: pos.latitude,
        gpsLng: pos.longitude,
        cargandoGps: false,
      );
    } catch (e) {
      state = state.copyWith(
        cargandoGps: false,
        error: 'Error al obtener GPS: $e',
      );
    }
  }

  Future<void> procesarFotoDesdeCamera(XFile xfile) async {
    try {
      final bytes = await xfile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        state = state.copyWith(error: 'No se pudo procesar la imagen.');
        return;
      }

      final resized =
          decoded.width > 1200 ? img.copyResize(decoded, width: 1200) : decoded;
      final compressed = img.encodeJpg(resized, quality: 85);

      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/acta_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath)..writeAsBytesSync(compressed);

      final isSharp = await compute(_evaluarNitidez, filePath);
      if (!isSharp) {
        await file.delete();
        state = state.copyWith(
          error:
              'La imagen está borrosa. Tome la foto nuevamente en un lugar bien iluminado.',
        );
        return;
      }

      state = state.copyWith(fotoFile: file, error: null);
    } catch (e) {
      state = state.copyWith(error: 'Error al procesar la foto: $e');
    }
  }

  static bool _evaluarNitidez(String path) {
    final file = File(path);
    if (!file.existsSync()) return false;
    final image = img.decodeImage(file.readAsBytesSync());
    if (image == null) return false;

    final grayscale = img.grayscale(image);
    final w = grayscale.width;
    final h = grayscale.height;
    double totalVariance = 0.0;
    int count = 0;

    for (int y = 5; y < h - 5; y += 4) {
      for (int x = 5; x < w - 5; x += 4) {
        final lC = img.getLuminance(grayscale.getPixel(x, y));
        final lR = img.getLuminance(grayscale.getPixel(x + 1, y));
        final lB = img.getLuminance(grayscale.getPixel(x, y + 1));
        final dx = (lC - lR).toDouble();
        final dy = (lC - lB).toDouble();
        totalVariance += dx * dx + dy * dy;
        count++;
      }
    }

    return (totalVariance / count) > 150.0;
  }

  Future<void> guardarActa({
    required String userId,
    String? urlFotoExistente, // URL de la foto ya registrada (modo edición)
  }) async {
    if (!state.puedeGuardar) {
      if (state.gpsLat == null) {
        state = state.copyWith(error: 'Debes obtener la ubicación GPS.');
      } else if (!state.esConsistente) {
        state = state.copyWith(
          error:
              'Los votos (${state.totalContabilizado}) superan el total de sufragantes (${state.totalSufragantes}).',
        );
      }
      return;
    }

    // Para acta NUEVA, la foto es obligatoria
    if (state.actaId == null && state.fotoFile == null) {
      state = state.copyWith(error: 'Debes tomar una foto del acta.');
      return;
    }

    state = state.copyWith(guardando: true, error: null);

    try {
      final repo = _ref.read(actaRepositoryProvider);

      // Subir nueva foto solo si se tomó una en esta sesión
      final String fotoUrl;
      if (state.fotoFile != null) {
        fotoUrl = await repo.subirFotoActa(state.fotoFile!);
      } else {
        fotoUrl = urlFotoExistente ?? '';
      }

      final acta = Acta(
        id: state.actaId ?? 0,
        mesaId: state.mesaId,
        usuarioId: userId,
        dignidad: state.dignidad,
        votosPorOrganizacion: state.votosPorOrganizacion
            .map((orgId, votos) => MapEntry(orgId.toString(), votos)),
        votosNulos: state.votosNulos,
        votosBlancos: state.votosBlancos,
        totalSufragantes: state.totalSufragantes,
        urlFotoActa: fotoUrl,
        gpsLat: state.gpsLat,
        gpsLng: state.gpsLng,
        estado: EstadoActa.ingresada,
        createdAt: DateTime.now(),
      );

      await repo.guardarActa(acta);

      state = state.copyWith(guardando: false, guardadoExito: true);
    } catch (e) {
      state = state.copyWith(
        guardando: false,
        error: 'Error al guardar el acta: $e',
      );
    }
  }
}

// ─────────────────────────────────────────
// Args del provider family
// ─────────────────────────────────────────
class ActaFormArgs {
  final int mesaId;
  final Dignidad dignidad;
  final int totalSufragantes;
  final List<OrganizacionPolitica> organizaciones;
  final Acta? actaExistente;

  const ActaFormArgs({
    required this.mesaId,
    required this.dignidad,
    required this.totalSufragantes,
    required this.organizaciones,
    this.actaExistente,
  });

  @override
  bool operator ==(Object other) =>
      other is ActaFormArgs &&
      other.mesaId == mesaId &&
      other.dignidad == dignidad;

  @override
  int get hashCode => Object.hash(mesaId, dignidad);
}

// ─────────────────────────────────────────
// Provider
// ─────────────────────────────────────────
final actaFormProvider = StateNotifierProvider.family<ActaFormNotifier,
    ActaFormState, ActaFormArgs>((ref, args) {
  // Precargar votos si hay acta existente
  final votosIniciales = <int, int>{};
  for (final org in args.organizaciones) {
    final valorExistente =
        args.actaExistente?.votosPorOrganizacion?[org.id.toString()] ?? 0;
    votosIniciales[org.id] = valorExistente;
  }

  return ActaFormNotifier(
    ref,
    ActaFormState(
      mesaId: args.mesaId,
      dignidad: args.dignidad,
      totalSufragantes: args.totalSufragantes,
      organizaciones: args.organizaciones,
      votosPorOrganizacion: votosIniciales,
      votosNulos: args.actaExistente?.votosNulos ?? 0,
      votosBlancos: args.actaExistente?.votosBlancos ?? 0,
      actaId: args.actaExistente?.id,
    ),
  );
});

          
================================================
📄 ARCHIVO: lib/features/auth/presentation/veedor/acta_form_screen.dart
================================================

// lib/features/auth/presentation/veedor/acta_form_screen.dart
// CAMBIO RESPECTO A LA VERSION ANTERIOR:
//  - Acepta `actaExistente` opcional para modo edición
//  - Precarga los valores del acta existente en los controllers
//  - El botón guarda O actualiza según corresponda
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../domain/entities/organizacion_politica.dart';
import 'acta_form_controller.dart';
import '../../domain/entities/acta.dart';

class ActaFormScreen extends ConsumerStatefulWidget {
  final int mesaId;
  final String mesaNombre;
  final String recintoNombre;
  final Dignidad dignidad;
  final int totalSufragantes;
  final List<OrganizacionPolitica> organizaciones;
  final String userId;
  final Acta? actaExistente; // null = nueva, not null = edición

  const ActaFormScreen({
    super.key,
    required this.mesaId,
    required this.mesaNombre,
    required this.recintoNombre,
    required this.dignidad,
    required this.totalSufragantes,
    required this.organizaciones,
    required this.userId,
    this.actaExistente,
  });

  @override
  ConsumerState<ActaFormScreen> createState() => _ActaFormScreenState();
}

class _ActaFormScreenState extends ConsumerState<ActaFormScreen> {
  late final Map<int, TextEditingController> _ctrlOrg;
  late final TextEditingController _ctrlNulos;
  late final TextEditingController _ctrlBlancos;
  late final ActaFormArgs _args;

  bool get _esEdicion => widget.actaExistente != null;

  @override
  void initState() {
    super.initState();
    _args = ActaFormArgs(
      mesaId: widget.mesaId,
      dignidad: widget.dignidad,
      totalSufragantes: widget.totalSufragantes,
      organizaciones: widget.organizaciones,
      actaExistente: widget.actaExistente,
    );

    // Precargar valores si es edición
    final votosExistentes =
        widget.actaExistente?.votosPorOrganizacion ?? {};

    _ctrlOrg = {
      for (final o in widget.organizaciones)
        o.id: TextEditingController(
          text: (votosExistentes[o.id.toString()] ?? 0).toString(),
        ),
    };
    _ctrlNulos = TextEditingController(
      text: (widget.actaExistente?.votosNulos ?? 0).toString(),
    );
    _ctrlBlancos = TextEditingController(
      text: (widget.actaExistente?.votosBlancos ?? 0).toString(),
    );
  }

  @override
  void dispose() {
    for (final c in _ctrlOrg.values) c.dispose();
    _ctrlNulos.dispose();
    _ctrlBlancos.dispose();
    super.dispose();
  }

  Future<void> _abrirCamara() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty || !mounted) return;

    final xfile = await Navigator.of(context).push<XFile>(
      MaterialPageRoute(
        builder: (_) => _CameraCapturePage(camera: cameras.first),
      ),
    );

    if (xfile != null) {
      await ref
          .read(actaFormProvider(_args).notifier)
          .procesarFotoDesdeCamera(xfile);
    }
  }

  Future<void> _guardar() async {
    final notifier = ref.read(actaFormProvider(_args).notifier);
    await notifier.guardarActa(userId: widget.userId);

    final state = ref.read(actaFormProvider(_args));
    if (state.guardadoExito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion
                ? 'Acta actualizada correctamente'
                : 'Acta registrada correctamente',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // retorna true para que el panel refresque
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(actaFormProvider(_args));

    ref.listen(actaFormProvider(_args), (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _esEdicion ? 'Editar acta' : 'Registrar acta',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              'Mesa ${widget.mesaNombre} — ${widget.dignidad.etiqueta}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (_esEdicion)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'Editando',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _CardInfoMesa(
              recinto: widget.recintoNombre,
              mesa: widget.mesaNombre,
              dignidad: widget.dignidad.etiqueta,
              totalSufragantes: widget.totalSufragantes,
            ),
            const SizedBox(height: 10),
            _CardVotos(
              organizaciones: widget.organizaciones,
              ctrlOrg: _ctrlOrg,
              ctrlNulos: _ctrlNulos,
              ctrlBlancos: _ctrlBlancos,
              state: state,
              onOrgChanged: (id, val) => ref
                  .read(actaFormProvider(_args).notifier)
                  .actualizarVotosOrganizacion(id, val),
              onNulosChanged: (val) => ref
                  .read(actaFormProvider(_args).notifier)
                  .actualizarVotosNulos(val),
              onBlancosChanged: (val) => ref
                  .read(actaFormProvider(_args).notifier)
                  .actualizarVotosBlancos(val),
            ),
            const SizedBox(height: 10),
            _CardFoto(
              fotoFile: state.fotoFile,
              urlFotoExistente: widget.actaExistente?.urlFotoActa,
              onTomarFoto: _abrirCamara,
            ),
            const SizedBox(height: 10),
            _CardGps(
              lat: state.gpsLat,
              lng: state.gpsLng,
              cargando: state.cargandoGps,
              onObtener: () =>
                  ref.read(actaFormProvider(_args).notifier).obtenerGps(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: state.guardando ? null : _guardar,
                icon: state.guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(_esEdicion
                        ? Icons.update_outlined
                        : Icons.save_outlined),
                label: Text(
                  state.guardando
                      ? 'Guardando...'
                      : (_esEdicion ? 'Actualizar acta' : 'Registrar acta'),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _esEdicion
                  ? 'Puedes corregir los datos o la foto en cualquier momento.'
                  : 'El acta quedará en estado "ingresada" hasta ser validada por el coordinador.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Sección: Info de la mesa (sin cambios)
// ─────────────────────────────────────────
class _CardInfoMesa extends StatelessWidget {
  final String recinto, mesa, dignidad;
  final int totalSufragantes;

  const _CardInfoMesa({
    required this.recinto,
    required this.mesa,
    required this.dignidad,
    required this.totalSufragantes,
  });

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: 'Información de la mesa',
      icono: Icons.place_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _Campo(label: 'Recinto', valor: recinto, disabled: true)),
              const SizedBox(width: 8),
              Expanded(child: _Campo(label: 'Mesa / JRV', valor: mesa, disabled: true)),
            ],
          ),
          const SizedBox(height: 8),
          _Campo(label: 'Dignidad', valor: dignidad, disabled: true),
          const SizedBox(height: 8),
          _Campo(
            label: 'Total sufragantes habilitados',
            valor: totalSufragantes.toString(),
            disabled: true,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Sección: Votos (sin cambios)
// ─────────────────────────────────────────
class _CardVotos extends StatelessWidget {
  final List<OrganizacionPolitica> organizaciones;
  final Map<int, TextEditingController> ctrlOrg;
  final TextEditingController ctrlNulos, ctrlBlancos;
  final ActaFormState state;
  final void Function(int, int) onOrgChanged;
  final void Function(int) onNulosChanged, onBlancosChanged;

  const _CardVotos({
    required this.organizaciones,
    required this.ctrlOrg,
    required this.ctrlNulos,
    required this.ctrlBlancos,
    required this.state,
    required this.onOrgChanged,
    required this.onNulosChanged,
    required this.onBlancosChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: 'Votos por organización política',
      icono: Icons.how_to_vote_outlined,
      child: Column(
        children: [
          ...organizaciones.map((org) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _FilaVotos(
                  label: '${org.listaNumero}. ${org.nombre}',
                  controller: ctrlOrg[org.id]!,
                  color: const Color(0xFFE8EAF6),
                  textColor: const Color(0xFF1A237E),
                  onChanged: (v) =>
                      onOrgChanged(org.id, int.tryParse(v) ?? 0),
                ),
              )),
          const Divider(height: 16),
          _FilaVotos(
            label: 'Votos nulos',
            controller: ctrlNulos,
            color: const Color(0xFFFFF3E0),
            textColor: const Color(0xFFE65100),
            onChanged: (v) => onNulosChanged(int.tryParse(v) ?? 0),
          ),
          const SizedBox(height: 8),
          _FilaVotos(
            label: 'Votos blancos',
            controller: ctrlBlancos,
            color: const Color(0xFFF3E5F5),
            textColor: const Color(0xFF6A1B9A),
            onChanged: (v) => onBlancosChanged(int.tryParse(v) ?? 0),
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total contabilizado',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text(
                '${state.totalContabilizado} / ${state.totalSufragantes}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: state.esConsistente
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Consistencia',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              _BadgeConsistencia(esConsistente: state.esConsistente),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilaVotos extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color color, textColor;
  final ValueChanged<String> onChanged;

  const _FilaVotos({
    required this.label,
    required this.controller,
    required this.color,
    required this.textColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide:
                    BorderSide(color: Colors.grey.shade300, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide:
                    BorderSide(color: Colors.grey.shade300, width: 0.5),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _BadgeConsistencia extends StatelessWidget {
  final bool esConsistente;
  const _BadgeConsistencia({required this.esConsistente});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: esConsistente ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        esConsistente ? '✓ Consistente' : '✗ Inconsistente',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: esConsistente
              ? Colors.green.shade700
              : Colors.red.shade700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Sección: Foto — NUEVO: muestra foto existente si hay URL
// ─────────────────────────────────────────
class _CardFoto extends StatelessWidget {
  final dynamic fotoFile;
  final String? urlFotoExistente;
  final VoidCallback onTomarFoto;

  const _CardFoto({
    required this.fotoFile,
    required this.urlFotoExistente,
    required this.onTomarFoto,
  });

  @override
  Widget build(BuildContext context) {
    final tieneNuevaFoto = fotoFile != null;
    final tieneFotoExistente =
        urlFotoExistente != null && urlFotoExistente!.isNotEmpty;

    return _Seccion(
      titulo: 'Fotografía del acta física',
      icono: Icons.camera_alt_outlined,
      child: Column(
        children: [
          // Muestra la nueva foto tomada en sesión
          if (tieneNuevaFoto) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                fotoFile,
                height: 200,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onTomarFoto,
              icon: const Icon(Icons.refresh),
              label: const Text('Retomar foto'),
            ),
          ]
          // Muestra la foto ya registrada en Supabase
          else if (tieneFotoExistente) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    urlFotoExistente!,
                    height: 200,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 80,
                      child: Center(
                        child: Icon(Icons.broken_image_outlined,
                            color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Foto actual',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onTomarFoto,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Reemplazar foto'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade700,
                side: BorderSide(color: Colors.orange.shade300),
              ),
            ),
          ]
          // Sin foto
          else ...[
            GestureDetector(
              onTap: onTomarFoto,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF9FA8DA),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFF3F4FD),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.add_a_photo_outlined,
                        size: 36, color: Color(0xFF5C6BC0)),
                    SizedBox(height: 8),
                    Text(
                      'Tomar foto del acta',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF5C6BC0),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Se usará la cámara trasera del dispositivo',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Sección: GPS (sin cambios)
// ─────────────────────────────────────────
class _CardGps extends StatelessWidget {
  final double? lat, lng;
  final bool cargando;
  final VoidCallback onObtener;

  const _CardGps({
    required this.lat,
    required this.lng,
    required this.cargando,
    required this.onObtener,
  });

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: 'Ubicación GPS',
      icono: Icons.gps_fixed,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Campo(
                  label: 'Latitud',
                  valor: lat != null ? lat!.toStringAsFixed(6) : '—',
                  disabled: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Campo(
                  label: 'Longitud',
                  valor: lng != null ? lng!.toStringAsFixed(6) : '—',
                  disabled: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF9FA8DA)),
                foregroundColor: const Color(0xFF1A237E),
              ),
              onPressed: cargando ? null : onObtener,
              icon: cargando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(
                cargando ? 'Obteniendo GPS...' : 'Actualizar ubicación',
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.info_outline, size: 13, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                'Se captura automáticamente al abrir el formulario',
                style:
                    TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Widgets auxiliares compartidos
// ─────────────────────────────────────────
class _Seccion extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Widget child;

  const _Seccion({required this.titulo, required this.icono, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFE8EAF6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(icono, size: 16, color: const Color(0xFF1A237E)),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final String label, valor;
  final bool disabled;

  const _Campo({
    required this.label,
    required this.valor,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 3),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: disabled ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
          ),
          child: Text(
            valor,
            style: TextStyle(
              fontSize: 13,
              color: disabled ? Colors.grey.shade600 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Página de cámara (sin cambios)
// ─────────────────────────────────────────
class _CameraCapturePage extends StatefulWidget {
  final CameraDescription camera;
  const _CameraCapturePage({required this.camera});

  @override
  State<_CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<_CameraCapturePage> {
  late CameraController _controller;
  late Future<void> _initFuture;
  bool _capturando = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _capturar() async {
    if (_capturando) return;
    setState(() => _capturando = true);
    try {
      final xfile = await _controller.takePicture();
      if (mounted) Navigator.of(context).pop(xfile);
    } catch (e) {
      setState(() => _capturando = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al capturar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Fotografía del acta'),
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              Center(child: CameraPreview(_controller)),
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _capturar,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        color: _capturando
                            ? Colors.grey
                            : Colors.white.withOpacity(0.85),
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 36, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

          
================================================
📄 ARCHIVO: lib/features/auth/presentation/veedor/veedor_panel_screen.dart
================================================

// lib/features/auth/presentation/veedor/veedor_panel_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/acta.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/mesa_jrv.dart';
import '../../domain/entities/organizacion_politica.dart';
import '../controller/login_controller.dart';
import 'veedor_providers.dart';
import 'acta_form_screen.dart';

class VeedorPanelScreen extends ConsumerWidget {
  const VeedorPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActualProvider);
    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final mesasAsync = ref.watch(mesasVeedorProvider(usuario.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Panel del Veedor',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              '${usuario.nombres} ${usuario.apellidos}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, size: 20),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await ref.read(loginControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
      body: mesasAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1A237E)),
        ),
        error: (e, _) => _ErrorView(
          mensaje: e.toString(),
          onRetry: () => ref.invalidate(mesasVeedorProvider(usuario.id)),
        ),
        data: (mesas) {
          if (mesas.isEmpty) {
            return const _SinMesasView();
          }
          return RefreshIndicator(
            color: const Color(0xFF1A237E),
            onRefresh: () async =>
                ref.invalidate(mesasVeedorProvider(usuario.id)),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _ResumenBanner(mesas: mesas, usuarioId: usuario.id),
                const SizedBox(height: 12),
                ...mesas.map(
                  (mesa) => _TarjetaMesa(
                    mesa: mesa,
                    usuario: usuario,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────
// Banner de resumen
// ─────────────────────────────────────────
class _ResumenBanner extends ConsumerWidget {
  final List<MesaJrv> mesas;
  final String usuarioId;

  const _ResumenBanner({required this.mesas, required this.usuarioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actasAsync = ref.watch(actasVeedorProvider(usuarioId));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: actasAsync.when(
        loading: () => const SizedBox(
          height: 48,
          child: Center(
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          ),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (actas) {
          final totalEsperadas = mesas.length * 2; // alcalde + prefecto
          final registradas = actas.length;
          final pendientes = totalEsperadas - registradas;

          return Row(
            children: [
              Expanded(
                child: _StatItem(
                  valor: '${mesas.length}',
                  etiqueta: 'Mesas asignadas',
                  icono: Icons.how_to_vote_outlined,
                ),
              ),
              _Divisor(),
              Expanded(
                child: _StatItem(
                  valor: '$registradas',
                  etiqueta: 'Actas registradas',
                  icono: Icons.check_circle_outline,
                ),
              ),
              _Divisor(),
              Expanded(
                child: _StatItem(
                  valor: '$pendientes',
                  etiqueta: 'Pendientes',
                  icono: Icons.pending_outlined,
                  destacar: pendientes > 0,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String valor;
  final String etiqueta;
  final IconData icono;
  final bool destacar;

  const _StatItem({
    required this.valor,
    required this.etiqueta,
    required this.icono,
    this.destacar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icono, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            color: destacar ? const Color(0xFFFFCC02) : Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          etiqueta,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}

class _Divisor extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 40,
        color: Colors.white24,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );
}

// ─────────────────────────────────────────
// Tarjeta por mesa
// ─────────────────────────────────────────
class _TarjetaMesa extends ConsumerWidget {
  final MesaJrv mesa;
  final Usuario usuario;

  const _TarjetaMesa({required this.mesa, required this.usuario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actasAsync = ref.watch(actasPorMesaProvider(mesa.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Encabezado de la mesa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFE8EAF6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_restaurant_outlined,
                    size: 16, color: Color(0xFF1A237E)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mesa ${mesa.numeroMesa} — ${mesa.genero}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filas de actas
          actasAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Error: $e',
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
            data: (actas) {
              final actaAlcalde = actas
                  .where((a) => a.dignidad == Dignidad.alcalde)
                  .firstOrNull;
              final actaPrefecto = actas
                  .where((a) => a.dignidad == Dignidad.prefecto)
                  .firstOrNull;

              return Column(
                children: [
                  _FilaActa(
                    dignidad: Dignidad.alcalde,
                    etiqueta: 'Acta de Alcalde',
                    icono: Icons.location_city_outlined,
                    acta: actaAlcalde,
                    onTap: () => _navegarAFormulario(
                      context,
                      ref,
                      Dignidad.alcalde,
                      actaAlcalde,
                    ),
                  ),
                  Divider(
                      height: 1, thickness: 0.5, color: Colors.grey.shade200),
                  _FilaActa(
                    dignidad: Dignidad.prefecto,
                    etiqueta: 'Acta de Prefecto',
                    icono: Icons.account_balance_outlined,
                    acta: actaPrefecto,
                    onTap: () => _navegarAFormulario(
                      context,
                      ref,
                      Dignidad.prefecto,
                      actaPrefecto,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _navegarAFormulario(
    BuildContext context,
    WidgetRef ref,
    Dignidad dignidad,
    Acta? actaExistente,
  ) async {
    // Cargar organizaciones políticas para esa dignidad
    final orgsAsync = ref.read(organizacionesPorDignidadProvider(dignidad));
    final List<OrganizacionPolitica> orgs = orgsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => [],
    );

    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActaFormScreen(
          mesaId: mesa.id,
          mesaNombre: mesa.numeroMesa.toString(),
          recintoNombre: 'Recinto ${mesa.recintoId}',
          dignidad: dignidad,
          totalSufragantes: 300, // TODO: cargar del recinto real
          organizaciones: orgs,
          userId: usuario.id,
          actaExistente: actaExistente,
        ),
      ),
    );

    // Refrescar actas de esta mesa al volver
    ref.invalidate(actasPorMesaProvider(mesa.id));
    ref.invalidate(actasVeedorProvider(usuario.id));
  }
}

// ─────────────────────────────────────────
// Fila de una acta (alcalde o prefecto)
// ─────────────────────────────────────────
class _FilaActa extends StatelessWidget {
  final Dignidad dignidad;
  final String etiqueta;
  final IconData icono;
  final Acta? acta;
  final VoidCallback onTap;

  const _FilaActa({
    required this.dignidad,
    required this.etiqueta,
    required this.icono,
    required this.acta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final registrada = acta != null;

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: registrada
                    ? Colors.green.shade50
                    : const Color(0xFFF3F4FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icono,
                size: 18,
                color: registrada
                    ? Colors.green.shade600
                    : const Color(0xFF5C6BC0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    etiqueta,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    registrada
                        ? 'Registrada — toca para editar'
                        : 'Pendiente — toca para registrar',
                    style: TextStyle(
                      fontSize: 11,
                      color: registrada
                          ? Colors.green.shade600
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            _BadgeEstado(acta: acta),
            const SizedBox(width: 8),
            Icon(
              registrada ? Icons.edit_outlined : Icons.add_circle_outline,
              size: 18,
              color: registrada
                  ? const Color(0xFF1A237E)
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeEstado extends StatelessWidget {
  final Acta? acta;
  const _BadgeEstado({required this.acta});

  @override
  Widget build(BuildContext context) {
    if (acta == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Text(
          'Pendiente',
          style: TextStyle(
              fontSize: 10,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w500),
        ),
      );
    }

    final (color, bg, borde, label) = switch (acta!.estado) {
      EstadoActa.ingresada => (
          Colors.blue.shade700,
          Colors.blue.shade50,
          Colors.blue.shade200,
          'Ingresada'
        ),
      EstadoActa.revisada => (
          Colors.green.shade700,
          Colors.green.shade50,
          Colors.green.shade200,
          'Revisada'
        ),
      EstadoActa.conNovedad => (
          Colors.red.shade700,
          Colors.red.shade50,
          Colors.red.shade200,
          'Con novedad'
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borde),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Views de estado vacío / error
// ─────────────────────────────────────────
class _SinMesasView extends StatelessWidget {
  const _SinMesasView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Sin mesas asignadas',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Contacta al coordinador de recinto para que te asigne una mesa.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String mensaje;
  final VoidCallback onRetry;

  const _ErrorView({required this.mensaje, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_outlined,
                size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error al cargar mesas',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E)),
            ),
          ],
        ),
      ),
    );
  }
}

          
================================================
📄 ARCHIVO: lib/features/auth/presentation/veedor/veedor_providers.dart
================================================

// lib/features/auth/presentation/veedor/veedor_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/supabase_client_provider.dart';
import '../../domain/entities/acta.dart';
import '../../domain/entities/mesa_jrv.dart';
import '../../domain/entities/organizacion_politica.dart';
import '../../data/models/mesa_jrv_model.dart';
import '../../data/models/acta_model.dart';
import '../../data/models/organizacion_politica_model.dart';

// ─────────────────────────────────────────
// Mesas asignadas al veedor
// ─────────────────────────────────────────
// Busca en la tabla veedor_mesas (relación veedor ↔ mesa)
// Si tienes otra tabla de asignación, ajusta el nombre aquí.
final mesasVeedorProvider =
    FutureProvider.family<List<MesaJrv>, String>((ref, usuarioId) async {
  final supabase = ref.watch(supabaseClientProvider);

  // Opción A: tabla intermedia veedor_mesas
  final resultado = await supabase
      .from('veedor_mesas')
      .select('mesa_id, mesas_jrv(*)')
      .eq('usuario_id', usuarioId);

  return (resultado as List)
      .map((row) =>
          MesaJrvModel.fromMap(row['mesas_jrv'] as Map<String, dynamic>))
      .toList();
});

// ─────────────────────────────────────────
// Actas registradas por el veedor (todas)
// ─────────────────────────────────────────
final actasVeedorProvider =
    FutureProvider.family<List<Acta>, String>((ref, usuarioId) async {
  final supabase = ref.watch(supabaseClientProvider);

  final resultado = await supabase
      .from('actas')
      .select()
      .eq('usuario_id', usuarioId)
      .order('created_at', ascending: false);

  return (resultado as List)
      .map((row) => ActaModel.fromMap(row as Map<String, dynamic>))
      .toList();
});

// ─────────────────────────────────────────
// Actas de una mesa específica
// ─────────────────────────────────────────
final actasPorMesaProvider =
    FutureProvider.family<List<Acta>, int>((ref, mesaId) async {
  final supabase = ref.watch(supabaseClientProvider);

  final resultado = await supabase.from('actas').select().eq('mesa_id', mesaId);

  return (resultado as List)
      .map((row) => ActaModel.fromMap(row as Map<String, dynamic>))
      .toList();
});

// ─────────────────────────────────────────
// Organizaciones políticas por dignidad
// ─────────────────────────────────────────
// Precarga las 5 organizaciones para alcalde o prefecto.
// Ajusta el filtro si en tu BD la dignidad está en candidatos o en otra tabla.
final organizacionesPorDignidadProvider =
    FutureProvider.family<List<OrganizacionPolitica>, Dignidad>(
        (ref, dignidad) async {
  final supabase = ref.watch(supabaseClientProvider);

  // Trae organizaciones que tienen candidatos para esa dignidad
  final resultado = await supabase
      .from('organizaciones_politicas')
      .select('''
        id,
        nombre,
        lista_numero,
        candidatos!inner(dignidad)
      ''')
      .eq('candidatos.dignidad', _dignidadToDb(dignidad))
      .order('lista_numero');

  return (resultado as List)
      .map((row) =>
          OrganizacionPoliticaModel.fromMap(row as Map<String, dynamic>))
      .toList();
});

String _dignidadToDb(Dignidad d) {
  switch (d) {
    case Dignidad.alcalde:
      return 'Alcalde';
    case Dignidad.prefecto:
      return 'Prefecto';
  }
}


          
================================================
📄 ARCHIVO: lib/features/auth/presentation/coordinador_provincial/coordinador_provincial_panel_screen.dart
================================================

// lib/features/auth/presentation/coordinador_provincial/coordinador_provincial_panel_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/acta.dart';
import '../../domain/entities/recinto.dart';
import '../controller/login_controller.dart';
import 'coordinador_provincial_providers.dart';

// ═════════════════════════════════════════════════════════════════════════════
// VALIDADOR DE CÉDULA ECUATORIANA
// ═════════════════════════════════════════════════════════════════════════════
class CedulaValidator {
  static bool isValid(String cedula) {
    final sanitized = cedula.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(sanitized)) return false;

    final digits = sanitized.split('').map(int.parse).toList();
    final province = int.parse(sanitized.substring(0, 2));
    if (province < 1 || province > 24) return false;

    final lastDigit = digits[9];
    int sum = 0;
    for (var i = 0; i < 9; i++) {
      final value = digits[i] * (i % 2 == 0 ? 2 : 1);
      sum += value > 9 ? value - 9 : value;
    }

    final validator = (10 - (sum % 10)) % 10;
    return validator == lastDigit;
  }

  static String? validate(String cedula) {
    final sanitized = cedula.trim();
    if (sanitized.isEmpty) return 'La cédula es obligatoria';
    if (sanitized.length != 10) {
      return 'Debe tener 10 dígitos (ingresaste ${sanitized.length})';
    }
    if (!isValid(sanitized)) return 'Cédula ecuatoriana no válida';
    return null;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PANTALLA PRINCIPAL
// ═════════════════════════════════════════════════════════════════════════════
class CoordinadorProvincialPanelScreen extends ConsumerStatefulWidget {
  const CoordinadorProvincialPanelScreen({super.key});

  @override
  ConsumerState<CoordinadorProvincialPanelScreen> createState() =>
      _CoordinadorProvincialPanelScreenState();
}

class _CoordinadorProvincialPanelScreenState
    extends ConsumerState<CoordinadorProvincialPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _dignidadFiltro = 'Todos';
  String? _recintoFiltro; // null = todos los recintos

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioActualProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Coordinador Provincial',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            if (usuario != null)
              Text('${usuario.nombres} ${usuario.apellidos}',
                  style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined, size: 20),
            tooltip: 'Nuevo recinto',
            onPressed: () => _dialogCrearRecinto(context),
          ),
          IconButton(
            icon: const Icon(Icons.person_add_outlined, size: 20),
            tooltip: 'Nuevo coordinador',
            onPressed: () => _dialogCrearCoordinador(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, size: 20),
            onPressed: () async {
              await ref.read(loginControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFF7C83F7),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.location_city_outlined, size: 18), text: 'Recintos'),
            Tab(icon: Icon(Icons.bar_chart_outlined, size: 18), text: 'Dashboard'),
            Tab(icon: Icon(Icons.people_outline, size: 18), text: 'Coordinadores'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _TabRecintos(onCrear: () => _dialogCrearRecinto(context)),
          _TabDashboard(
            filtroDigidad: _dignidadFiltro,
            filtroRecinto: _recintoFiltro,
            onFiltroDigidadChanged: (v) => setState(() => _dignidadFiltro = v),
            onFiltroRecintoChanged: (v) => setState(() => _recintoFiltro = v),
          ),
          const _TabCoordinadores(),
        ],
      ),
    );
  }

  // ── Diálogo crear recinto ──────────────────────────────────────────────────
  void _dialogCrearRecinto(BuildContext context) {
    final ctrlNombre = TextEditingController();
    final ctrlCanton = TextEditingController();
    final ctrlParroquia = TextEditingController();
    final ctrlDireccion = TextEditingController();
    final ctrlNumJRV = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo recinto electoral',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CampoForm(ctrl: ctrlNombre, label: 'Nombre del recinto'),
                const SizedBox(height: 10),
                _CampoForm(ctrl: ctrlCanton, label: 'Cantón'),
                const SizedBox(height: 10),
                _CampoForm(ctrl: ctrlParroquia, label: 'Parroquia'),
                const SizedBox(height: 10),
                _CampoForm(
                  ctrl: ctrlNumJRV,
                  label: 'Número de JRV / mesas',
                  digitsOnly: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Obligatorio';
                    final n = int.tryParse(v);
                    if (n == null || n < 1) return 'Debe ser mayor a 0';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _CampoForm(
                  ctrl: ctrlDireccion,
                  label: 'Dirección (opcional)',
                  required: false,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E)),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                await ref.read(crearRecintoProvider)(
                  ctrlCanton.text.trim(),
                  ctrlParroquia.text.trim(),
                  ctrlNombre.text.trim(),
                  ctrlDireccion.text.trim().isEmpty
                      ? null
                      : ctrlDireccion.text.trim(),
                  int.parse(ctrlNumJRV.text.trim()), // número de JRV
                );
                ref.invalidate(todosLosRecintosProvider);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Recinto creado correctamente'),
                    backgroundColor: Colors.green,
                  ));
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  // ── Diálogo crear coordinador de recinto ──────────────────────────────────
  void _dialogCrearCoordinador(BuildContext context) {
    final ctrlCedula = TextEditingController();
    final ctrlNombres = TextEditingController();
    final ctrlApellidos = TextEditingController();
    final ctrlTelefono = TextEditingController();
    final ctrlCorreo = TextEditingController();
    int? recintoIdSeleccionado;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final recintosAsync = ref.watch(todosLosRecintosProvider);
          return AlertDialog(
            title: const Text('Crear coordinador de recinto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Cédula con validación ecuatoriana ──
                    _CampoForm(
                      ctrl: ctrlCedula,
                      label: 'Cédula de identidad',
                      digitsOnly: true,
                      maxLength: 10,
                      validator: CedulaValidator.validate,
                    ),
                    const SizedBox(height: 10),
                    _CampoForm(
                      ctrl: ctrlNombres,
                      label: 'Nombres completos',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Los nombres son obligatorios'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _CampoForm(
                      ctrl: ctrlApellidos,
                      label: 'Apellidos completos',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Los apellidos son obligatorios'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _CampoForm(
                      ctrl: ctrlTelefono,
                      label: 'Teléfono de contacto',
                      digitsOnly: true,
                      maxLength: 10,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Obligatorio';
                        if (v.length < 9) return 'Teléfono inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // ── Correo electrónico ──
                    _CampoForm(
                      ctrl: ctrlCorreo,
                      label: 'Correo electrónico',
                      keyboard: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'El correo es obligatorio';
                        }
                        final emailRegex = RegExp(
                            r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
                        if (!emailRegex.hasMatch(v.trim())) {
                          return 'Correo electrónico inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // ── Selector de recinto ──
                    recintosAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => Text('Error: $e'),
                      data: (recintos) => DropdownButtonFormField<int>(
                        value: recintoIdSeleccionado,
                        hint: const Text('Asignar a recinto'),
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), isDense: true),
                        validator: (v) =>
                            v == null ? 'Selecciona un recinto' : null,
                        items: recintos
                            .map((r) => DropdownMenuItem(
                                  value: r.id,
                                  child: Text(r.nombre,
                                      style:
                                          const TextStyle(fontSize: 13)),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setS(() => recintoIdSeleccionado = v),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Aviso de correo de confirmación
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.mail_outline,
                              size: 16, color: Color(0xFF2E7D32)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Se enviará un correo de confirmación para activar la cuenta.',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF2E7D32)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar')),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E)),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  try {
                    await ref.read(crearCoordinadorRecintoProvider)(
                      ctrlCedula.text.trim(),
                      ctrlNombres.text.trim(),
                      ctrlApellidos.text.trim(),
                      ctrlTelefono.text.trim(),
                      ctrlCorreo.text.trim(),
                      recintoIdSeleccionado!,
                    );
                    ref.invalidate(coordinadoresRecintoProvider);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Coordinador creado · Se envió correo de confirmación'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ));
                    }
                  }
                },
                child: const Text('Crear y enviar correo'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 1 — RECINTOS
// ═════════════════════════════════════════════════════════════════════════════
class _TabRecintos extends ConsumerWidget {
  final VoidCallback onCrear;
  const _TabRecintos({required this.onCrear});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recintosAsync = ref.watch(todosLosRecintosProvider);

    return RefreshIndicator(
      color: const Color(0xFF1A237E),
      onRefresh: () async => ref.invalidate(todosLosRecintosProvider),
      child: recintosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: Colors.red))),
        data: (recintos) {
          if (recintos.isEmpty) {
            return _EmptyState(
              icono: Icons.location_city_outlined,
              mensaje: 'Sin recintos registrados',
              sub: 'Crea el primer recinto electoral.',
              boton: 'Crear recinto',
              onTap: onCrear,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: recintos.length,
            itemBuilder: (_, i) => _TarjetaRecinto(recinto: recintos[i]),
          );
        },
      ),
    );
  }
}

class _TarjetaRecinto extends ConsumerWidget {
  final Recinto recinto;
  const _TarjetaRecinto({required this.recinto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumenAsync = ref.watch(resumenPorRecintoProvider(recinto));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => _DetalleRecintoScreen(recinto: recinto),
        )),
        child: Column(
          children: [
            // Header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFE8EAF6),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_city_outlined,
                      size: 16, color: Color(0xFF1A237E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(recinto.nombre,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A237E))),
                  ),
                  const Icon(Icons.chevron_right,
                      size: 16, color: Color(0xFF1A237E)),
                ],
              ),
            ),
            // Sub-info
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.place_outlined,
                      size: 13, color: Color(0xFF9E9E9E)),
                  const SizedBox(width: 4),
                  Text('${recinto.canton} · ${recinto.parroquia}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF757575))),
                  const Spacer(),
                  resumenAsync.when(
                    loading: () => const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (_, __) => const SizedBox(),
                    data: (r) => _PillAvance(resumen: r),
                  ),
                ],
              ),
            ),
            // Barra de progreso
            resumenAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (r) => r.totalMesas == 0
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: r.porcentaje,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFE8EAF6),
                              color: r.porcentaje == 1
                                  ? Colors.green
                                  : const Color(0xFF3949AB),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${r.totalActas} / ${r.totalMesas * 2} actas · ${r.totalMesas} mesas',
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFF9E9E9E)),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillAvance extends StatelessWidget {
  final ResumenRecintoProv resumen;
  const _PillAvance({required this.resumen});

  @override
  Widget build(BuildContext context) {
    final color = resumen.pendientes == 0
        ? Colors.green.shade600
        : resumen.porcentaje > 0.5
            ? Colors.blue.shade600
            : Colors.orange.shade700;
    final bg = resumen.pendientes == 0
        ? Colors.green.shade50
        : resumen.porcentaje > 0.5
            ? Colors.blue.shade50
            : Colors.orange.shade50;
    final label = resumen.pendientes == 0
        ? 'Completo'
        : '${resumen.pendientes} pendientes';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

// ─── Detalle de un recinto ────────────────────────────────────────────────────
class _DetalleRecintoScreen extends ConsumerWidget {
  final Recinto recinto;
  const _DetalleRecintoScreen({required this.recinto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actasAsync = ref.watch(actasDeRecintoProvider(recinto.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: Text(recinto.nombre,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20),
            onPressed: () =>
                ref.invalidate(actasDeRecintoProvider(recinto.id)),
          ),
        ],
      ),
      body: actasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: Colors.red))),
        data: (actas) {
          if (actas.isEmpty) {
            return const Center(
              child: Text('Sin actas registradas en este recinto.',
                  style: TextStyle(color: Color(0xFF9E9E9E))),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: actas.length,
            itemBuilder: (_, i) => _TarjetaActaDetalle(acta: actas[i]),
          );
        },
      ),
    );
  }
}

class _TarjetaActaDetalle extends StatelessWidget {
  final Acta acta;
  const _TarjetaActaDetalle({required this.acta});

  @override
  Widget build(BuildContext context) {
    final tieneGps = acta.gpsLat != null && acta.gpsLng != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _BadgeEstado(acta: acta),
              const SizedBox(width: 8),
              Text(
                acta.dignidad == Dignidad.alcalde
                    ? 'Acta de Alcalde'
                    : 'Acta de Prefecto',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text('Mesa ${acta.mesaId}',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9E9E9E))),
            ],
          ),
          if (tieneGps) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 6),
                  Text(
                    'GPS: ${acta.gpsLat!.toStringAsFixed(6)}, ${acta.gpsLng!.toStringAsFixed(6)}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_off_outlined,
                      size: 14, color: Colors.orange.shade700),
                  const SizedBox(width: 6),
                  Text('Sin coordenadas GPS',
                      style: TextStyle(
                          fontSize: 11, color: Colors.orange.shade700)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text('Registrada: ${_formatFecha(acta.createdAt)}',
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9E9E9E))),
        ],
      ),
    );
  }

  String _formatFecha(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _BadgeEstado extends StatelessWidget {
  final Acta acta;
  const _BadgeEstado({required this.acta});

  @override
  Widget build(BuildContext context) {
    return switch (acta.estado) {
      EstadoActa.ingresada =>
        _pill('Ingresada', Colors.blue.shade700, Colors.blue.shade50),
      EstadoActa.revisada =>
        _pill('Revisada', Colors.green.shade700, Colors.green.shade50),
      EstadoActa.conNovedad =>
        _pill('Con novedad', Colors.red.shade700, Colors.red.shade50),
    };
  }

  Widget _pill(String label, Color color, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500)),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 2 — DASHBOARD DE VOTOS (con filtro por recinto)
// ═════════════════════════════════════════════════════════════════════════════
class _TabDashboard extends ConsumerWidget {
  final String filtroDigidad;
  final String? filtroRecinto;
  final ValueChanged<String> onFiltroDigidadChanged;
  final ValueChanged<String?> onFiltroRecintoChanged;

  const _TabDashboard({
    required this.filtroDigidad,
    required this.filtroRecinto,
    required this.onFiltroDigidadChanged,
    required this.onFiltroRecintoChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final votosAsync = ref.watch(dashboardVotosProvider);
    final recintosAsync = ref.watch(todosLosRecintosProvider);

    return RefreshIndicator(
      color: const Color(0xFF1A237E),
      onRefresh: () async => ref.invalidate(dashboardVotosProvider),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ── Filtro por recinto ──
          recintosAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (recintos) => _SelectorRecinto(
              recintos: recintos,
              seleccionado: filtroRecinto,
              onChanged: onFiltroRecintoChanged,
            ),
          ),
          const SizedBox(height: 10),

          // ── Filtro por dignidad ──
          _SelectorDignidad(
              valor: filtroDigidad, onChanged: onFiltroDigidadChanged),
          const SizedBox(height: 12),

          votosAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: Colors.red))),
            data: (votos) {
              // Filtrar por recinto si aplica
              var filtrados = filtroRecinto != null
                  ? votos
                      .where((v) => v.recintoNombre == filtroRecinto)
                      .toList()
                  : votos;

              // Filtrar por dignidad
              filtrados = filtroDigidad == 'Todos'
                  ? filtrados
                  : filtrados
                      .where((v) => v.dignidad == filtroDigidad)
                      .toList();

              if (filtrados.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text('Sin votos registrados aún.',
                        style: TextStyle(color: Color(0xFF9E9E9E))),
                  ),
                );
              }

              // Encabezado del resumen
              final totalVotos = filtrados.fold<int>(
                  0, (acc, v) => acc + v.totalVotos);
              final maxVotos =
                  filtrados.isEmpty ? 1 : filtrados.first.totalVotos;

              return Column(
                children: [
                  // Tarjeta resumen total
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.how_to_vote_outlined,
                            color: Colors.white70, size: 20),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              filtroRecinto ?? 'Todos los recintos',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.white70),
                            ),
                            Text(
                              '$totalVotos votos totales',
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ...filtrados.asMap().entries.map((e) => _BarraCandidato(
                        posicion: e.key + 1,
                        datos: e.value,
                        maxVotos: maxVotos,
                      )),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Selector de recinto para el dashboard ────────────────────────────────────
class _SelectorRecinto extends StatelessWidget {
  final List<Recinto> recintos;
  final String? seleccionado;
  final ValueChanged<String?> onChanged;

  const _SelectorRecinto({
    required this.recintos,
    required this.seleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: seleccionado,
          isExpanded: true,
          hint: const Text('Todos los recintos',
              style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
          icon: const Icon(Icons.filter_list_outlined,
              size: 18, color: Color(0xFF1A237E)),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Todos los recintos',
                  style: TextStyle(fontSize: 13)),
            ),
            ...recintos.map((r) => DropdownMenuItem<String?>(
                  value: r.nombre,
                  child:
                      Text(r.nombre, style: const TextStyle(fontSize: 13)),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SelectorDignidad extends StatelessWidget {
  final String valor;
  final ValueChanged<String> onChanged;
  const _SelectorDignidad(
      {required this.valor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: ['Todos', 'Alcalde', 'Prefecto'].map((d) {
          final sel = valor == d;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: sel
                      ? const Color(0xFF1A237E)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        sel ? Colors.white : const Color(0xFF757575),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BarraCandidato extends StatelessWidget {
  final int posicion;
  final VotosCandidato datos;
  final int maxVotos;

  const _BarraCandidato({
    required this.posicion,
    required this.datos,
    required this.maxVotos,
  });

  @override
  Widget build(BuildContext context) {
    final porcentaje =
        maxVotos == 0 ? 0.0 : datos.totalVotos / maxVotos;
    final esPrimero = posicion == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esPrimero
              ? const Color(0xFF3949AB).withOpacity(0.4)
              : const Color(0xFFE0E0E0),
          width: esPrimero ? 1.5 : 0.5,
        ),
        boxShadow: esPrimero
            ? [
                BoxShadow(
                    color: const Color(0xFF1A237E).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3)),
              ]
            : [],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _NumeroPosicion(pos: posicion),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(datos.nombre,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121))),
                    Text(
                      '${datos.organizacion} · ${datos.dignidad}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9E9E9E)),
                    ),
                  ],
                ),
              ),
              Text(
                '${datos.totalVotos}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: esPrimero
                      ? const Color(0xFF1A237E)
                      : const Color(0xFF424242),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: porcentaje,
              minHeight: 6,
              backgroundColor: const Color(0xFFE8EAF6),
              color: esPrimero
                  ? const Color(0xFF3949AB)
                  : const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumeroPosicion extends StatelessWidget {
  final int pos;
  const _NumeroPosicion({required this.pos});

  @override
  Widget build(BuildContext context) {
    final colors = {
      1: [const Color(0xFFFFD700), const Color(0xFF8B6914)],
      2: [const Color(0xFFE8E8E8), const Color(0xFF616161)],
      3: [const Color(0xFFCD7F32), const Color(0xFF5D4037)],
    };
    final c = colors[pos] ??
        [const Color(0xFFF5F5F5), const Color(0xFF9E9E9E)];
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: c[0], shape: BoxShape.circle),
      child: Center(
        child: Text('$pos',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c[1])),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 3 — COORDINADORES DE RECINTO
// ═════════════════════════════════════════════════════════════════════════════
class _TabCoordinadores extends ConsumerWidget {
  const _TabCoordinadores();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordsAsync = ref.watch(coordinadoresRecintoProvider);

    return RefreshIndicator(
      color: const Color(0xFF1A237E),
      onRefresh: () async => ref.invalidate(coordinadoresRecintoProvider),
      child: coordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: Colors.red))),
        data: (coords) {
          if (coords.isEmpty) {
            return const _EmptyState(
              icono: Icons.people_outline,
              mensaje: 'Sin coordinadores registrados',
              sub: 'Crea coordinadores desde el botón superior.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: coords.length,
            itemBuilder: (_, i) {
              final c = coords[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFE0E0E0), width: 0.5),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFE8EAF6),
                      child: Text(
                        c.nombres.isNotEmpty
                            ? c.nombres[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: Color(0xFF1A237E),
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${c.nombres} ${c.apellidos}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          Text(c.cedula,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9E9E9E))),
                          if (c.correo != null)
                            Text(c.correo!,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9E9E9E))),
                        ],
                      ),
                    ),
                    if (c.recintoId != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EAF6),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text('Recinto ${c.recintoId}',
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF1A237E),
                                fontWeight: FontWeight.w500)),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Widgets auxiliares
// ═════════════════════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final IconData icono;
  final String mensaje;
  final String sub;
  final String? boton;
  final VoidCallback? onTap;

  const _EmptyState({
    required this.icono,
    required this.mensaje,
    required this.sub,
    this.boton,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(mensaje,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text(sub,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade500)),
            if (boton != null && onTap != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.add),
                label: Text(boton!),
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Campo de formulario con validación integrada ──────────────────────────────
class _CampoForm extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool digitsOnly;
  final int? maxLength;
  final bool required;
  final String? Function(String?)? validator;
  final TextInputType? keyboard;

  const _CampoForm({
    required this.ctrl,
    required this.label,
    this.digitsOnly = false,
    this.maxLength,
    this.required = true,
    this.validator,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard ??
          (digitsOnly ? TextInputType.number : TextInputType.text),
      inputFormatters: [
        if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: validator ??
          (required
              ? (v) => (v == null || v.trim().isEmpty)
                  ? '$label es obligatorio'
                  : null
              : null),
    );
  }
}

          
================================================
📄 ARCHIVO: lib/features/auth/presentation/coordinador_provincial/coordinador_provincial_providers.dart
================================================

// lib/features/auth/presentation/coordinador_provincial/coordinador_provincial_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../data/datasources/supabase_client_provider.dart';
import '../../data/models/mesa_jrv_model.dart';
import '../../data/models/recinto_model.dart';
import '../../data/models/usuario_model.dart';
import '../../data/models/acta_model.dart';
import '../../domain/entities/mesa_jrv.dart';
import '../../domain/entities/recinto.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/acta.dart';

// ─── Todos los recintos ───────────────────────────────────────────────────────
final todosLosRecintosProvider = FutureProvider<List<Recinto>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final res = await supabase
      .from(SupabaseConstants.recintosTable)
      .select()
      .order('nombre');
  return (res as List)
      .map((r) => RecintoModel.fromMap(r as Map<String, dynamic>))
      .toList();
});

// ─── Resumen de avance por recinto ───────────────────────────────────────────
class ResumenRecintoProv {
  final Recinto recinto;
  final int totalMesas;
  final int actasAlcalde;
  final int actasPrefecto;

  const ResumenRecintoProv({
    required this.recinto,
    required this.totalMesas,
    required this.actasAlcalde,
    required this.actasPrefecto,
  });

  int get totalActas => actasAlcalde + actasPrefecto;
  int get pendientes => (totalMesas * 2) - totalActas;
  double get porcentaje =>
      totalMesas == 0 ? 0 : totalActas / (totalMesas * 2);
}

final resumenPorRecintoProvider =
    FutureProvider.family<ResumenRecintoProv, Recinto>((ref, recinto) async {
  final supabase = ref.watch(supabaseClientProvider);

  // Mesas del recinto
  final mesasRes = await supabase
      .from(SupabaseConstants.mesasJrvTable)
      .select('id')
      .eq('recinto_id', recinto.id);
  final mesaIds = (mesasRes as List).map((r) => r['id'] as int).toList();

  if (mesaIds.isEmpty) {
    return ResumenRecintoProv(
      recinto: recinto,
      totalMesas: 0,
      actasAlcalde: 0,
      actasPrefecto: 0,
    );
  }

  final actasRes = await supabase
      .from(SupabaseConstants.actasTable)
      .select('dignidad')
      .inFilter('mesa_id', mesaIds);

  int alcalde = 0, prefecto = 0;
  for (final row in actasRes as List) {
    final d = row['dignidad'] as String?;
    if (d == 'Alcalde') alcalde++;
    if (d == 'Prefecto') prefecto++;
  }

  return ResumenRecintoProv(
    recinto: recinto,
    totalMesas: mesaIds.length,
    actasAlcalde: alcalde,
    actasPrefecto: prefecto,
  );
});

// ─── Detalle de actas de un recinto (con GPS) ────────────────────────────────
final actasDeRecintoProvider =
    FutureProvider.family<List<Acta>, int>((ref, recintoId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final mesasRes = await supabase
      .from(SupabaseConstants.mesasJrvTable)
      .select('id')
      .eq('recinto_id', recintoId);
  final mesaIds =
      (mesasRes as List).map((r) => r['id'] as int).toList();
  if (mesaIds.isEmpty) return [];

  final res = await supabase
      .from(SupabaseConstants.actasTable)
      .select()
      .inFilter('mesa_id', mesaIds)
      .order('created_at', ascending: false);
  return (res as List)
      .map((r) => ActaModel.fromMap(r as Map<String, dynamic>))
      .toList();
});

// ─── Dashboard: votos consolidados por candidato ─────────────────────────────
class VotosCandidato {
  final int candidatoId;
  final String nombre;
  final String dignidad;
  final String organizacion;
  final int totalVotos;

  const VotosCandidato({
    required this.candidatoId,
    required this.nombre,
    required this.dignidad,
    required this.organizacion,
    required this.totalVotos,
  });
}

final dashboardVotosProvider =
    FutureProvider<List<VotosCandidato>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  // Join votos_candidatos → candidatos → organizaciones_politicas
  final res = await supabase.from('votos_candidatos').select('''
    candidato_id,
    cantidad_votos,
    candidatos!inner(
      nombre,
      dignidad,
      organizaciones_politicas!inner(nombre)
    )
  ''');

  // Agrupar por candidato_id sumando votos
  final Map<int, VotosCandidato> mapa = {};
  for (final row in res as List) {
    final cid = row['candidato_id'] as int;
    final votos = row['cantidad_votos'] as int;
    final cand = row['candidatos'] as Map<String, dynamic>;
    final org = cand['organizaciones_politicas'] as Map<String, dynamic>;

    if (mapa.containsKey(cid)) {
      mapa[cid] = VotosCandidato(
        candidatoId: cid,
        nombre: mapa[cid]!.nombre,
        dignidad: mapa[cid]!.dignidad,
        organizacion: mapa[cid]!.organizacion,
        totalVotos: mapa[cid]!.totalVotos + votos,
      );
    } else {
      mapa[cid] = VotosCandidato(
        candidatoId: cid,
        nombre: cand['nombre'] as String,
        dignidad: cand['dignidad'] as String,
        organizacion: org['nombre'] as String,
        totalVotos: votos,
      );
    }
  }

  final lista = mapa.values.toList()
    ..sort((a, b) => b.totalVotos.compareTo(a.totalVotos));
  return lista;
});

// ─── Mesas de un recinto (para detalles) ────────────────────────────────────
final mesasDeRecintoProvProv =
    FutureProvider.family<List<MesaJrv>, int>((ref, recintoId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final res = await supabase
      .from(SupabaseConstants.mesasJrvTable)
      .select()
      .eq('recinto_id', recintoId)
      .order('numero_mesa');
  return (res as List)
      .map((r) => MesaJrvModel.fromMap(r as Map<String, dynamic>))
      .toList();
});

// ─── Crear recinto ────────────────────────────────────────────────────────────
final crearRecintoProvider =
    Provider<Future<Recinto> Function(String canton, String parroquia,
        String nombre, String? direccion)>((ref) {
  return (canton, parroquia, nombre, direccion) async {
    final supabase = ref.read(supabaseClientProvider);
    final res = await supabase
        .from(SupabaseConstants.recintosTable)
        .insert({
          'canton': canton,
          'parroquia': parroquia,
          'nombre': nombre,
          'provincia': 'Ecuador', // ajusta según tu lógica
          if (direccion != null) 'direccion': direccion,
        })
        .select()
        .single();
    return RecintoModel.fromMap(res as Map<String, dynamic>);
  };
});

// ─── Crear coordinador de recinto ────────────────────────────────────────────
final crearCoordinadorRecintoProvider =
    Provider<Future<void> Function(String cedula, String nombres,
        String apellidos, String telefono, int recintoId)>((ref) {
  return (cedula, nombres, apellidos, telefono, recintoId) async {
    final supabase = ref.read(supabaseClientProvider);
    await supabase.functions.invoke('crear-usuario', body: {
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'rol': 'coordinador_recinto',
      'recinto_id': recintoId,
    });
  };
});

// ─── Coordinadores de recinto ─────────────────────────────────────────────────
final coordinadoresRecintoProvider =
    FutureProvider<List<Usuario>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final res = await supabase
      .from('usuarios')
      .select()
      .eq('rol', 'coordinador_recinto')
      .order('nombre');
  return (res as List)
      .map((r) =>
          UsuarioModel.fromMap(r as Map<String, dynamic>, correo: ''))
      .toList();
});

          
================================================
📄 ARCHIVO: lib/features/auth/presentation/coordinador_recinto/coordinador_recinto_providers.dart
================================================

// lib/features/auth/presentation/coordinador_recinto/coordinador_recinto_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../data/datasources/supabase_client_provider.dart';
import '../../data/models/mesa_jrv_model.dart';
import '../../data/models/usuario_model.dart';
import '../../data/models/acta_model.dart';
import '../../domain/entities/mesa_jrv.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/acta.dart';

// ─── Mesas del recinto ────────────────────────────────────────────────────────
final mesasPorRecintoProvider =
    FutureProvider.family<List<MesaJrv>, int>((ref, recintoId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final res = await supabase
      .from(SupabaseConstants.mesasJrvTable)
      .select()
      .eq('recinto_id', recintoId)
      .order('numero_mesa');
  return (res as List)
      .map((r) => MesaJrvModel.fromMap(r as Map<String, dynamic>))
      .toList();
});

// ─── Actas de una mesa ────────────────────────────────────────────────────────
final actasDeMesaProvider =
    FutureProvider.family<List<Acta>, int>((ref, mesaId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final res = await supabase
      .from(SupabaseConstants.actasTable)
      .select()
      .eq('mesa_id', mesaId);
  return (res as List)
      .map((r) => ActaModel.fromMap(r as Map<String, dynamic>))
      .toList();
});

// ─── Veedores del recinto (para mostrar asignaciones) ────────────────────────
final veedoresDeRecintoProvider =
    FutureProvider.family<List<Usuario>, int>((ref, recintoId) async {
  final supabase = ref.watch(supabaseClientProvider);
  // Trae usuarios con rol veedor que tienen mesas asignadas en este recinto
  final res = await supabase
      .from('veedor_mesas')
      .select('''
        usuario_id,
        mesa_id,
        usuarios!inner(*),
        mesas_jrv!inner(recinto_id)
      ''')
      .eq('mesas_jrv.recinto_id', recintoId);

  final vistos = <String>{};
  final lista = <Usuario>[];
  for (final row in res as List) {
    final uid = row['usuario_id'] as String;
    if (!vistos.contains(uid)) {
      vistos.add(uid);
      lista.add(UsuarioModel.fromMap(
        row['usuarios'] as Map<String, dynamic>,
        correo: '',
      ));
    }
  }
  return lista;
});

// ─── Resumen de avance del recinto ───────────────────────────────────────────
class ResumenRecinto {
  final int totalMesas;
  final int mesasConActaAlcalde;
  final int mesasConActaPrefecto;

  const ResumenRecinto({
    required this.totalMesas,
    required this.mesasConActaAlcalde,
    required this.mesasConActaPrefecto,
  });

  int get mesasCompletas =>
      [mesasConActaAlcalde, mesasConActaPrefecto].reduce((a, b) => a < b ? a : b);
  int get actasPendientes => (totalMesas * 2) - mesasConActaAlcalde - mesasConActaPrefecto;
}

final resumenRecintoProvider =
    FutureProvider.family<ResumenRecinto, int>((ref, recintoId) async {
  final mesas = await ref.watch(mesasPorRecintoProvider(recintoId).future);
  if (mesas.isEmpty) {
    return const ResumenRecinto(
        totalMesas: 0, mesasConActaAlcalde: 0, mesasConActaPrefecto: 0);
  }

  final supabase = ref.watch(supabaseClientProvider);
  final mesaIds = mesas.map((m) => m.id).toList();

  final res = await supabase
      .from(SupabaseConstants.actasTable)
      .select('mesa_id, dignidad')
      .inFilter('mesa_id', mesaIds);

  int alcalde = 0, prefecto = 0;
  for (final row in res as List) {
    final d = row['dignidad'] as String?;
    if (d == 'Alcalde') alcalde++;
    if (d == 'Prefecto') prefecto++;
  }

  return ResumenRecinto(
    totalMesas: mesas.length,
    mesasConActaAlcalde: alcalde,
    mesasConActaPrefecto: prefecto,
  );
});

// ─── Crear mesa ───────────────────────────────────────────────────────────────
final crearMesaProvider =
    Provider<Future<void> Function(int recintoId, int numero, GeneroMesa genero)>(
        (ref) {
  return (recintoId, numero, genero) async {
    final supabase = ref.read(supabaseClientProvider);
    await supabase.from(SupabaseConstants.mesasJrvTable).insert({
      'recinto_id': recintoId,
      'numero_mesa': numero,
      'genero': genero.dbValue,
    });
  };
});

// ─── Crear cuenta de veedor ───────────────────────────────────────────────────
// Llama a una Edge Function de Supabase para crear el usuario en auth + perfil
final crearVeedorProvider =
    Provider<Future<void> Function(String cedula, String nombres, String apellidos, String telefono, int mesaId)>(
        (ref) {
  return (cedula, nombres, apellidos, telefono, mesaId) async {
    final supabase = ref.read(supabaseClientProvider);
    // Invoca la Edge Function 'crear-usuario' (ver nota en el SQL)
    await supabase.functions.invoke('crear-usuario', body: {
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'rol': 'veedor',
      'mesa_id': mesaId,
    });
  };
});

// ─── Reasignar veedor a mesa ──────────────────────────────────────────────────
final reasignarVeedorProvider =
    Provider<Future<void> Function(String usuarioId, int mesaId)>((ref) {
  return (usuarioId, mesaId) async {
    final supabase = ref.read(supabaseClientProvider);
    // Elimina asignación anterior y crea la nueva
    await supabase
        .from('veedor_mesas')
        .delete()
        .eq('usuario_id', usuarioId);
    await supabase.from('veedor_mesas').insert({
      'usuario_id': usuarioId,
      'mesa_id': mesaId,
    });
  };
});

          
================================================
📄 ARCHIVO: lib/features/auth/presentation/coordinador_recinto/coordinador_recinto_panel_screen.dart
================================================

// lib/features/auth/presentation/coordinador_recinto/coordinador_recinto_panel_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/acta.dart';
import '../../domain/entities/mesa_jrv.dart';
import '../../domain/entities/organizacion_politica.dart';
import '../../domain/entities/usuario.dart';
import '../controller/login_controller.dart';
import '../veedor/acta_form_screen.dart';
import '../veedor/veedor_providers.dart';
import 'coordinador_recinto_providers.dart';

class CoordinadorRecintoPanelScreen extends ConsumerWidget {
  const CoordinadorRecintoPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActualProvider);
    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // El recinto del coordinador viene en recintoId del perfil
    final recintoId = usuario.recintoId;
    if (recintoId == null) {
      return const Scaffold(
        body: Center(
            child: Text(
                'Sin recinto asignado. Contacta al coordinador provincial.')),
      );
    }

    final resumenAsync = ref.watch(resumenRecintoProvider(recintoId));
    final mesasAsync = ref.watch(mesasPorRecintoProvider(recintoId));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Coordinador de Recinto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('${usuario.nombres} ${usuario.apellidos}',
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined, size: 20),
            tooltip: 'Crear veedor',
            onPressed: () =>
                _mostrarDialogoCrearVeedor(context, ref, recintoId),
          ),
          IconButton(
            icon: const Icon(Icons.add_road_outlined, size: 20),
            tooltip: 'Agregar mesa',
            onPressed: () => _mostrarDialogoCrearMesa(context, ref, recintoId),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, size: 20),
            onPressed: () async {
              await ref.read(loginControllerProvider.notifier).logout();
              if (context.mounted)
                Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF1B5E20),
        onRefresh: () async {
          ref.invalidate(resumenRecintoProvider(recintoId));
          ref.invalidate(mesasPorRecintoProvider(recintoId));
        },
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Banner resumen
            resumenAsync.when(
              loading: () => const _BannerCargando(),
              error: (e, _) => _BannerError(mensaje: e.toString()),
              data: (resumen) => _BannerResumen(resumen: resumen),
            ),
            const SizedBox(height: 12),

            // Lista de mesas
            mesasAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: Colors.red)),
              ),
              data: (mesas) {
                if (mesas.isEmpty) {
                  return _SinMesasView(
                    onAgregar: () =>
                        _mostrarDialogoCrearMesa(context, ref, recintoId),
                  );
                }
                return Column(
                  children: mesas
                      .map((mesa) => _TarjetaMesaCoordinador(
                            mesa: mesa,
                            usuario: usuario,
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Dialogo crear mesa ──────────────────────────────────────────────────────
  void _mostrarDialogoCrearMesa(
      BuildContext context, WidgetRef ref, int recintoId) {
    final ctrlNumero = TextEditingController();
    GeneroMesa generoSeleccionado = GeneroMesa.unica;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Nueva mesa / JRV',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrlNumero,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Número de mesa',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Género',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
              ),
              const SizedBox(height: 6),
              ...GeneroMesa.values.map((g) => RadioListTile<GeneroMesa>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title:
                        Text(g.dbValue, style: const TextStyle(fontSize: 13)),
                    value: g,
                    groupValue: generoSeleccionado,
                    onChanged: (v) => setS(() => generoSeleccionado = v!),
                  )),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20)),
              onPressed: () async {
                final numero = int.tryParse(ctrlNumero.text);
                if (numero == null) return;
                try {
                  await ref.read(crearMesaProvider)(
                      recintoId, numero, generoSeleccionado);
                  ref.invalidate(mesasPorRecintoProvider(recintoId));
                  ref.invalidate(resumenRecintoProvider(recintoId));
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialogo crear veedor ────────────────────────────────────────────────────
  void _mostrarDialogoCrearVeedor(
      BuildContext context, WidgetRef ref, int recintoId) {
    final ctrlCedula = TextEditingController();
    final ctrlNombres = TextEditingController();
    final ctrlApellidos = TextEditingController();
    final ctrlTelefono = TextEditingController();
    int? mesaIdSeleccionada;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final mesasAsync = ref.watch(mesasPorRecintoProvider(recintoId));
          return AlertDialog(
            title: const Text('Crear veedor',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CampoTexto(
                      ctrl: ctrlCedula,
                      label: 'Cédula',
                      digitsOnly: true,
                      maxLength: 10),
                  const SizedBox(height: 10),
                  _CampoTexto(ctrl: ctrlNombres, label: 'Nombres'),
                  const SizedBox(height: 10),
                  _CampoTexto(ctrl: ctrlApellidos, label: 'Apellidos'),
                  const SizedBox(height: 10),
                  _CampoTexto(
                      ctrl: ctrlTelefono, label: 'Teléfono', digitsOnly: true),
                  const SizedBox(height: 10),
                  mesasAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error cargando mesas: $e'),
                    data: (mesas) => DropdownButtonFormField<int>(
                      value: mesaIdSeleccionada,
                      hint: const Text('Asignar a mesa'),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: mesas
                          .map((m) => DropdownMenuItem(
                                value: m.id,
                                child: Text(
                                    'Mesa ${m.numeroMesa} — ${m.genero.dbValue}'),
                              ))
                          .toList(),
                      onChanged: (v) => setS(() => mesaIdSeleccionada = v),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar')),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20)),
                onPressed: mesaIdSeleccionada == null
                    ? null
                    : () async {
                        try {
                          await ref.read(crearVeedorProvider)(
                            ctrlCedula.text.trim(),
                            ctrlNombres.text.trim(),
                            ctrlApellidos.text.trim(),
                            ctrlTelefono.text.trim(),
                            mesaIdSeleccionada!,
                          );
                          ref.invalidate(veedoresDeRecintoProvider(recintoId));
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text('Veedor creado correctamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                child: const Text('Crear'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────
// Banner resumen
// ─────────────────────────────────────────
class _BannerResumen extends StatelessWidget {
  final ResumenRecinto resumen;
  const _BannerResumen({required this.resumen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Stat(valor: '${resumen.totalMesas}', etiqueta: 'Mesas'),
          _Div(),
          _Stat(
              valor: '${resumen.mesasConActaAlcalde}',
              etiqueta: 'Actas alcalde'),
          _Div(),
          _Stat(
              valor: '${resumen.mesasConActaPrefecto}',
              etiqueta: 'Actas prefecto'),
          _Div(),
          _Stat(
            valor: '${resumen.actasPendientes}',
            etiqueta: 'Pendientes',
            destacar: resumen.actasPendientes > 0,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String valor, etiqueta;
  final bool destacar;
  const _Stat(
      {required this.valor, required this.etiqueta, this.destacar = false});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(valor,
                style: TextStyle(
                  color: destacar ? const Color(0xFFFFCC02) : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                )),
            Text(etiqueta,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      );
}

class _Div extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1,
      height: 36,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 6));
}

class _BannerCargando extends StatelessWidget {
  const _BannerCargando();
  @override
  Widget build(BuildContext context) => Container(
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF1B5E20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
            child:
                CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
      );
}

class _BannerError extends StatelessWidget {
  final String mensaje;
  const _BannerError({required this.mensaje});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(mensaje, style: TextStyle(color: Colors.red.shade700)),
      );
}

// ─────────────────────────────────────────
// Tarjeta de mesa con sus actas
// ─────────────────────────────────────────
class _TarjetaMesaCoordinador extends ConsumerWidget {
  final MesaJrv mesa;
  final Usuario usuario;

  const _TarjetaMesaCoordinador({required this.mesa, required this.usuario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actasAsync = ref.watch(actasDeMesaProvider(mesa.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.how_to_vote_outlined,
                    size: 16, color: Color(0xFF1B5E20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mesa ${mesa.numeroMesa} — ${mesa.genero.dbValue}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
                // Botón reasignar veedor
                GestureDetector(
                  onTap: () => _mostrarReasignar(context, ref, mesa),
                  child: const Icon(Icons.swap_horiz,
                      size: 18, color: Color(0xFF1B5E20)),
                ),
              ],
            ),
          ),

          // Filas de actas
          actasAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Error: $e',
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
            data: (actas) {
              final actaAlcalde = actas
                  .where((a) => a.dignidad == Dignidad.alcalde)
                  .firstOrNull;
              final actaPrefecto = actas
                  .where((a) => a.dignidad == Dignidad.prefecto)
                  .firstOrNull;

              return Column(
                children: [
                  _FilaActaCoordinador(
                    etiqueta: 'Acta de Alcalde',
                    acta: actaAlcalde,
                    onTap: () => _irAFormulario(
                        context, ref, Dignidad.alcalde, actaAlcalde),
                  ),
                  Divider(
                      height: 1, thickness: 0.5, color: Colors.grey.shade200),
                  _FilaActaCoordinador(
                    etiqueta: 'Acta de Prefecto',
                    acta: actaPrefecto,
                    onTap: () => _irAFormulario(
                        context, ref, Dignidad.prefecto, actaPrefecto),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _irAFormulario(BuildContext context, WidgetRef ref,
      Dignidad dignidad, Acta? actaExistente) async {
    final orgsAsync = ref.read(organizacionesPorDignidadProvider(dignidad));
    final orgs = orgsAsync.maybeWhen(
        data: (d) => d, orElse: () => <OrganizacionPolitica>[]);

    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActaFormScreen(
          mesaId: mesa.id,
          mesaNombre: mesa.numeroMesa.toString(),
          recintoNombre: 'Recinto ${mesa.recintoId}',
          dignidad: dignidad,
          totalSufragantes: 300,
          organizaciones: orgs,
          userId: usuario.id,
          actaExistente: actaExistente,
        ),
      ),
    );
    ref.invalidate(actasDeMesaProvider(mesa.id));
  }

  void _mostrarReasignar(BuildContext context, WidgetRef ref, MesaJrv mesa) {
    // Cargar veedores del recinto para mostrarlos en el dropdown
    showDialog(
      context: context,
      builder: (ctx) => _DialogoReasignar(mesa: mesa, ref: ref),
    );
  }
}

class _FilaActaCoordinador extends StatelessWidget {
  final String etiqueta;
  final Acta? acta;
  final VoidCallback onTap;

  const _FilaActaCoordinador({
    required this.etiqueta,
    required this.acta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final registrada = acta != null;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              registrada
                  ? Icons.check_circle_outline
                  : Icons.radio_button_unchecked,
              size: 18,
              color: registrada ? Colors.green.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(etiqueta,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  if (acta?.gpsLat != null)
                    Text(
                      'GPS: ${acta!.gpsLat!.toStringAsFixed(5)}, ${acta!.gpsLng!.toStringAsFixed(5)}',
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    ),
                ],
              ),
            ),
            _BadgeEstadoActa(acta: acta),
            const SizedBox(width: 8),
            Icon(
              registrada ? Icons.edit_outlined : Icons.add_circle_outline,
              size: 16,
              color: const Color(0xFF1B5E20),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeEstadoActa extends StatelessWidget {
  final Acta? acta;
  const _BadgeEstadoActa({required this.acta});

  @override
  Widget build(BuildContext context) {
    if (acta == null) {
      return _badge('Pendiente', Colors.orange.shade700, Colors.orange.shade50,
          Colors.orange.shade200);
    }
    return switch (acta!.estado) {
      EstadoActa.ingresada => _badge('Ingresada', Colors.blue.shade700,
          Colors.blue.shade50, Colors.blue.shade200),
      EstadoActa.revisada => _badge('Revisada', Colors.green.shade700,
          Colors.green.shade50, Colors.green.shade200),
      EstadoActa.conNovedad => _badge('Con novedad', Colors.red.shade700,
          Colors.red.shade50, Colors.red.shade200),
    };
  }

  Widget _badge(String label, Color color, Color bg, Color border) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: border),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w500)),
      );
}

// ─────────────────────────────────────────
// Diálogo reasignar veedor
// ─────────────────────────────────────────
class _DialogoReasignar extends ConsumerStatefulWidget {
  final MesaJrv mesa;
  final WidgetRef ref;
  const _DialogoReasignar({required this.mesa, required this.ref});

  @override
  ConsumerState<_DialogoReasignar> createState() => _DialogoReasignarState();
}

class _DialogoReasignarState extends ConsumerState<_DialogoReasignar> {
  String? _veedorSeleccionado;

  @override
  Widget build(BuildContext context) {
    final veedoresAsync =
        ref.watch(veedoresDeRecintoProvider(widget.mesa.recintoId));

    return AlertDialog(
      title: Text(
        'Reasignar veedor — Mesa ${widget.mesa.numeroMesa}',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      content: veedoresAsync.when(
        loading: () => const SizedBox(
            height: 60, child: Center(child: CircularProgressIndicator())),
        error: (e, _) => Text('Error: $e'),
        data: (veedores) {
          if (veedores.isEmpty) {
            return const Text('No hay veedores disponibles en este recinto.',
                style: TextStyle(fontSize: 13));
          }
          return DropdownButtonFormField<String>(
            value: _veedorSeleccionado,
            hint: const Text('Seleccionar veedor'),
            decoration: const InputDecoration(
                border: OutlineInputBorder(), isDense: true),
            items: veedores
                .map((v) => DropdownMenuItem(
                      value: v.id,
                      child: Text('${v.nombres} ${v.apellidos}',
                          style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _veedorSeleccionado = v),
          );
        },
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        FilledButton(
          style:
              FilledButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
          onPressed: _veedorSeleccionado == null
              ? null
              : () async {
                  try {
                    await ref.read(reasignarVeedorProvider)(
                        _veedorSeleccionado!, widget.mesa.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veedor reasignado correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                },
          child: const Text('Reasignar'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Widgets auxiliares
// ─────────────────────────────────────────
class _SinMesasView extends StatelessWidget {
  final VoidCallback onAgregar;
  const _SinMesasView({required this.onAgregar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Sin mesas registradas',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text('Agrega las mesas de este recinto.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAgregar,
              icon: const Icon(Icons.add),
              label: const Text('Agregar mesa'),
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool digitsOnly;
  final int? maxLength;

  const _CampoTexto({
    required this.ctrl,
    required this.label,
    this.digitsOnly = false,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: digitsOnly ? TextInputType.number : TextInputType.text,
      inputFormatters: [
        if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}


          
================================================
📄 ARCHIVO: lib/main.dart
================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/supabase_constants.dart';
import 'features/auth/domain/entities/usuario.dart';
import 'features/auth/presentation/controller/login_controller.dart';
import 'features/auth/presentation/veedor/veedor_panel_screen.dart';
import 'features/auth/presentation/auth/olvide_password_screen.dart';
import 'features/auth/presentation/auth/cambiar_password_screen.dart';
import 'features/auth/presentation/coordinador_provincial/coordinador_provincial_panel_screen.dart';
import 'features/auth/presentation/coordinador_recinto/coordinador_recinto_panel_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConstants.url,
    publishableKey: SupabaseConstants.anonKey,
  );
  runApp(const ControlElectoralApp());
}

class ControlElectoralApp extends StatelessWidget {
  const ControlElectoralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Control Electoral',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        home: const LoginScreen(),
        // ─── REGISTRO DE RUTAS NOMBRADAS ─────────────────────────────────────
        routes: {
          '/veedor': (_) => const VeedorPanelScreen(),
          '/olvide-password': (_) => const OlvidePasswordScreen(),
          '/cambiar-password': (_) => const CambiarPasswordScreen(),
          '/provincial': (_) => const CoordinadorProvincialPanelScreen(),
          '/coordinador-recinto': (_) => const CoordinadorRecintoPanelScreen(),
        },
      ),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _cedulaCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  String? _selectedRol;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _passwordCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  RolUsuario _rolDesdeDropdown(String rol) {
    switch (rol) {
      case 'Coordinador Provincial':
        return RolUsuario.coordinadorProvincial;
      case 'Coordinador Recinto':
        return RolUsuario.coordinadorRecinto;
      case 'Veedor':
      default:
        return RolUsuario.veedor;
    }
  }

  Future<void> _onLoginPressed() async {
    FocusScope.of(context).unfocus();

    if (_selectedRol == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona tu rol antes de continuar.'),
          backgroundColor: Color(0xFFD92D20),
        ),
      );
      return;
    }

    final usuario = await ref
        .read(loginControllerProvider.notifier)
        .login(_cedulaCtrl.text.trim(), _passwordCtrl.text);

    if (!mounted || usuario == null) return;

    final rolEsperado = _rolDesdeDropdown(_selectedRol!);

    if (usuario.rol != rolEsperado) {
      await ref.read(loginControllerProvider.notifier).logout();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El rol seleccionado no corresponde a tu cuenta.'),
          backgroundColor: Color(0xFFD92D20),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (usuario.debeCambiarPassword) {
      Navigator.of(context).pushReplacementNamed('/cambiar-password');
      return;
    }

    switch (usuario.rol) {
      case RolUsuario.coordinadorProvincial:
        Navigator.of(context).pushReplacementNamed('/provincial');
        break;
      case RolUsuario.coordinadorRecinto:
        Navigator.of(context).pushReplacementNamed('/coordinador-recinto');
        break;
      case RolUsuario.veedor:
        Navigator.of(context).pushReplacementNamed('/veedor');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height - 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE4E7EC),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.verified_user_outlined,
                                color: Color(0xFF3422CD),
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Voter Portal',
                                style: TextStyle(
                                  color: Color(0xFF3422CD),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E7FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.unarchive_outlined,
                              color: Color(0xFF3422CD),
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Acceda a su portal de votación',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF101828),
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Ingrese sus credenciales oficiales para continuar de forma segura.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF475467),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildLabel('Seleccionar Rol'),
                          const SizedBox(height: 6),
                          _buildDropdownField(),
                          const SizedBox(height: 20),
                          _buildLabel('ID del Usuario'),
                          const SizedBox(height: 6),
                          _buildTextField(
                            controller: _cedulaCtrl,
                            hint: '10 dígitos numéricos',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLabel('Contraseña'),
                              GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .pushNamed('/olvide-password'),
                                child: const Text(
                                  '¿Olvidó su contraseña?',
                                  style: TextStyle(
                                    color: Color(0xFF3422CD),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _buildTextField(
                            controller: _passwordCtrl,
                            hint: '••••••••',
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF98A2B3),
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (state.hasError)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3F2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFECDCA),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Color(0xFFD92D20),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _mensajeError('${state.error}'),
                                      style: const TextStyle(
                                        color: Color(0xFFB42318),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: state.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF3422CD),
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: _onLoginPressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2B1CB1),
                                      elevation: 2,
                                      shadowColor: const Color(0xFF3422CD)
                                          .withOpacity(0.3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '¿No tienes cuenta? ',
                                style: TextStyle(
                                  color: Color(0xFF667085),
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .pushNamed('/solicitar-acceso'),
                                child: const Text(
                                  'Solicitar acceso',
                                  style: TextStyle(
                                    color: Color(0xFF3422CD),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FADF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF6EE7B7).withOpacity(0.5),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info,
                            color: Color(0xFF065F46),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Este sistema utiliza encriptación de grado militar y autenticación de dos factores para proteger su integridad democrática.',
                              style: TextStyle(
                                color: Color(0xFF065F46),
                                fontSize: 12,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF344054),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Color(0xFF101828), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
        prefixIcon: Icon(icon, color: const Color(0xFF667085), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3422CD), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedRol,
      hint: Row(
        children: const [
          Icon(
            Icons.account_circle_outlined,
            color: Color(0xFF667085),
            size: 20,
          ),
          SizedBox(width: 10),
          Text(
            'Seleccionar un rol',
            style: TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
          ),
        ],
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF667085),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3422CD), width: 1.5),
        ),
      ),
      items: const [
        'Coordinador Provincial',
        'Coordinador Recinto',
        'Veedor',
      ]
          .map(
            (value) => DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF101828),
                  fontSize: 14,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedRol = value),
    );
  }

  String _mensajeError(String error) {
    if (error.contains('Cédula inválida')) {
      return 'Cédula inválida. Verifica el número.';
    }
    if (error.contains('Invalid login credentials')) {
      return 'Cédula o contraseña incorrectos.';
    }
    if (error.contains('rate_limit')) {
      return 'Demasiados intentos. Espera un momento.';
    }
    if (error.contains('no registrado') || error.contains('not found')) {
      return 'Usuario no registrado en el sistema.';
    }
    if (error.contains('Email not confirmed')) {
      return 'Correo electrónico no confirmado. Revisa tu bandeja de entrada.';
    }
    return error; // muestra el error real para depuración
  }
}


          
================================================
📄 ARCHIVO: .flutter-plugins
================================================

# This is a generated file; do not edit or check into version control.
app_links=/Users/dam/.pub-cache/hosted/pub.dev/app_links-6.4.0/
app_links_linux=/Users/dam/.pub-cache/hosted/pub.dev/app_links_linux-1.0.3/
app_links_web=/Users/dam/.pub-cache/hosted/pub.dev/app_links_web-1.0.4/
camera=/Users/dam/.pub-cache/hosted/pub.dev/camera-0.11.0+2/
camera_android_camerax=/Users/dam/.pub-cache/hosted/pub.dev/camera_android_camerax-0.6.5+2/
camera_avfoundation=/Users/dam/.pub-cache/hosted/pub.dev/camera_avfoundation-0.9.17+5/
camera_web=/Users/dam/.pub-cache/hosted/pub.dev/camera_web-0.3.5/
connectivity_plus=/Users/dam/.pub-cache/hosted/pub.dev/connectivity_plus-6.1.5/
flutter_plugin_android_lifecycle=/Users/dam/.pub-cache/hosted/pub.dev/flutter_plugin_android_lifecycle-2.0.19/
geolocator=/Users/dam/.pub-cache/hosted/pub.dev/geolocator-12.0.0/
geolocator_android=/Users/dam/.pub-cache/hosted/pub.dev/geolocator_android-4.6.1/
geolocator_apple=/Users/dam/.pub-cache/hosted/pub.dev/geolocator_apple-2.3.9/
geolocator_web=/Users/dam/.pub-cache/hosted/pub.dev/geolocator_web-4.0.0/
geolocator_windows=/Users/dam/.pub-cache/hosted/pub.dev/geolocator_windows-0.2.3/
gtk=/Users/dam/.pub-cache/hosted/pub.dev/gtk-2.2.0/
path_provider=/Users/dam/.pub-cache/hosted/pub.dev/path_provider-2.1.4/
path_provider_android=/Users/dam/.pub-cache/hosted/pub.dev/path_provider_android-2.2.4/
path_provider_foundation=/Users/dam/.pub-cache/hosted/pub.dev/path_provider_foundation-2.4.1/
path_provider_linux=/Users/dam/.pub-cache/hosted/pub.dev/path_provider_linux-2.2.1/
path_provider_windows=/Users/dam/.pub-cache/hosted/pub.dev/path_provider_windows-2.3.0/
permission_handler=/Users/dam/.pub-cache/hosted/pub.dev/permission_handler-11.3.1/
permission_handler_android=/Users/dam/.pub-cache/hosted/pub.dev/permission_handler_android-12.0.13/
permission_handler_apple=/Users/dam/.pub-cache/hosted/pub.dev/permission_handler_apple-9.4.10/
permission_handler_html=/Users/dam/.pub-cache/hosted/pub.dev/permission_handler_html-0.1.3+5/
permission_handler_windows=/Users/dam/.pub-cache/hosted/pub.dev/permission_handler_windows-0.2.1/
shared_preferences=/Users/dam/.pub-cache/hosted/pub.dev/shared_preferences-2.2.3/
shared_preferences_android=/Users/dam/.pub-cache/hosted/pub.dev/shared_preferences_android-2.2.2/
shared_preferences_foundation=/Users/dam/.pub-cache/hosted/pub.dev/shared_preferences_foundation-2.5.3/
shared_preferences_linux=/Users/dam/.pub-cache/hosted/pub.dev/shared_preferences_linux-2.4.1/
shared_preferences_web=/Users/dam/.pub-cache/hosted/pub.dev/shared_preferences_web-2.4.1/
shared_preferences_windows=/Users/dam/.pub-cache/hosted/pub.dev/shared_preferences_windows-2.4.1/
sqflite=/Users/dam/.pub-cache/hosted/pub.dev/sqflite-2.3.3+1/
url_launcher=/Users/dam/.pub-cache/hosted/pub.dev/url_launcher-6.3.1/
url_launcher_android=/Users/dam/.pub-cache/hosted/pub.dev/url_launcher_android-6.3.2/
url_launcher_ios=/Users/dam/.pub-cache/hosted/pub.dev/url_launcher_ios-6.3.2/
url_launcher_linux=/Users/dam/.pub-cache/hosted/pub.dev/url_launcher_linux-3.2.1/
url_launcher_macos=/Users/dam/.pub-cache/hosted/pub.dev/url_launcher_macos-3.2.2/
url_launcher_web=/Users/dam/.pub-cache/hosted/pub.dev/url_launcher_web-2.3.3/
url_launcher_windows=/Users/dam/.pub-cache/hosted/pub.dev/url_launcher_windows-3.1.3/


          
================================================
📄 ARCHIVO: analysis_options.yaml
================================================

# This file configures the analyzer, which statically analyzes Dart code to
# check for errors, warnings, and lints.
#
# The issues identified by the analyzer are surfaced in the UI of Dart-enabled
# IDEs (https://dart.dev/tools#ides-and-editors). The analyzer can also be
# invoked from the command line by running `flutter analyze`.

# The following line activates a set of recommended lints for Flutter apps,
# packages, and plugins designed to encourage good coding practices.
include: package:flutter_lints/flutter.yaml

linter:
  # The lint rules applied to this project can be customized in the
  # section below to disable rules from the `package:flutter_lints/flutter.yaml`
  # included above or to enable additional rules. A list of all available lints
  # and their documentation is published at https://dart.dev/lints.
  #
  # Instead of disabling a lint rule for the entire project in the
  # section below, it can also be suppressed for a single line of code
  # or a specific dart file by using the `// ignore: name_of_lint` and
  # `// ignore_for_file: name_of_lint` syntax on the line or in the file
  # producing the lint.
  rules:
    # avoid_print: false  # Uncomment to disable the `avoid_print` rule
    # prefer_single_quotes: true  # Uncomment to enable the `prefer_single_quotes` rule

# Additional information about this file can be found at
# https://dart.dev/guides/language/analysis-options


