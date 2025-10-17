import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../data/models/recipe_step.dart';

class RecipeDetailPage extends StatelessWidget {
  final RecipeEntity recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.photoUrls.isNotEmpty)
              Image.network(
                recipe.photoUrls.first,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(recipe.description),
                  const SizedBox(height: 12),
                  const Text(
                    'Nguyên liệu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...recipe.ingredients.map((ing) => Text('• $ing')).toList(),
                  const SizedBox(height: 12),
                  const Text(
                    'Các bước',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...recipe.steps.asMap().entries.map((entry) {
                    final i = entry.key;
                    final RecipeStep step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bước ${i + 1}: ${step.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(step.description),
                          if (step.photoUrl != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: step.photoUrl!.startsWith('http')
                                  ? Image.network(step.photoUrl!)
                                  : Image.file(File(step.photoUrl!)),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
