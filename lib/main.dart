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
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/recipe_repository.dart';
import 'data/settings.dart';
import 'firebase_options.dart'; // from https://firebase.google.com/docs/flutter/setup
import 'login_info.dart';
import 'pages/edit_recipe_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(App());
}

class App extends StatefulWidget {
  App({super.key}) {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      LoginInfo.instance.user = user;
      RecipeRepository.user = user;
    });
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _router = GoRouter(
    routes: [
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            name: 'edit',
            path: 'edit/:recipe',
            builder: (context, state) => EditRecipePage(
              recipeId: state.pathParameters['recipe']!,
            ),
          ),
        ],
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => SignInScreen(
          showAuthActionSwitch: true,
          breakpoint: 600,
          providers: LoginInfo.authProviders,
          showPasswordVisibilityToggle: true,
        ),
      ),
    ],
    redirect: (context, state) {
      final loginLocation = state.namedLocation('login');
      final homeLocation = state.namedLocation('home');
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final loggingIn = state.matchedLocation == loginLocation;

      if (!loggedIn && !loggingIn) return loginLocation;
      if (loggedIn && loggingIn) return homeLocation;
      return null;
    },
    refreshListenable: LoginInfo.instance,
  );

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      );
}
