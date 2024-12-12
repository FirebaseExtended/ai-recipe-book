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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fua;
import 'package:flutter/foundation.dart';

class LoginInfo extends ChangeNotifier {
  LoginInfo._() : _user = FirebaseAuth.instance.currentUser;
  User? _user;
  User? get user => _user;

  set user(User? user) {
    _user = user;
    notifyListeners();
  }

  static final List<fua.AuthProvider> authProviders = [
    fua.EmailAuthProvider(),
  ];

  static final instance = LoginInfo._();

  String? get displayName => user?.displayName ?? user?.email;

  Future<void> logout() async {
    user = null;
    await FirebaseAuth.instance.signOut();
  }
}
