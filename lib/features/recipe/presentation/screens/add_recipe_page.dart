import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../bloc/recipe_bloc.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../data/models/recipe_step.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> ingredients = [];
  final List<RecipeStep> steps = [];
  final List<XFile> photos = [];
  XFile? video;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => photos.add(picked));
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) setState(() => video = picked);
  }

  void _addIngredient(String ingredient) {
    if (ingredient.trim().isEmpty) return;
    setState(() => ingredients.add(ingredient.trim()));
  }

  Future<void> _addStepDialog() async {
    final _stepTitleController = TextEditingController();
    final _stepDescController = TextEditingController();
    XFile? stepPhoto;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Thêm bước'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _stepTitleController,
                  decoration: const InputDecoration(labelText: 'Tiêu đề bước'),
                ),
                TextField(
                  controller: _stepDescController,
                  decoration: const InputDecoration(labelText: 'Mô tả bước'),
                ),
                const SizedBox(height: 8),
                stepPhoto != null
                    ? Image.file(
                        File(stepPhoto!.path),
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox.shrink(),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null)
                      setDialogState(() => stepPhoto = picked);
                  },
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Thêm ảnh cho bước'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_stepTitleController.text.trim().isEmpty &&
                    _stepDescController.text.trim().isEmpty)
                  return;

                setState(() {
                  steps.add(
                    RecipeStep(
                      title: _stepTitleController.text.trim(),
                      description: _stepDescController.text.trim(),
                      photoUrl: stepPhoto?.path,
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> uploadToCloudinary(File file) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    if (cloudName == null || uploadPreset == null) return null;

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final resBody = await response.stream.bytesToString();
      final data = json.decode(resBody);
      return data['secure_url'] as String?;
    } else {
      print('Cloudinary upload failed: ${response.statusCode}');
      return null;
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nhập tiêu đề và mô tả')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để tạo công thức')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    List<String> photoUrls = [];
    for (var photo in photos) {
      final url = await uploadToCloudinary(File(photo.path));
      if (url != null) photoUrls.add(url);
    }

    List<RecipeStep> uploadedSteps = [];
    for (var step in steps) {
      String? stepUrl;
      if (step.photoUrl != null) {
        stepUrl = await uploadToCloudinary(File(step.photoUrl!));
      }
      uploadedSteps.add(
        RecipeStep(
          title: step.title,
          description: step.description,
          photoUrl: stepUrl,
        ),
      );
    }

    final newRecipe = RecipeEntity(
      id: '',
      title: title,
      description: description,
      photoUrls: photoUrls,
      videoUrl: video?.path,
      creatorId: user.uid,
      ingredients: ingredients,
      steps: uploadedSteps,
      likes: [],
      savedBy: [],
    );

    context.read<RecipeBloc>().add(AddNewRecipe(newRecipe));

    Navigator.pop(context);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final _ingredientController = TextEditingController();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ảnh công thức',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ...photos.map(
                          (p) => Image.file(
                            File(p.path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_a_photo),
                          onPressed: _pickPhoto,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Video công thức',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        video != null
                            ? Text(video!.name)
                            : const Text('Chưa có video'),
                        IconButton(
                          icon: const Icon(Icons.video_library),
                          onPressed: _pickVideo,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Tiêu đề'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Mô tả'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nguyên liệu',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ingredientController,
                            decoration: const InputDecoration(
                              hintText: 'Nhập nguyên liệu',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            _addIngredient(_ingredientController.text);
                            _ingredientController.clear();
                          },
                        ),
                      ],
                    ),
                    ...ingredients.map(
                      (ing) => ListTile(
                        title: Text(ing),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              setState(() => ingredients.remove(ing)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Các bước',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: _addStepDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm bước'),
                        ),
                      ],
                    ),
                    ...steps.asMap().entries.map((entry) {
                      final i = entry.key;
                      final step = entry.value;
                      return ListTile(
                        leading: step.photoUrl != null
                            ? Image.file(
                                File(step.photoUrl!),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : null,
                        title: Text('${i + 1}. ${step.title}'),
                        subtitle: Text(step.description),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => setState(() => steps.removeAt(i)),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            Center(
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text(
                  'Thêm công thức',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
