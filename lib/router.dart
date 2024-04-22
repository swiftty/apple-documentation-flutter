import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:appledocumentationflutter/features/all_technologies/all_technologies_page.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'all technologies',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const AllTechnologiesPage(),
      ),
    ),
  ],
);
