import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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
  final _ingredientController = TextEditingController();

  final List<String> ingredients = [];
  final List<RecipeStep> steps = [];
  final List<XFile> photos = [];
  final List<String> tags = [];

  XFile? video;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => photos.add(picked));
  }

  void _removePhoto(XFile photo) {
    setState(() => photos.remove(photo));
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;

    final tempDir = await getApplicationDocumentsDirectory();
    final savedPath = '${tempDir.path}/${picked.name}';
    await File(picked.path).copy(savedPath);

    setState(() => video = XFile(savedPath));
  }

  void _removeVideo() {
    setState(() => video = null);
  }

  void _addIngredient(String ingredient) {
    if (ingredient.trim().isEmpty) return;
    setState(() => ingredients.add(ingredient.trim()));
  }

  Future<void> _addStepDialog() async {
    final stepDescController = TextEditingController();
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
                  controller: stepDescController,
                  decoration: const InputDecoration(labelText: 'Mô tả bước'),
                ),
                const SizedBox(height: 8),
                if (stepPhoto != null)
                  Image.file(
                    File(stepPhoto!.path),
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null) {
                      setDialogState(() => stepPhoto = picked);
                    }
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
                if (stepDescController.text.trim().isEmpty) return;
                setState(() {
                  steps.add(
                    RecipeStep(
                      description: stepDescController.text.trim(),
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

  Future<String?> uploadToCloudinary(File file, {bool isVideo = false}) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];
    if (cloudName == null || uploadPreset == null) return null;

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/${isVideo ? 'video' : 'image'}/upload',
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
      debugPrint('Cloudinary upload failed: ${response.statusCode}');
      return null;
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề và mô tả')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để tạo công thức')),
      );
      return;
    }

    if (!mounted) return;
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
        RecipeStep(description: step.description, photoUrl: stepUrl),
      );
    }

    String? videoUrl;
    if (video != null && await File(video!.path).exists()) {
      videoUrl = await uploadToCloudinary(File(video!.path), isVideo: true);
    }

    final newRecipe = RecipeEntity(
      id: '',
      title: title,
      description: description,
      photoUrls: photoUrls,
      videoUrl: videoUrl,
      creatorId: user.uid,
      ingredients: ingredients,
      steps: uploadedSteps,
      likes: [],
      savedBy: [],
      tags: tags,
    );

    if (!mounted) return;
    context.read<RecipeBloc>().add(AddNewRecipe(newRecipe));
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MediaCard(
                  photos: photos,
                  video: video,
                  pickPhoto: _pickPhoto,
                  pickVideo: _pickVideo,
                  onRemovePhoto: _removePhoto,
                  onRemoveVideo: _removeVideo,
                ),
                const SizedBox(height: 16),

                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Tiêu đề',
                          ),
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

                TagCard(
                  tags: tags,
                  onUpdateTags: (newTags) {
                    setState(
                      () => tags
                        ..clear()
                        ..addAll(newTags),
                    );
                  },
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
                            title: Text('${i + 1}.'),
                            subtitle: Text(step.description),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  setState(() => steps.removeAt(i)),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(borderRadius: BorderRadius.zero),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(
                    240,
                    144,
                    48,
                    1,
                  ),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _submit,
                child: const Text(
                  'Thêm công thức',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MediaCard extends StatelessWidget {
  final List<XFile> photos;
  final XFile? video;
  final VoidCallback pickPhoto;
  final VoidCallback pickVideo;
  final ValueChanged<XFile> onRemovePhoto;
  final VoidCallback onRemoveVideo;

  const MediaCard({
    super.key,
    required this.photos,
    required this.video,
    required this.pickPhoto,
    required this.pickVideo,
    required this.onRemovePhoto,
    required this.onRemoveVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ảnh công thức',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...photos.map(
                  (p) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(p.path),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => onRemovePhoto(p),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: pickPhoto,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_a_photo, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Video công thức',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            VideoPreview(
              videoFile: video != null ? File(video!.path) : null,
              onPickVideo: pickVideo,
              onRemoveVideo: onRemoveVideo,
            ),
          ],
        ),
      ),
    );
  }
}

class TagCard extends StatelessWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onUpdateTags;

  const TagCard({super.key, required this.tags, required this.onUpdateTags});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thẻ (Tags)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Nhập thẻ, ví dụ: "ăn sáng", "healthy"',
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isEmpty) return;
                      onUpdateTags([...tags, value.trim()]);
                      controller.clear();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (controller.text.trim().isEmpty) return;
                    onUpdateTags([...tags, controller.text.trim()]);
                    controller.clear();
                  },
                ),
              ],
            ),
            Wrap(
              spacing: 6,
              children: tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () =>
                          onUpdateTags(tags.where((t) => t != tag).toList()),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPreview extends StatefulWidget {
  final File? videoFile;
  final VoidCallback onPickVideo;
  final VoidCallback onRemoveVideo;

  const VideoPreview({
    super.key,
    required this.videoFile,
    required this.onPickVideo,
    required this.onRemoveVideo,
  });

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(covariant VideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoFile?.path != widget.videoFile?.path) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    final file = widget.videoFile;
    controller?.dispose();
    controller = null;

    if (file != null && await file.exists()) {
      controller = VideoPlayerController.file(file);
      await controller!.initialize();
      setState(() {});
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return GestureDetector(
        onTap: widget.onPickVideo,
        child: Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.video_library, size: 48, color: Colors.grey),
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: VideoPlayer(controller!),
          ),
        ),
        IconButton(
          iconSize: 48,
          icon: Icon(
            controller!.value.isPlaying
                ? Icons.pause_circle_filled
                : Icons.play_circle_fill,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              controller!.value.isPlaying
                  ? controller!.pause()
                  : controller!.play();
            });
          },
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.change_circle, color: Colors.white),
            onPressed: widget.onPickVideo,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: widget.onRemoveVideo,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              child: const Icon(Icons.delete, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}
