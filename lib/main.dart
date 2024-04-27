import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appledocumentationflutter/data/api_client.dart';
import 'package:appledocumentationflutter/router.dart';
import 'package:appledocumentationflutter/theme.dart';

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
    const theme = MaterialTheme(TextTheme());

    return MaterialApp.router(
      title: 'Apple Docs',
      theme: theme.dark(),
      // router settings
      routerDelegate: goRouter.routerDelegate,
      routeInformationParser: goRouter.routeInformationParser,
      routeInformationProvider: goRouter.routeInformationProvider,
    );
  }
}
