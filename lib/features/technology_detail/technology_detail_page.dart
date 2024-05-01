import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appledocumentationflutter/entities/technology_detail.dart';
import 'package:appledocumentationflutter/entities/value_object/ref_id.dart';
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
      padding: const EdgeInsets.all(16),
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
        const Divider(),
        const SizedBox(height: 24),
        _heading("Topics", level: 2, detail: detail),
      ],
      for (final section in detail.topicSections) ...[
        Container(
          padding: const EdgeInsets.only(top: 12),
          child: _heading(section.title, level: 3, detail: detail),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final identifier in section.identifiers)
              if (detail.reference(identifier) case final reference?)
                _ReferenceWidget(
                  reference: reference,
                  references: detail.reference,
                ),
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

  Widget _failed(Failed state) {
    return const Center(
      child: Text('Failed to load technology detail'),
    );
  }
}

// MARK: - reference
class _ReferenceWidget extends StatelessWidget {
  const _ReferenceWidget({
    required this.reference,
    required this.references,
  });

  final Reference reference;
  final Reference? Function(RefId) references;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return reference.when(
      topic: (kind, role, title, url, images, abstract, fragments, deprecated) {
        final attributes = const DocTextAttributes().copyWith(
          link: url.value,
        );

        final icon = _icon(role);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fragments.isNotEmpty) ...[
              _richTextFromFragments(
                context: context,
                fragments: fragments,
                link: url.value,
              ),
            ] else if (icon == null) ...[
              Text.rich(
                TextSpan(
                  text: title,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.primary,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      debugPrint('link: ${url.value}');
                    },
                ),
              ),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Transform.translate(
                  offset: const Offset(0, 4),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.secondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (icon != null)
                        DocTextView(
                          [
                            DocTextBlock.paragraph([(title, attributes)])
                          ],
                          references: references,
                        ),
                      DocTextView.fromInline(
                        abstract,
                        references: references,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
      link: (String title, String url) {
        return Text(title);
      },
      image: (variants) {
        return Text("data: $variants");
      },
      unknown: (identifier, type) {
        return Text("data: $identifier, $type");
      },
    );
  }

  IconData? _icon(Role? role) {
    if (role == Role.article) {
      return Icons.article_outlined;
    } else if (role == Role.collectionGroup) {
      return Icons.list;
    } else if (role == Role.sampleCode) {
      return Icons.data_object;
    } else {
      return null;
    }
  }

  Widget _richTextFromFragments({
    required BuildContext context,
    required List<Fragment> fragments,
    required String? link,
  }) {
    final theme = Theme.of(context);

    return Text.rich(
      TextSpan(
        children: [
          for (final fragment in fragments)
            fragment.when(
              keyword: (text) => TextSpan(
                text: text,
              ),
              text: (text) => TextSpan(text: text),
              label: (text) => TextSpan(
                text: text,
              ),
              identifier: (text) => TextSpan(
                text: text,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                ),
                recognizer: link != null
                    ? (TapGestureRecognizer()
                      ..onTap = () {
                        debugPrint('link: $link');
                      })
                    : null,
              ),
              typeIdentifier: (text, preciseIdentifier) => TextSpan(text: text),
              genericParameter: (text) => TextSpan(text: text),
              externalParam: (text) => TextSpan(text: text),
            ),
        ],
        style: TextStyle(
          fontSize: 16,
          fontFeatures: const [
            FontFeature.tabularFigures(),
          ],
          color: theme.colorScheme.secondary,
        ),
      ),
    );
  }
}
