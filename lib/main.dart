import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appledocumentationflutter/data/api_client.dart';
import 'package:appledocumentationflutter/features/root_page.dart';
import 'package:appledocumentationflutter/router.dart';

void main() {
  runApp(ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(ApiClientImpl()),
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Apple Docs',
      theme: ThemeData.dark(),
      // router settings
      routerDelegate: goRouter.routerDelegate,
      routeInformationParser: goRouter.routeInformationParser,
      routeInformationProvider: goRouter.routeInformationProvider,
    );
  }
}
