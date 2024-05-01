import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:appledocumentationflutter/entities/value_object/technology_id.dart';
import 'package:appledocumentationflutter/features/all_technologies/all_technologies_page.dart';
import 'package:appledocumentationflutter/features/technology_detail/technology_detail_page.dart';

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
    GoRoute(
      path: '/detail',
      name: 'technology detail',
      pageBuilder: (context, state) {
        final id = state.uri.queryParameters['id']!;

        return MaterialPage(
          key: state.pageKey,
          child: TechnologyDetailPage(
            id: TechnologyId(id),
            onTapTechnology: (id) {
              context.push('/detail?id=${Uri.encodeComponent(id.value)}');
            },
          ),
        );
      },
    ),
  ],
);
