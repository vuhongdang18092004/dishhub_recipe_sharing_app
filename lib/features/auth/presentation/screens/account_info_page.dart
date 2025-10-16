import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/user_entity.dart';

class AccountInfoPage extends StatefulWidget {
  final UserEntity user;

  const AccountInfoPage({super.key, required this.user});

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  File? _avatarImageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _avatarImageFile = File(picked.path));
    }
  }

  Future<void> _saveChanges() async {
    try {
      final newName = _nameController.text.trim();
      String? newPhotoUrl = widget.user.photo;

      if (_avatarImageFile != null) {
        final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
        final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

        if (cloudName == null || uploadPreset == null) {
          throw Exception("Thiếu cấu hình Cloudinary trong .env");
        }

        final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
        final request = http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = uploadPreset
          ..fields['folder'] = 'avatars'
          ..files.add(await http.MultipartFile.fromPath('file', _avatarImageFile!.path));

        final response = await request.send();
        final responseData = await http.Response.fromStream(response);

        if (response.statusCode == 200) {
          final data = jsonDecode(responseData.body);
          newPhotoUrl = data['secure_url'];
        } else {
          throw Exception("Upload thất bại (${response.statusCode})");
        }
      }

      await FirebaseFirestore.instance.collection('users').doc(widget.user.id).update({
        'name': newName,
        'photo': newPhotoUrl,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Cập nhật thành công")),
      );
    } catch (e) {
      debugPrint("Lỗi khi cập nhật: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cập nhật thất bại: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    ImageProvider<Object>? imageProvider;
    if (_avatarImageFile != null) {
      imageProvider = FileImage(_avatarImageFile!);
    } else if (user.photo != null && user.photo!.isNotEmpty) {
      imageProvider = NetworkImage(user.photo!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Thông tin tài khoản")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: imageProvider,
                backgroundColor: Colors.grey[200],
                child: imageProvider == null
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text("Thay đổi ảnh đại diện"),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Họ và tên",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _emailController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save_outlined),
                label: const Text("Lưu thay đổi"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
