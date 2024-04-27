import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appledocumentationflutter/entities/technology_detail.dart';
import 'package:appledocumentationflutter/entities/value_object/technology_id.dart';
import 'package:appledocumentationflutter/features/technology_detail/technology_detail_view_model.dart';
import 'package:appledocumentationflutter/ui_components/doc_text_view.dart';

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
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final state = ref.watch(technologyDetailViewModelProvider(id: widget.id));

    switch (state) {
      case Pending():
      case Loading():
        return _loading();

      case Loaded(:final technologyDetail):
        return _loaded(context, technologyDetail);

      case Failed():
        return _failed(state);
    }
  }

  Widget _loading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _loaded(BuildContext context, TechnologyDetail detail) {
    return ListView(
      children: _content(context, detail),
    );
  }

  List<Widget> _content(BuildContext context, TechnologyDetail detail) {
    final theme = Theme.of(context);

    return [
      Text(widget.id.value),
      if (detail.metadata.roleHeading case final haeding?)
        Text(
          haeding,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      Text(
        detail.metadata.title,
        style: theme.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      DocTextView.fromInline(
        detail.abstract,
        references: detail.reference,
      ),
      for (final section in detail.primaryContentSections) ...[
        for (final content in section.content)
          DocTextView(
            content,
            references: detail.reference,
          ),
      ],
      if (detail.relationshipsSections.isNotEmpty)
        const Text(
          "Relationships",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      for (final section in detail.relationshipsSections) ...[
        for (final identifier in section.identifiers)
          if (detail.reference(identifier) case final reference?) Text("data: $reference"),
      ],
    ];
  }

  Widget _failed(Failed state) {
    return const Center(
      child: Text('Failed to load technology detail'),
    );
  }
}
