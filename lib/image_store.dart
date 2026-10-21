import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

/// منتخب کردہ تصویر کے راستے کو مستقل طور پر محفوظ کرنے کے لیے مددگار
class ImageStore {
  ImageStore._();

  /// تصویر کے راستے کو bytes میں بدلتا ہے (پرنٹ/PDF کے لیے)
  static Future<pw.MemoryImage?> loadPdfImage(String? path) async {
    if (path == null || path.trim().isEmpty) return null;
    try {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return pw.MemoryImage(bytes);
      }
    } catch (_) {}
    try {
      final data = await rootBundle.load(path);
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {}
    return null;
  }

  /// ایپ UI میں دکھانے کے لیے ImageProvider
  static ImageProvider? provider(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('assets/')) return AssetImage(path);
    final file = File(path);
    if (file.existsSync()) return FileImage(file);
    return null;
  }
}
