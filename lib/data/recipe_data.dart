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

import 'dart:convert';

import 'package:uuid/uuid.dart';

class Recipe {
  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    this.tags = const [],
    this.notes = '',
  });

  Recipe.empty(String id)
      : this(
          id: id,
          title: '',
          description: '',
          ingredients: [],
          instructions: [],
          tags: [],
          notes: '',
        );

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'] ?? const Uuid().v4(),
        title: json['title'],
        description: json['description'],
        ingredients: List<String>.from(json['ingredients']),
        instructions: List<String>.from(json['instructions']),
        tags: json['tags'] == null ? [] : List<String>.from(json['tags']),
        notes: json['notes'] ?? '',
      );

  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> tags;
  final String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'ingredients': ingredients,
        'instructions': instructions,
        'tags': tags,
        'notes': notes,
      };

  static Future<List<Recipe>> loadFrom(String json) async {
    final jsonList = jsonDecode(json) as List;
    return [for (final json in jsonList) Recipe.fromJson(json)];
  }

  @override
  String toString() => '''
# $title
$description

## Ingredients
${ingredients.join('\n')}

## Instructions
${instructions.join('\n')}
''';
}
