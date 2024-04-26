import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appledocumentationflutter/entities/technology_detail.dart';
import 'package:appledocumentationflutter/entities/value_object/technology_id.dart';
import 'package:appledocumentationflutter/features/technology_detail/technology_detail_view_model.dart';

class TechnologyDetailPage extends ConsumerStatefulWidget {
  const TechnologyDetailPage({super.key, required this.id});

  final TechnologyId id;

  @override
  ConsumerState<TechnologyDetailPage> createState() => _TechnologyDetailPageState();
}

class _TechnologyDetailPageState extends ConsumerState<TechnologyDetailPage> {
  TechnologyDetailViewModel get _viewModel =>
      ref.read(technologyDetailViewModelProvider(id: widget.id).notifier);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.send(const OnAppear());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Technology Detail'),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    final state = ref.watch(technologyDetailViewModelProvider(id: widget.id));

    switch (state) {
      case Pending():
      case Loading():
        return _loading();

      case Loaded(:final technologyDetail):
        return _loaded(technologyDetail);

      case Failed():
        return _failed(state);
    }
  }

  Widget _loading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _loaded(TechnologyDetail detail) {
    return ListView(
      children: _content(detail),
    );
  }

  List<Widget> _content(TechnologyDetail detail) {
    return [
      for (final abstract in detail.abstract)
        abstract.when(
          text: (text) => Text(text),
          reference: (identifier, _) => Text('Reference: ${identifier.value}'),
          unknown: (type) => Text('Unknown type: $type'),
        ),
      for (final section in detail.primaryContentSections)
        for (final content in section.content)
          content.when(
            heading: (text, level, anchor) => Text(text),
            paragraph: (inlineContent) => Text("$inlineContent"),
            links: (items, style) => Text("$items"),
            unorderedList: (items) => Text("$items"),
            termList: (items) => Text("$items"),
            aside: (content, style, name) => Text("$content"),
          ),
    ];
  }

  Widget _failed(Failed state) {
    return const Center(
      child: Text('Failed to load technology detail'),
    );
  }
}
