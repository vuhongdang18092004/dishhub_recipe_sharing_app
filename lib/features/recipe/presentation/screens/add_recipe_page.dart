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

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() => photos.add(picked));
    }
  }

  void _removePhoto(XFile photo) {
    if (mounted) {
      setState(() => photos.remove(photo));
    }
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;

    final tempDir = await getApplicationDocumentsDirectory();
    final savedPath = '${tempDir.path}/${picked.name}';
    await File(picked.path).copy(savedPath);

    if (mounted) {
      setState(() => video = XFile(savedPath));
    }
  }

  void _removeVideo() {
    if (mounted) {
      setState(() => video = null);
    }
  }

  void _addIngredient(String ingredient) {
    if (ingredient.trim().isEmpty) return;
    if (mounted) {
      setState(() => ingredients.add(ingredient.trim()));
    }
  }

  Future<void> _addStepDialog() async {
    final stepDescController = TextEditingController();
    XFile? stepPhoto;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (stepDescController.text.trim().isEmpty) return;
                if (mounted) {
                  setState(() {
                    steps.add(
                      RecipeStep(
                        description: stepDescController.text.trim(),
                        photoUrl: stepPhoto?.path,
                      ),
                    );
                  });
                }
                Navigator.of(context).pop();
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
    if (cloudName == null || uploadPreset == null) {
      debugPrint('Cloudinary configuration missing');
      return null;
    }

    if (!await file.exists()) {
      debugPrint('File does not exist: ${file.path}');
      return null;
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/${isVideo ? 'video' : 'image'}/upload',
    );

    try {
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      debugPrint('Uploading to Cloudinary: ${file.path}');
      final response = await request.send();

      if (response.statusCode == 200) {
        final resBody = await response.stream.bytesToString();
        final data = json.decode(resBody);
        debugPrint('Upload successful: ${data['secure_url']}');
        return data['secure_url'] as String?;
      } else {
        debugPrint('Cloudinary upload failed: ${response.statusCode}');
        final errorBody = await response.stream.bytesToString();
        debugPrint('Error response: $errorBody');
        return null;
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<bool> _validateFiles() async {
    for (var photo in photos) {
      final file = File(photo.path);
      if (!await file.exists()) {
        debugPrint('Photo not found: ${photo.path}');
        return false;
      }
    }

    for (var step in steps) {
      if (step.photoUrl != null) {
        final file = File(step.photoUrl!);
        if (!await file.exists()) {
          debugPrint('Step photo not found: ${step.photoUrl}');
          return false;
        }
      }
    }

    if (video != null) {
      final file = File(video!.path);
      if (!await file.exists()) {
        debugPrint('Video not found: ${video!.path}');
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecipeBloc, RecipeState>(
      listener: (context, state) {
        if (state is RecipeAddedSuccess) {
          _handleRecipeAddedSuccess(context);
        } else if (state is RecipeError) {
          _handleRecipeError(state.message);
        }
      },
      child: PopScope(
        canPop: !_isSubmitting,
        onPopInvoked: (didPop) {
          if (!didPop && _isSubmitting) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đang xử lý, vui lòng đợi...'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
        child: Scaffold(
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
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Mô tả',
                                border: OutlineInputBorder(),
                              ),
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _ingredientController,
                                    decoration: const InputDecoration(
                                      hintText: 'Nhập nguyên liệu',
                                      border: OutlineInputBorder(),
                                    ),
                                    onSubmitted: (value) {
                                      _addIngredient(value);
                                      _ingredientController.clear();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle,
                                    color: Colors.green,
                                  ),
                                  iconSize: 32,
                                  onPressed: () {
                                    _addIngredient(_ingredientController.text);
                                    _ingredientController.clear();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...ingredients.map(
                              (ing) => Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  title: Text(ing),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        setState(() => ingredients.remove(ing)),
                                  ),
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
                                  'Các bước thực hiện',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _addStepDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Thêm bước'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromRGBO(
                                      240,
                                      144,
                                      48,
                                      1,
                                    ),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...steps.asMap().entries.map((entry) {
                              final i = entry.key;
                              final step = entry.value;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color.fromRGBO(
                                      240,
                                      144,
                                      48,
                                      1,
                                    ),
                                    foregroundColor: Colors.white,
                                    child: Text('${i + 1}'),
                                  ),
                                  title: Text(
                                    'Bước ${i + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(step.description),
                                      if (step.photoUrl != null) ...[
                                        const SizedBox(height: 8),
                                        Image.file(
                                          File(step.photoUrl!),
                                          width: 100,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        setState(() => steps.removeAt(i)),
                                  ),
                                ),
                              );
                            }),
                            if (steps.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text(
                                    'Chưa có bước nào được thêm',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),

              Positioned(
                left: 16,
                right: 16,
                bottom: 0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(240, 144, 48, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                    elevation: 4,
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Thêm công thức',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              if (_isSubmitting)
                Container(
                  color: Colors.black54,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting || !mounted) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề và mô tả')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để tạo công thức')),
      );
      return;
    }

    final areFilesValid = await _validateFiles();
    if (!areFilesValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Một số file không tồn tại. Vui lòng chọn lại.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      List<String> photoUrls = [];
      for (var photo in photos) {
        final file = File(photo.path);
        if (await file.exists()) {
          final url = await uploadToCloudinary(file);
          if (url != null) {
            photoUrls.add(url);
            debugPrint('Uploaded photo: $url');
          }
        }
      }

      List<RecipeStep> uploadedSteps = [];
      for (var step in steps) {
        String? stepUrl;
        if (step.photoUrl != null) {
          final file = File(step.photoUrl!);
          if (await file.exists()) {
            stepUrl = await uploadToCloudinary(file);
          }
        }
        uploadedSteps.add(
          RecipeStep(description: step.description, photoUrl: stepUrl),
        );
      }

      String? videoUrl;
      if (video != null) {
        final file = File(video!.path);
        if (await file.exists()) {
          videoUrl = await uploadToCloudinary(file, isVideo: true);
        }
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
        comments: [],
        tags: tags,
      );

      if (mounted) {
        context.read<RecipeBloc>().add(AddNewRecipe(newRecipe));
      }
    } catch (e) {
      debugPrint('Error submitting recipe: $e');
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi thêm công thức: $e')));
      }
    }
  }

  void _handleRecipeAddedSuccess(BuildContext context) {
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _titleController.clear();
      _descriptionController.clear();
      _ingredientController.clear();
      ingredients.clear();
      steps.clear();
      photos.clear();
      tags.clear();
      video = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Công thức đã được thêm thành công!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    });
  }

  void _handleRecipeError(String errorMessage) {
    if (!mounted) return;

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(errorMessage)),
          ],
        ),
        backgroundColor: Colors.red,
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
                          color: Colors.red,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => onRemovePhoto(p),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
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
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, color: Colors.grey, size: 24),
                        SizedBox(height: 4),
                        Text(
                          'Thêm',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thêm các từ khóa để người dùng dễ dàng tìm thấy công thức của bạn',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Nhập thẻ, ví dụ: "ăn sáng", "healthy"',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isEmpty) return;
                      onUpdateTags([...tags, value.trim().toLowerCase()]);
                      controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                  iconSize: 32,
                  onPressed: () {
                    if (controller.text.trim().isEmpty) return;
                    onUpdateTags([
                      ...tags,
                      controller.text.trim().toLowerCase(),
                    ]);
                    controller.clear();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
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
      if (mounted) setState(() {});
    } else {
      if (mounted) setState(() {});
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
            border: Border.all(color: Colors.grey),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Thêm video', style: TextStyle(color: Colors.grey)),
            ],
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
        Container(
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(8),
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: const Icon(Icons.delete, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}
