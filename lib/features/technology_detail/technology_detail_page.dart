import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
    required this.onTapUrl,
  });

  final TechnologyId id;
  final void Function(TechnologyId) onTapTechnology;
  final void Function(Uri) onTapUrl;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => launchUrlString('https://developer.apple.com${widget.id.value}'),
          ),
        ],
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
        ...switch (section) {
          PrimaryContentSectionContent(:final content) => [
            for (final content in content)
              DocTextView.fromBlock(
                content,
                references: detail.reference,
                onTapLink: _onTapLink,
              ),
          ],

          PrimaryContentSectionDeclarations(:final declarations) => [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
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
          ],

          PrimaryContentSectionParameters(:final parameters) => [
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
                      ),
                    ),
                  ]),
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
            ],
          ],

          PrimaryContentSectionDetails(:final title, :final details) => [
            _heading(title, level: 2, detail: detail),
            const Text.rich(
              TextSpan(
                text: "Name",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Text.rich(
              TextSpan(
                text: details.ideTitle,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            const Text.rich(
              TextSpan(
                text: "Type",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Text.rich(
              TextSpan(
                text: details.value.expand((m) => m.keys).join(", "),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],

          PrimaryContentSectionUnknown(:final kind) => [
            Text("Unknown section kind: $kind"),
          ],
        },
      if (detail.primaryContentSections.isNotEmpty) ...[
        const SizedBox(height: 8),
        const Divider(),
      ],
      if (detail.topicSections.isNotEmpty) ...[
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
                  renderType: RefereneceViewRenderType.topic,
                ),
          ],
        ),
      ],
      if (detail.topicSections.isNotEmpty) ...[
        const SizedBox(height: 8),
        const Divider(),
      ],
      if (detail.relationshipsSections.isNotEmpty)
        _heading("Relationships", level: 1, detail: detail),
      for (final section in detail.relationshipsSections) ...[
        _heading(section.title, level: 2, detail: detail),
        for (final identifier in section.identifiers)
          if (detail.reference(identifier) case final reference?) ...[
            _ReferenceWidget(
              reference: reference,
              references: detail.reference,
              onTapLink: _onTapLink,
              renderType: RefereneceViewRenderType.relationship,
            ),
            const SizedBox(height: 8),
          ],
      ],
      if (detail.relationshipsSections.isNotEmpty) ...[
        const SizedBox(height: 8),
        const Divider(),
      ],
      if (detail.seeAlsoSections.isNotEmpty) ...[
        _heading("See Also", level: 1, detail: detail),
      ],
      for (final section in detail.seeAlsoSections) ...[
        _heading(section.title, level: 2, detail: detail),
        for (final identifier in section.identifiers)
          if (detail.reference(identifier) case final reference?) ...[
            _ReferenceWidget(
              reference: reference,
              references: detail.reference,
              onTapLink: _onTapLink,
              renderType: RefereneceViewRenderType.seeAlso,
            ),
            const SizedBox(height: 8),
          ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Failed to load technology detail.\nreason: ${state.exception}'),
      ),
    );
  }

  void _onTapLink(Link link) {
    switch (link) {
      case LinkUrl link:
        widget.onTapUrl(Uri.parse(link.value));

      case LinkTechnology link:
        widget.onTapTechnology(link.id);
    }
  }
}

// MARK: - reference
enum RefereneceViewRenderType {
  topic,
  relationship,
  seeAlso,
}

class _ReferenceWidget extends StatelessWidget {
  const _ReferenceWidget({
    required this.reference,
    required this.references,
    required this.onTapLink,
    required this.renderType,
  });

  final Reference reference;
  final Reference? Function(RefId) references;
  final void Function(Link) onTapLink;
  final RefereneceViewRenderType renderType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return switch (reference) {
      ReferenceTopic(
        :final role,
        :final title,
        :final url,
        :final abstract,
        :final fragments,
        :final conformance,
      ) =>
        () {
          final attributes = const DocTextAttributes().copyWith(
            link: Link.technology(url),
          );

          final icon = _icon(role);

          if (renderType == RefereneceViewRenderType.relationship) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                if (conformance case final conformance?)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: DocTextView.fromInline(
                      conformance.conformancePrefix +
                          [const InlineContent.text(text: ' ')] +
                          conformance.constraints,
                      references: references,
                      onTapLink: onTapLink,
                    ),
                  ),
              ],
            );
          }

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
                              DocTextBlock.paragraph([(title, attributes)]),
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
        }(),

      ReferenceLink(:final title, :final url) => () {
        return Text.rich(
          TextSpan(
            text: title,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.primary,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                onTapLink(Link.technologyOrUrl(url));
              },
          ),
        );
      }(),

      ReferenceImage(:final variants) => () {
        return Text("data: $variants");
      }(),

      ReferenceSection(:final identifier, :final title, :final kind, :final role, :final url) =>
        () {
          return Text("data: $identifier, $title, $kind, $role, $url");
        }(),

      ReferenceUnknown(:final identifier, :final type) => () {
        return Text("data: $identifier, $type");
      }(),
    };
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

Widget _richTextFromFragments({
  required BuildContext context,
  required List<Fragment> fragments,
  required Reference? Function(RefId) references,
  void Function()? onTap,
  void Function(Link)? onTapLink,
}) {
  final theme = Theme.of(context);

  return Text.rich(
    TextSpan(
      children: [
        for (final fragment in fragments)
          switch (fragment) {
            FragmentAttribute(:final text) => TextSpan(text: text),
            FragmentKeyword(:final text) => TextSpan(text: text),
            FragmentText(:final text) => TextSpan(text: text),
            FragmentLabel(:final text) => TextSpan(text: text),
            FragmentNumber(:final text) => TextSpan(text: text),
            FragmentGenericParameter(:final text) => TextSpan(text: text),
            FragmentInternalParam(:final text) => TextSpan(text: text),
            FragmentExternalParam(:final text) => TextSpan(text: text),

            FragmentIdentifier(:final text) => TextSpan(
              text: text,
              style: TextStyle(
                color: onTap != null ? theme.colorScheme.primary : null,
              ),
              recognizer: onTap != null ? (TapGestureRecognizer()..onTap = onTap) : null,
            ),

            FragmentTypeIdentifier(:final text, :final identifier) => () {
              final ref = identifier != null ? references(identifier) : null;
              final link = switch (ref) {
                ReferenceTopic(:final url) => Link.technology(url),
                ReferenceLink(:final url) => Link.technologyOrUrl(url),
                _ => null,
              };

              return TextSpan(
                text: text,
                style: TextStyle(
                  color: onTapLink != null && link != null ? theme.colorScheme.primary : null,
                ),
                recognizer: onTapLink != null && link != null
                    ? (TapGestureRecognizer()..onTap = () => onTapLink(link))
                    : null,
              );
            }(),
          },
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
