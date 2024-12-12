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
import 'package:gap/gap.dart';

import '../data/recipe_data.dart';

class RecipeContentView extends StatelessWidget {
  const RecipeContentView({
    required this.recipe,
    super.key,
  });

  final Recipe recipe;
  static const mobileBreakpoint = 600;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) =>
              constraints.maxWidth < mobileBreakpoint
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _RecipeIngredientsView(recipe),
                          const Gap(16),
                          _RecipeInstructionsView(recipe),
                        ],
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _RecipeIngredientsView(recipe)),
                        const Gap(16),
                        Expanded(child: _RecipeInstructionsView(recipe)),
                      ],
                    ),
        ),
      );
}

class _RecipeIngredientsView extends StatelessWidget {
  const _RecipeIngredientsView(this.recipe);
  final Recipe recipe;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingredients:🍎',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ...[
            for (final ingredient in recipe.ingredients) Text('• $ingredient')
          ],
        ],
      );
}

class _RecipeInstructionsView extends StatelessWidget {
  const _RecipeInstructionsView(this.recipe);
  final Recipe recipe;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructions:🥧',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ...[
            for (final entry in recipe.instructions.asMap().entries)
              Text('${entry.key + 1}. ${entry.value}')
          ],
        ],
      );
}
