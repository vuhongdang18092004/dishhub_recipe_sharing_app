import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../data/models/recipe_step.dart';
import '../bloc/recipe_bloc.dart';

class EditRecipePage extends StatefulWidget {
  final RecipeEntity recipe;

  const EditRecipePage({super.key, required this.recipe});

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late List<TextEditingController> _ingredientControllers;
  late List<TextEditingController> _stepControllers;
  late List<String?> _stepPhotoUrls; // thêm để lưu ảnh cho từng bước
  List<String> _photoUrls = [];
  String? _videoUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.recipe.title);
    _descriptionController = TextEditingController(
      text: widget.recipe.description,
    );

    _ingredientControllers = widget.recipe.ingredients
        .map((ing) => TextEditingController(text: ing))
        .toList();

    _stepControllers = widget.recipe.steps
        .map((s) => TextEditingController(text: s.description))
        .toList();

    _stepPhotoUrls = widget.recipe.steps.map((s) => s.photoUrl).toList();
    _photoUrls = List.from(widget.recipe.photoUrls);
    _videoUrl = widget.recipe.videoUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var c in _ingredientControllers) {
      c.dispose();
    }
    for (var c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickRecipeImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _photoUrls.add(picked.path); // local path (chưa upload)
      });
    }
  }

  Future<void> _pickStepImage(int index) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _stepPhotoUrls[index] = picked.path;
      });
    }
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _videoUrl = picked.path;
      });
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _addStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
      _stepPhotoUrls.add(null);
    });
  }

  void _saveChanges() {
    final updatedRecipe = widget.recipe.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      photoUrls: _photoUrls,
      videoUrl: _videoUrl,
      ingredients: _ingredientControllers.map((c) => c.text.trim()).toList(),
      steps: List.generate(
        _stepControllers.length,
        (i) => RecipeStep(
          description: _stepControllers[i].text.trim(),
          photoUrl: _stepPhotoUrls[i],
        ),
      ),
    );

    context.read<RecipeBloc>().add(UpdateExistingRecipe(updatedRecipe));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Đã lưu thay đổi công thức')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa công thức'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟢 Tiêu đề
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tên món ăn',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 🟢 Mô tả
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // 🖼️ Ảnh món ăn
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hình ảnh món ăn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _pickRecipeImage,
                  icon: const Icon(Icons.add_a_photo),
                ),
              ],
            ),
            if (_photoUrls.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photoUrls.length,
                  itemBuilder: (context, index) {
                    final path = _photoUrls[index];
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: path.startsWith('http')
                                ? Image.network(
                                    path,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(path),
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _photoUrls.removeAt(index);
                              });
                            },
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),

            // 🎬 Video
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Video hướng dẫn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _pickVideo,
                  icon: const Icon(Icons.video_call),
                ),
              ],
            ),
            if (_videoUrl != null)
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black12,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.video_library,
                      size: 60,
                      color: Colors.grey,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => setState(() => _videoUrl = null),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // 🟢 Nguyên liệu
            _buildSectionHeader('Nguyên liệu', _addIngredient),
            _buildDynamicList(_ingredientControllers, 'Nguyên liệu'),

            const SizedBox(height: 24),

            // 🟢 Các bước
            _buildSectionHeader('Các bước', _addStep),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stepControllers.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        TextField(
                          controller: _stepControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Bước ${index + 1}',
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        if (_stepPhotoUrls[index] != null)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _stepPhotoUrls[index]!.startsWith('http')
                                    ? Image.network(
                                        _stepPhotoUrls[index]!,
                                        width: double.infinity,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(_stepPhotoUrls[index]!),
                                        width: double.infinity,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () => setState(
                                    () => _stepPhotoUrls[index] = null,
                                  ),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black54,
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _pickStepImage(index),
                              icon: const Icon(Icons.photo_camera),
                              label: const Text('Chọn ảnh'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _stepControllers.removeAt(index);
                                  _stepPhotoUrls.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),

            // 🟢 Nút lưu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Lưu thay đổi'),
                onPressed: _saveChanges,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _buildDynamicList(
    List<TextEditingController> controllers,
    String labelPrefix,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controllers.length,
      itemBuilder: (context, index) {
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: controllers[index],
                decoration: InputDecoration(
                  labelText: '$labelPrefix ${index + 1}',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => setState(() => controllers.removeAt(index)),
            ),
          ],
        );
      },
    );
  }
}
