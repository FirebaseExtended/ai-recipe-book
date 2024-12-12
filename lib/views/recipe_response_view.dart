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

// json access
// ignore_for_file: avoid_dynamic_calls

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gap/gap.dart';

import '../data/recipe_data.dart';
import '../data/recipe_repository.dart';
import 'recipe_content_view.dart';

class RecipeResponseView extends StatelessWidget {
  const RecipeResponseView({
    required this.repository,
    required this.response,
    super.key,
  });

  final RecipeRepository repository;
  final String response;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    try {
      final map = jsonDecode(response);
      final recipesWithText = map['recipes'] as List<dynamic>;
      final finalText = map['text'] as String;

      for (final recipeWithText in recipesWithText) {
        // extract the text before the recipe
        final text = recipeWithText['text'] as String;
        if (text.isNotEmpty) children.add(MarkdownBody(data: text));

        // extract the recipe
        final json = recipeWithText['recipe'] as Map<String, dynamic>;
        final recipe = Recipe.fromJson(json);
        children.add(const Gap(16));
        children.add(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipe.title, style: Theme.of(context).textTheme.titleLarge),
            Text(recipe.description),
            RecipeContentView(recipe: recipe),
          ],
        ));

        // add a button to add the recipe to the list
        children.add(const Gap(16));
        children.add(OutlinedButton(
          onPressed: () => unawaited(repository.addNewRecipe(recipe)),
          child: const Text('Add Recipe'),
        ));
        children.add(const Gap(16));
      }

      // add the remaining text
      if (finalText.isNotEmpty) children.add(MarkdownBody(data: finalText));
    }
    // want to catch everything
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      children.add(Text('Error: $e'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
