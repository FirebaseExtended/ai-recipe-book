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

import 'dart:async';

import 'package:flutter/material.dart';

import '../data/settings.dart';

class SettingsDrawer extends StatelessWidget {
  SettingsDrawer({required this.onSave, super.key});
  final VoidCallback onSave;

  final controller = TextEditingController(
    text: Settings.foodPreferences,
  );

  @override
  Widget build(BuildContext context) => Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Food Preferences')),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: controller,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Enter your food preferences...',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: OverflowBar(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    OutlinedButton(
                      child: const Text('Save'),
                      onPressed: () {
                        unawaited(Settings.setFoodPreferences(controller.text));
                        Navigator.of(context).pop();
                        onSave();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
