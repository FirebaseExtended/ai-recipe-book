# Vertex AI Cookbook

The vertex_ai_cookbook project is a sample app written to showcase the power of Firebase Vertex AI. It's written in Flutter and leverages [the Flutter AI Toolkit](https://pub.dev/packages/flutter_ai_toolkit) as well as [Firebase Auth](https://pub.dev/packages/firebase_auth) and [Cloud Firestore](https://pub.dev/packages/cloud_firestore). At it's core, it relies on [Vertex AI for Firebase](https://pub.dev/packages/firebase_vertexai) for all of it's generative AI features.

# Features

Once you've logged in using your Google account, the cookbook app is split into two sections, one for recipes and one for a chat with the Vertex AI LLM. Those two sections are either side-by-side for desktop form factors:

TODO: intro-split.png

Or they're on individual tabs for mobile form factors:

TODO: intro-tabbed.png

## Stored in Cloud Firestore

When logging in as a new user, you'll get a set of default recipes for you to play around with. All of those recipes are stored in Cloud Firestore for you between sessions. You're free to explore them by simply expanding them to see their ingredients and instructions:

TODO: intro-expanded-recipe.png

These are your recipes, so feel free to add to them, edit them, delete them or search through them as you see fit:

TODO: intro-search.png

If you'd like the Vertex AI LLM to help you generate new recipes, that's what the Chat is for.

## Generating Recipes

The Chat section of the app is tuned to be a recipe generating machine, as you can see in `home_page.dart`:

```dart
...
  final _provider = VertexProvider(
    chatModel: FirebaseVertexAI.instance.generativeModel(
      model: "gemini-1.5-flash",
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      systemInstruction: Content.system('''
You are a helpful assistant that generates recipes based on the ingredients and 
instructions provided as well as my food preferences, which are as follows:
${Settings.foodPreferences.isEmpty ? 'I don\'t have any food preferences' : Settings.foodPreferences}

You should keep things casual and friendly. Feel free to mix in rich text
commentary with the recipes you generate. You may generate multiple recipes in
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
...
```

The call to `FirebaseVertexAI.instance.generativeModel` created an instance of a generative model for use in interacting with the user during a chat session. In addition to it be created using the name of the model (`gemini-1.5-flash` in this case), the `systemInstruction` tells the LLM how to be. In this case, we've asked for "a helpful assistant that generates recipes," which is the theme of this app. With those instructions in place, the chat will produce a recipe at the slightest provocation:

TODO: generate-single.png

Pressing the Add Recipe button drops the recipe directly into your database of recipes. It does this with the `responseBuilder` parameter to [the `LlmChatView` constructor](https://pub.dev/documentation/flutter_ai_toolkit/latest/flutter_ai_toolkit/LlmChatView-class.html). The `LlmChatView` is the main entry point of the Flutter AI Toolkit and allows you to easily drop an AI chat feature into your own Flutter apps, as show in `home_page.dart`:

```dart
...
  LlmChatView(
    provider: _provider,
    responseBuilder: (context, response) => RecipeResponseView(
      repository: repository,
      response: response,
    ),
...
```

By default, the response from the LLM is parsed as Markdown to enable rich text, e.g. headings, bold, etc. that the LLM might provide as part of its response. In this case, we've overridden that default behavior by use of the custom Flutter widget `RecipeResponseView` class, which parses the LLM output as JSON into a typed `Recipe` object and provides the "Add Recipe" button.

That's just one way to hook into the `LlmChatView` for your own apps. Another is to allow the user to fine-tune the LLM with the user's preferences.

## User Preferences
Looking again at the system instructions we provide the LLM, you'll see a spot for user preferences:

```dart
...
  final _provider = VertexProvider(
    chatModel: FirebaseVertexAI.instance.generativeModel(
      model: "gemini-1.5-flash",
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      systemInstruction: Content.system('''
You are a helpful assistant that generates recipes based on the ingredients and 
instructions provided as well as my food preferences, which are as follows:
${Settings.foodPreferences.isEmpty ? 'I don\'t have any food preferences' : Settings.foodPreferences}
```

The `foodPreferences` setting allows the user to set their food preferences via the drawer from the top-left corner of the app:

TODO: user-prefs.png

With that in place, the user can get recipes tailored to their restrictions, likes and dislikes:

TODO: user-prefs-recipe.png

In this case, even though we asked for a recipe that contains ingredients we don't like, the LLM is smart enough to lean on those user preferences to give us something we'll like instead.

## Multi-message Chat
The chat with the LLM isn't got a "one and done" thing; the LLM understands the history of the conversation and allows the user to reference the context built up over multiple messages:

TODO: generate-multi.png

In this way, the user can iterate on a recipe with the LLM until the come up with something that they're happy to add to their cookbook.

## Multimodal Input
The input to the chat isn't just text -- it can also include files and images. For example, here we've uploading a recipe card from my family's old, printed cookbook:

TODO: multi-modal.png

You can also upload files of other types, e.g. text files, PDFs, etc.

And you're not limited to a single file either. For fun, I recommend taking a photo of what you've got in your fridge and another one of what you've got in your cupboard and asking for a recipe made from those ingredients.

## Non-chat Generative AI
You aren't limited to the chat UI to implement features in your app using generative AI. When you press the Add or Edit buttons, you'll be given a dialog with your recipe details and a button simply called "Magic" at the bottom:

TODO: magic-button.png

This button creates a Firebase AI Vertex model just like the one used to initial the `LlmChatView` but does so simply to ask for modifications to the existing recipe using the user's -- potentially changing -- food preferences, as you can see in the `edit_recipe_page.dart` file:

```dart
  final _provider = VertexProvider(
    chatModel: FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-1.5-flash',
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      systemInstruction: Content.system('''
You are a helpful assistant that generates recipes based on the ingredients and 
instructions provided as well as my food preferences, which are as follows:
${Settings.foodPreferences.isEmpty ? 'I don\'t have any food preferences' : Settings.foodPreferences}
...'''),
    ),
  );

  ...

  Future<void> _onMagic() async {
    final stream = _provider.sendMessageStream(
      'Generate a modified version of this recipe based on my food preferences: '
      '${_ingredientsController.text}\n\n${_instructionsController.text}',
    );
    var response = await stream.join();

    try {
      final json = jsonDecode(response);
      final modifications = json['modifications'];
      final recipe = Recipe.fromJson(json['recipe']);

      if (!context.mounted) return;
      final accept = await showDialog<bool>(/* show the modifications */);
      ...
    }
  }
```

The `VertexProvider` class is provided by the Flutter AI Toolkit to allow for a number of LLM providers to work with chat via [the common `LlmProvider` interface](https://pub.dev/documentation/flutter_ai_toolkit/latest/flutter_ai_toolkit/LlmProvider-class.html). In the case, we're using the same method on the provider that the `LlmChatView` would call to send a prompt to the underlying LLM, the `sendMessageStream` method.

In this case, instead of the user providing the prompt, the app is, based on the current information in the recipe form. Since LLMs can stream their responses, we gather all of that up into a single response, parse it as JSON and pull out the updated recipe and the list of modifications to show to the user for their approval:

TODO: magic-button-pushed.png

You can use this same technique in your apps to use the Vertex AI LLM to implement novel features in your app without requiring the use of an actual chat at all.

## Security

The cookbook sample uses Firebase Auth to provide secure access for each user to their own recipes. It's been engineered to work in both development mode and locked down mode via Cloud Firestore security rules (described below).

## Multi-platform

This sample has been tested and workes on all supported Firebase platforms: Android, iOS, web and macOS. The adventurous may want to try the pre-release [`flutterfire_desktop` packages](https://github.com/FirebaseExtended/flutterfire_desktop).

# Getting Started

This sample relies on a Firebase project, which you then initialize in your app. You can learn how to set that up with the steps described in [the Get started with the Gemini API using the Vertex AI in Firebase SDKs docs](https://firebase.google.com/docs/vertex-ai/get-started?platform=flutter).

## Firebase Auth

Once you have your Firebase project in place, you'll need to [configure Firebase Auth with support for Google Sign-In](https://github.com/firebase/FirebaseUI-Flutter/blob/main/docs/firebase-ui-auth/providers/oauth.md#google-sign-in) to enable your users to create new accounts and store their recipes.

## Cloud Firestore

And finally, you'll need to create a Cloud Firestore database to store your users' recipes. The [Create a Cloud Firestore database docs](https://firebase.google.com/docs/firestore/quickstart#create) will show you how to do that.

TODO: README/create-firestore-default-database.png ??

Once you have your database created, you can secure it according to [the Firebase Security Rules docs for Content-owner only access](https://firebase.google.com/docs/rules/basics#content-owner_only_access) using rules like these:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{documents=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId
    }
  }
}
```

## Firebase AppCheck

In addition, for maximum security, I recommend configuring your own apps with [Firebase AppCheck](https://firebase.google.com/learn/pathways/firebase-app-check).

# Feedback

Are you having trouble with this app even after it's been configured correctly? Feel free to drop issues or, even better, PRs, in [the vertex_ai_cookbook repo](https://github.com/csells/vertex_ai_cookbook).