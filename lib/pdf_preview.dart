import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'main.dart' show App3D;
import 'strings.dart';

/// پی‌دی‌اف پیش‌نظارہ صفحہ — پرنٹ سے پہلے مکمل پیش‌نظارہ دکھاتا ہے۔
/// نیچے پرنٹ، سیو (PDF) اور شیئر کے بٹن ہیں جیسا کہ معمولی پرنٹ ڈائیلاگ میں ہوتا ہے۔
class PdfPreviewPage extends StatelessWidget {
  final List<int> bytes;
  final String fileName;

  const PdfPreviewPage({super.key, required this.bytes, required this.fileName});

  /// پیش‌نظارہ صفحہ کھولنے کا آسان طریقہ — سب پرنٹ جگہوں سے یہی صرف کال کریں
  static Future<void> show(
    BuildContext context, {
    required List<int> bytes,
    required String fileName,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PdfPreviewPage(bytes: bytes, fileName: fileName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings.current;
    return Scaffold(
      backgroundColor: App3D.bg,
      appBar: AppBar(
        backgroundColor: App3D.charcoal,
        foregroundColor: Colors.white,
        title: Text(
          '${s.pdfPreview} — $fileName',
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // اوپر تیلے ہوئے بٹن: پرنٹ / PDF محفوظ / شیئر
          Container(
            width: double.infinity,
            color: App3D.charcoal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _actionButton(
                  icon: Icons.print,
                  label: s.lPrint,
                  onTap: () => Printing.layoutPdf(
                    name: fileName,
                    onLayout: (format) async => Uint8List.fromList(bytes),
                  ),
                ),
                const SizedBox(width: 8),
                _actionButton(
                  icon: Icons.save_alt,
                  label: s.savePdf,
                  onTap: () => Printing.sharePdf(
                    bytes: Uint8List.fromList(bytes),
                    filename: fileName,
                  ),
                ),
                const Spacer(),
                // PdfPreview کے اپنے بٹن غیر فعال ہیں، اوپر والے بٹن استعمال ہوں گے
              ],
            ),
          ),
          Expanded(
            child: PdfPreview(
              //PdfPreview خود اسکرول/زوم کرتا ہے
              build: (format) async => Uint8List.fromList(bytes),
              allowPrinting: false,
              allowSharing: false,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              pdfFileName: fileName,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(label,
                  style:
                      const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

/// کسی بھی PDF سروس کے بائٹس پر پیش‌نظارہ دکھانے کا مختصر طریقہ
Future<bool> showPdfPreview(
  BuildContext context, {
  required List<int> bytes,
  required String fileName,
}) async {
  await PdfPreviewPage.show(context, bytes: bytes, fileName: fileName);
  return true;
}
