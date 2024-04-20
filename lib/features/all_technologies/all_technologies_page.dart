import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appledocumentationflutter/features/all_technologies/all_technologies_view_model.dart';

class AllTechnologiesPage extends ConsumerStatefulWidget {
  const AllTechnologiesPage({super.key});

  @override
  ConsumerState<AllTechnologiesPage> createState() => _AllTechnologiesPageState();
}

class _AllTechnologiesPageState extends ConsumerState<AllTechnologiesPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.send(const OnAppear());
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(allTechnologiesViewModelProvider);

    switch (state) {
      case Pending():
      case Loading():
        return const Center(
          child: CircularProgressIndicator(),
        );

      case Loaded(technologies: final technologies):
        return Center(
          child: Text('$technologies'),
        );

      case Failed():
        return const Center(
          child: Text('Error'),
        );
    }
  }

  AllTechnologiesViewModel get _viewModel => ref.read(allTechnologiesViewModelProvider.notifier);
}
