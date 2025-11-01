import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../data/models/recipe_step.dart';
import '../widgets/zoomable_image_screen.dart';

class RecipeDetailPage extends StatelessWidget {
  final RecipeEntity recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  void _openZoomableImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ZoomableImageScreen(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text("Chi tiết công thức"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.photoUrls.isNotEmpty)
              GestureDetector(
                onTap: () => _openZoomableImage(context, recipe.photoUrls.first),
                child: Hero(
                  tag: recipe.photoUrls.first,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: Image.network(
                      recipe.photoUrls.first,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    recipe.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.restaurant_menu, color: Colors.deepOrange),
                  const SizedBox(width: 8),
                  Text(
                    'Nguyên liệu',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: recipe.ingredients.map((ing) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.circle, size: 6, color: Colors.orangeAccent),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                ing,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.black87,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.format_list_numbered_rounded,
                      color: Colors.deepOrange),
                  const SizedBox(width: 8),
                  Text(
                    'Các bước thực hiện',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: recipe.steps.asMap().entries.map((entry) {
                  final i = entry.key;
                  final RecipeStep step = entry.value;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    Colors.deepOrange.withOpacity(0.15),
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Bước ${i + 1}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            step.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                          if (step.photoUrl != null &&
                              step.photoUrl!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: GestureDetector(
                                onTap: () =>
                                    _openZoomableImage(context, step.photoUrl!),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: step.photoUrl!.startsWith('http')
                                      ? Image.network(step.photoUrl!)
                                      : Image.file(File(step.photoUrl!)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
