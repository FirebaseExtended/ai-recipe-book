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

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:future_builder_ex/future_builder_ex.dart';
import 'package:go_router/go_router.dart';

import '../data/recipe_repository.dart';
import '../data/settings.dart';
import '../login_info.dart';
import '../views/recipe_list_view.dart';
import '../views/recipe_response_view.dart';
import '../views/search_box.dart';
import '../views/settings_drawer.dart';
import 'split_or_tabs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String _searchText = '';

  late LlmProvider _provider = _createProvider();

  // create a new provider with the given history and the current settings
  LlmProvider _createProvider([List<ChatMessage>? history]) => VertexProvider(
        history: history,
        generativeModel: FirebaseVertexAI.instance.generativeModel(
          model: 'gemini-1.5-flash',
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            responseSchema: Schema(
              SchemaType.object,
              properties: {
                'recipes': Schema(
                  SchemaType.array,
                  items: Schema(
                    SchemaType.object,
                    properties: {
                      'text': Schema(SchemaType.string),
                      'recipe': Schema(
                        SchemaType.object,
                        properties: {
                          'title': Schema(SchemaType.string),
                          'description': Schema(SchemaType.string),
                          'ingredients': Schema(
                            SchemaType.array,
                            items: Schema(SchemaType.string),
                          ),
                          'instructions': Schema(
                            SchemaType.array,
                            items: Schema(SchemaType.string),
                          ),
                        },
                      ),
                    },
                  ),
                ),
                'text': Schema(SchemaType.string),
              },
            ),
          ),
          systemInstruction: Content.system(
            '''
You are a helpful assistant that generates recipes based on the ingredients and 
instructions provided as well as my food preferences, which are as follows:
${Settings.foodPreferences.isEmpty ? "I don't have any food preferences" : Settings.foodPreferences}

You should keep things casual and friendly. You may generate multiple recipes in
a single response, but only if asked. Generate each response in JSON format
with the following schema, including one or more "text" and "recipe" pairs as
well as any trailing text commentary you care to provide:

{
  "recipes": [
    {
      "text": "Any commentary you care to provide about the recipe.",
      "recipe":
      {
        "title": "Recipe Title",
        "description": "Recipe Description",
        "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"],
        "instructions": ["Instruction 1", "Instruction 2", "Instruction 3"]
      }
    }
  ],
  "text": "any final commentary you care to provide",
}
''',
          ),
        ),
      );

  final _repositoryFuture = RecipeRepository.forCurrentUser;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Vertex AI Cookbook'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout: ${LoginInfo.instance.displayName!}',
              onPressed: () async => LoginInfo.instance.logout(),
            ),
            IconButton(
              onPressed: _onAdd,
              tooltip: 'Add Recipe',
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        drawer: Builder(
          builder: (context) => SettingsDrawer(onSave: _onSettingsSave),
        ),
        body: FutureBuilderEx<RecipeRepository>(
          future: _repositoryFuture,
          builder: (context, repository) => SplitOrTabs(
            tabs: const [
              Tab(text: 'Recipes'),
              Tab(text: 'Chat'),
            ],
            children: [
              Column(
                children: [
                  SearchBox(onSearchChanged: _updateSearchText),
                  Expanded(
                    child: RecipeListView(
                      searchText: _searchText,
                      repository: repository!,
                    ),
                  ),
                ],
              ),
              LlmChatView(
                provider: _provider,
                responseBuilder: (context, response) => RecipeResponseView(
                  repository: repository,
                  response: response,
                ),
              ),
            ],
          ),
        ),
      );

  void _updateSearchText(String text) => setState(() => _searchText = text);

  void _onAdd() => context.goNamed(
        'edit',
        pathParameters: {'recipe': RecipeRepository.newRecipeID},
      );

  void _onSettingsSave() => setState(() {
        // move the history over from the old provider to the new one
        final history = _provider.history.toList();
        _provider = _createProvider(history);
      });
}
