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

import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  Settings._();

  static SharedPreferencesWithCache? _prefs;

  static Future<void> init() async {
    assert(_prefs == null, 'call Settings.init() exactly once');
    _prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
  }

  static String get foodPreferences {
    assert(_prefs != null, 'call Settings.init() exactly once');
    return _prefs!.getString('foodPreferences') ?? '';
  }

  static Future<void> setFoodPreferences(String value) async {
    assert(_prefs != null, 'call Settings.init() exactly once');
    await _prefs!.setString('foodPreferences', value);
  }
}
