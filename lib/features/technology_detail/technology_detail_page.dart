import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appledocumentationflutter/entities/technology_detail.dart';
import 'package:appledocumentationflutter/entities/value_object/ref_id.dart';
import 'package:appledocumentationflutter/entities/value_object/reference.dart';
import 'package:appledocumentationflutter/entities/value_object/technology_id.dart';
import 'package:appledocumentationflutter/entities/value_object/text_content.dart';
import 'package:appledocumentationflutter/features/technology_detail/technology_detail_view_model.dart';
import 'package:appledocumentationflutter/ui_components/doc_text_view.dart';

class TechnologyDetailPage extends ConsumerStatefulWidget {
  const TechnologyDetailPage({
    super.key,
    required this.id,
    required this.onTapTechnology,
  });

  final TechnologyId id;
  final void Function(TechnologyId) onTapTechnology;

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
        onTapLink: _onTapLink,
      ),
      for (final section in detail.primaryContentSections)
        ...section.when(
          content: (content) {
            return [
              for (final content in content)
                DocTextView.fromBlock(
                  content,
                  references: detail.reference,
                  onTapLink: _onTapLink,
                ),
            ];
          },
          declarations: (declarations) {
            return [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    for (final declaration in declarations)
                      _richTextFromFragments(
                        context: context,
                        fragments: declaration.tokens,
                        references: detail.reference,
                        onTapLink: _onTapLink,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
            ];
          },
          parameters: (languages, parameters) {
            return [
              _heading('Parameters', level: 2, detail: detail),
              for (final parameter in parameters) ...[
                DocTextView(
                  [
                    DocTextBlock.paragraph([
                      (
                        parameter.name,
                        const DocTextAttributes(
                          fontSize: 18,
                          bold: true,
                          monospaced: true,
                        )
                      )
                    ])
                  ],
                  references: detail.reference,
                  onTapLink: _onTapLink,
                ),
                for (final content in parameter.content)
                  DocTextView.fromBlock(
                    content,
                    references: detail.reference,
                    onTapLink: _onTapLink,
                  ),
              ]
            ];
          },
        ),
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
                  onTapLink: _onTapLink,
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
      onTapLink: _onTapLink,
    );
  }

  Widget _failed(Failed state) {
    return const Center(
      child: Text('Failed to load technology detail'),
    );
  }

  void _onTapLink(Link link) {
    link.when(
      url: (url) => debugPrint(url),
      technology: (id) => widget.onTapTechnology(id),
    );
  }
}

// MARK: - reference
class _ReferenceWidget extends StatelessWidget {
  const _ReferenceWidget({
    required this.reference,
    required this.references,
    required this.onTapLink,
  });

  final Reference reference;
  final Reference? Function(RefId) references;
  final void Function(Link) onTapLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return reference.when(
      topic: (kind, role, title, url, images, abstract, fragments, deprecated) {
        final attributes = const DocTextAttributes().copyWith(
          link: Link.technology(url),
        );

        final icon = _icon(role);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fragments.isNotEmpty) ...[
              _richTextFromFragments(
                context: context,
                fragments: fragments,
                references: references,
                onTap: () => onTapLink(Link.technology(url)),
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
                      onTapLink(Link.technology(url));
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
                          onTapLink: onTapLink,
                        ),
                      DocTextView.fromInline(
                        abstract,
                        references: references,
                        onTapLink: onTapLink,
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
}

Widget _richTextFromFragments(
    {required BuildContext context,
    required List<Fragment> fragments,
    required Reference? Function(RefId) references,
    void Function()? onTap,
    void Function(Link)? onTapLink}) {
  final theme = Theme.of(context);

  return Text.rich(
    TextSpan(
      children: [
        for (final fragment in fragments)
          fragment.when(
            attribute: (text) => TextSpan(
              text: text,
            ),
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
                color: onTap != null ? theme.colorScheme.primary : null,
              ),
              recognizer: onTap != null ? (TapGestureRecognizer()..onTap = onTap) : null,
            ),
            typeIdentifier: (text, preciseIdentifier, identifier) {
              final ref = identifier != null ? references(identifier) : null;
              final link = ref?.maybeMap(
                topic: (value) => Link.technology(value.url),
                link: (value) => Link.technologyOrUrl(value.url),
                orElse: () => null,
              );

              return TextSpan(
                text: text,
                style: TextStyle(
                  color: onTapLink != null && link != null ? theme.colorScheme.primary : null,
                ),
                recognizer: onTapLink != null && link != null
                    ? (TapGestureRecognizer()..onTap = () => onTapLink(link))
                    : null,
              );
            },
            genericParameter: (text) => TextSpan(text: text),
            internalParam: (text) => TextSpan(text: text),
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
