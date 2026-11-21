import 'dart:io';

import 'package:archive/archive_io.dart'; // Make sure to import archive_io
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  /// Whether the database has been opened and is ready to use.
  static bool get isInitialized => _database != null;

  /// Access the opened database anywhere in the app.
  /// Throws if initialize() has not completed yet.
  static Database get database {
    if (_database == null) {
      throw Exception(
        "Database not initialized. Call DatabaseService.initialize() first.",
      );
    }
    return _database!;
  }

  static Future<void> initialize() async {
    if (_database != null) return;

    // 🔧 SIMULATE SLOW DEVICE — remove this line before production
    // await Future.delayed(const Duration(seconds: 1000));

    final docDir = await getApplicationDocumentsDirectory();
    final dbPath = join(docDir.path, "drug_interactions.db");
    final dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      // 1. Copy the zip from assets to a temporary file on disk
      final zipData = await rootBundle.load("assets/drug_interactions.zip");
      final tempDir = await getTemporaryDirectory();
      final tempZipPath = join(tempDir.path, "db.zip");
      final tempZipFile = File(tempZipPath);
      await tempZipFile.writeAsBytes(
        zipData.buffer.asUint8List(
          zipData.offsetInBytes,
          zipData.lengthInBytes,
        ),
      );

      // 2. Use streaming to extract directly to disk without loading into RAM
      final inputStream = InputFileStream(tempZipPath);
      final archive = ZipDecoder().decodeStream(inputStream);

      for (final file in archive) {
        if (file.isFile && file.name.endsWith('.db')) {
          final outputStream = OutputFileStream(dbPath);
          file.writeContent(outputStream); // Writes directly to disk
          outputStream.closeSync();
          break;
        }
      }

      // 3. Clean up temporary files
      inputStream.closeSync();
      await tempZipFile.delete();
    }

    _database = await openDatabase(dbPath, version: 1);
  }
}
