// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/recipe_data.dart';
import '../data/recipe_repository.dart';
import 'recipe_view.dart';

class RecipeListView extends StatefulWidget {
  const RecipeListView({
    required this.repository,
    required this.searchText,
    super.key,
  });

  final RecipeRepository repository;
  final String searchText;

  @override
  _RecipeListViewState createState() => _RecipeListViewState();
}

class _RecipeListViewState extends State<RecipeListView> {
  final _expanded = <String, bool>{};

  Iterable<Recipe> _filteredRecipes(Iterable<Recipe> recipes) => recipes
      .where((recipe) =>
          recipe.title
              .toLowerCase()
              .contains(widget.searchText.toLowerCase()) ||
          recipe.description
              .toLowerCase()
              .contains(widget.searchText.toLowerCase()) ||
          recipe.tags.any((tag) =>
              tag.toLowerCase().contains(widget.searchText.toLowerCase())))
      .toList()
    ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: widget.repository,
        builder: (context, child) => ListView(
          children: [
            for (final recipe in _filteredRecipes(widget.repository.recipes))
              RecipeView(
                key: ValueKey(recipe.id),
                recipe: recipe,
                expanded: _expanded[recipe.id] ?? false,
                onExpansionChanged: (expanded) =>
                    _onExpand(recipe.id, expanded),
                onEdit: () => _onEdit(recipe),
                onDelete: () async => _onDelete(recipe),
              ),
          ],
        ),
      );

  void _onExpand(String recipeId, bool expanded) =>
      _expanded[recipeId] = expanded;

  void _onEdit(Recipe recipe) => context.goNamed(
        'edit',
        pathParameters: {'recipe': recipe.id},
      );

  Future<void> _onDelete(Recipe recipe) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text(
          'Are you sure you want to delete the recipe "${recipe.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete ?? false) {
      await widget.repository.deleteRecipe(recipe);
    }
  }
}
