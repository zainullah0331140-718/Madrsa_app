import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'image_store.dart';
import 'strings.dart';

/// طالب علم کی تصویر لینے/منتخب کرنے کا وِجٹ (کیمرہ یا گیلری)
class StudentPhotoPicker extends StatefulWidget {
  const StudentPhotoPicker({
    super.key,
    required this.photoPath,
    required this.onChanged,
  });

  final String? photoPath;
  final ValueChanged<String?> onChanged;

  @override
  State<StudentPhotoPicker> createState() => _StudentPhotoPickerState();
}

class _StudentPhotoPickerState extends State<StudentPhotoPicker> {
  final ImagePicker _picker = ImagePicker();
  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    try {
      setState(() => _busy = true);
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        imageQuality: 80,
      );
      if (file == null) return;
      widget.onChanged(file.path);
    } catch (e) {
      if (!mounted) return;
      final s = Strings.current;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${s.photoNotSupported}: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showOptions() {
    final s = Strings.current;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                s.photoOptions,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(s.fromCamera),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(s.fromGallery),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.gallery);
              },
            ),
            if ((widget.photoPath ?? '').isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(s.removePhoto,
                    style: const TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onChanged(null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.photoPath;
    final provider = ImageStore.provider(path);
    final hasPhoto = provider != null;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _busy ? null : _showOptions,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.green[100],
                  backgroundImage: hasPhoto ? provider : null,
                  child: hasPhoto
                      ? null
                      : const Icon(Icons.person, size: 52, color: Colors.green),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.camera_alt,
                            size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: _busy ? null : _showOptions,
            icon: const Icon(Icons.add_a_photo, size: 16),
            label: Text(Strings.current.addPhoto),
          ),
        ],
      ),
    );
  }
}

/// ڈسک پر محفوظ تصویر کو یقینی بنانے کے لیے مددگار (موجود ہو تو راستہ، ورنہ null)
String? normalizePhoto(String? path) {
  if (path == null) return null;
  final trimmed = path.trim();
  if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return null;
  return trimmed;
}

/// کیا راستہ ڈسک پر موجود ہے؟
bool photoExists(String? path) {
  final p = normalizePhoto(path);
  if (p == null) return false;
  if (p.startsWith('assets/')) return true;
  return File(p).existsSync();
}
