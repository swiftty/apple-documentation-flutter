import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appledocumentationflutter/entities/technology_detail.dart';
import 'package:appledocumentationflutter/entities/value_object/reference.dart';
import 'package:appledocumentationflutter/entities/value_object/technology_id.dart';
import 'package:appledocumentationflutter/entities/value_object/text_content.dart';
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
        title: Column(
          children: [
            const Text('Technology Detail'),
            Text(
              widget.id.value,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
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
          DocTextView.fromBlock(
            content,
            references: detail.reference,
          ),
      ],
      if (detail.topicSections.isNotEmpty) ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: const Divider(),
        ),
        _heading("Tooics", detail: detail),
      ],
      for (final section in detail.topicSections) ...[
        _heading(section.title, level: 2, detail: detail),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final identifier in section.identifiers)
              if (detail.reference(identifier) case final reference?)
                _reference(context, reference, detail: detail)
          ],
        )
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

  Widget _heading(String text, {int level = 1, required TechnologyDetail detail}) {
    return DocTextView.fromBlock(
      BlockContent.heading(text: text, level: level),
      references: detail.reference,
    );
  }

  Widget _reference(BuildContext context, Reference reference, {required TechnologyDetail detail}) {
    final theme = Theme.of(context);

    return reference.when(
      topic: (kind, role, title, url, abstract, deprecated) {
        final attributes = const DocTextAttributes().copyWith(
          link: url.value,
          underline: true,
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Icon(
              Icons.article_outlined,
              color: theme.colorScheme.secondary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DocTextView(
                    [
                      DocTextBlock.paragraph([(title, attributes)])
                    ],
                    references: detail.reference,
                  ),
                  DocTextView.fromInline(
                    abstract,
                    references: detail.reference,
                  ),
                ],
              ),
            ),
          ],
        );
      },
      link: (String title, String url) {
        return Text(title);
      },
      image: (List<ImageVariant> variants) {
        return Text("data: $variants");
      },
      unknown: (identifier, type) {
        return Text("data: $identifier, $type");
      },
    );
  }

  Widget _failed(Failed state) {
    return const Center(
      child: Text('Failed to load technology detail'),
    );
  }
}
