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
import 'recipe_content_view.dart';

class RecipeView extends StatelessWidget {
  const RecipeView({
    required this.recipe,
    required this.expanded,
    required this.onExpansionChanged,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Recipe recipe;
  final bool expanded;
  final ValueChanged<bool>? onExpansionChanged;
  final Function() onEdit;
  final Function() onDelete;

  @override
  Widget build(BuildContext context) => Card(
        child: Column(
          children: [
            ExpansionTile(
              title: Text(recipe.title),
              subtitle: Text(recipe.description),
              initiallyExpanded: expanded,
              onExpansionChanged: onExpansionChanged,
              children: [
                RecipeContentView(recipe: recipe),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: OverflowBar(
                    spacing: 8,
                    alignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: onDelete,
                        child: const Text('Delete'),
                      ),
                      OutlinedButton(
                        onPressed: onEdit,
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
              ],
            ),
          ],
        ),
      );
}
