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