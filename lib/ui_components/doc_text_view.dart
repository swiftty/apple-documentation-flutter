import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:appledocumentationflutter/entities/value_object/ref_id.dart';
import 'package:appledocumentationflutter/entities/value_object/reference.dart';
import 'package:appledocumentationflutter/entities/value_object/technology_id.dart';
import 'package:appledocumentationflutter/entities/value_object/text_content.dart';

part 'doc_text_view.freezed.dart';

@freezed
sealed class DocTextBlock with _$DocTextBlock {
  const factory DocTextBlock.paragraph(
    List<(String, DocTextAttributes)> contents,
  ) = _Paragraph;

  const factory DocTextBlock.heading(
    List<(String, DocTextAttributes)> contents, {
    required int level,
    String? anchor,
  }) = _Heading;

  const factory DocTextBlock.indent({
    required int level,
    required List<DocTextBlock> content,
  }) = _Indent;

  const factory DocTextBlock.image(
    List<ImageVariant> variants, {
    @Default(null) ImageMetadata? metadata,
    @Default(false) bool rounded,
  }) = _Image;

  const factory DocTextBlock.aside({
    required List<DocTextBlock> contents,
    required String? name,
    required String style,
  }) = _Aside;

  const factory DocTextBlock.unorderedList({
    required List<DocTextBlock> items,
  }) = _UnorderedList;

  const factory DocTextBlock.orderedList({
    required List<DocTextBlock> items,
  }) = _OrderedList;

  const factory DocTextBlock.codeListing({
    required List<String> code,
    required String syntax,
  }) = _CodeListing;

  const factory DocTextBlock.row({
    required int numberOfColumns,
    required List<DocTextBlock> columns,
  }) = _Row;

  const factory DocTextBlock.card({
    required String? url,
    required List<DocTextBlock> contents,
  }) = _Card;
}

@freezed
sealed class Link with _$Link {
  const factory Link.url(
    String value,
  ) = _Url;

  const factory Link.technology(
    TechnologyId id,
  ) = _Technology;

  factory Link.technologyOrUrl(
    String value,
  ) {
    if (value.startsWith('http')) {
      return Link.url(value);
    } else {
      return Link.technology(TechnologyId(value));
    }
  }
}

@freezed
class DocTextAttributes with _$DocTextAttributes {
  const factory DocTextAttributes({
    @Default(16) double fontSize,
    @Default(false) bool bold,
    @Default(false) bool italic,
    @Default(false) bool underline,
    @Default(false) bool monospaced,
    @Default(null) Link? link,
  }) = _DocTextAttributes;
}

class DocTextView extends StatelessWidget {
  const DocTextView(
    this.textBlocks, {
    required this.references,
    this.attributes = const DocTextAttributes(),
    required this.onTapLink,
    super.key,
  });

  factory DocTextView.fromBlock(
    BlockContent blockContent, {
    required Reference? Function(RefId) references,
    DocTextAttributes attributes = const DocTextAttributes(),
    required void Function(Link) onTapLink,
    Key? key,
  }) {
    final builder = _TextBlockBuilder();
    builder.insertBlock(blockContent, attributes: attributes, references: references);

    return DocTextView(
      builder.build(),
      references: references,
      attributes: attributes,
      onTapLink: onTapLink,
      key: key,
    );
  }

  factory DocTextView.fromInline(
    List<InlineContent> inlineContent, {
    required Reference? Function(RefId) references,
    DocTextAttributes attributes = const DocTextAttributes(),
    required void Function(Link) onTapLink,
    Key? key,
  }) {
    final builder = _TextBlockBuilder();
    for (final content in inlineContent) {
      builder.insertInline(content, attributes: attributes, references: references);
    }

    return DocTextView(
      builder.build(),
      references: references,
      attributes: attributes,
      onTapLink: onTapLink,
      key: key,
    );
  }

  final List<DocTextBlock> textBlocks;
  final DocTextAttributes attributes;
  final Reference? Function(RefId) references;
  final void Function(Link) onTapLink;

  @override
  Widget build(BuildContext context) {
    return _render(context, textBlocks);
  }

  Widget _renderText(BuildContext context, List<(String, DocTextAttributes)> contents) {
    final theme = Theme.of(context);

    return Text.rich(
      TextSpan(children: [
        for (final (text, attributes) in contents)
          TextSpan(
            text: text,
            style: TextStyle(
              fontSize: attributes.fontSize,
              fontWeight: attributes.bold ? FontWeight.bold : null,
              fontStyle: attributes.italic ? FontStyle.italic : null,
              decoration: attributes.underline ? TextDecoration.underline : null,
              color: attributes.link != null ? theme.colorScheme.primary : null,
              fontFeatures: [
                if (attributes.monospaced) const FontFeature.tabularFigures(),
              ],
            ),
            recognizer: attributes.link != null
                ? (TapGestureRecognizer()
                  ..onTap = () {
                    onTapLink(attributes.link!);
                  })
                : null,
          ),
      ]),
    );
  }

  Widget _render(BuildContext context, List<DocTextBlock> contents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final content in contents)
          content.when(
            paragraph: (contents) {
              return _renderText(context, contents);
            },
            heading: (contents, level, anchor) {
              return Padding(
                padding: EdgeInsets.only(top: 12 - (level - 1).toDouble() * 2),
                child: _renderText(context, contents),
              );
            },
            indent: (level, content) {
              return Padding(
                padding: EdgeInsets.only(left: 16 * level.toDouble()),
                child: _render(context, content),
              );
            },
            image: (data, metadata, rounded) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _DocImageView(
                        data,
                        metadata: [
                          if (metadata case final metadata?)
                            if (metadata.abstract.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              DocTextView.fromInline(
                                metadata.abstract,
                                attributes: attributes.copyWith(fontSize: attributes.fontSize - 2),
                                references: references,
                                onTapLink: onTapLink,
                              ),
                            ],
                        ],
                        rounded: rounded,
                        attributes: attributes,
                        references: references,
                      ),
                    )
                  ],
                ),
              );
            },
            aside: (contents, name, style) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _DocAsideView(
                  () => _render(context, contents),
                  name: name,
                  style: style,
                  attributes: attributes,
                ),
              );
            },
            unorderedList: (items) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in items) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        _renderText(context, [('• ', attributes.copyWith(bold: true))]),
                        Expanded(child: _render(context, [item])),
                      ],
                    ),
                  ],
                ],
              );
            },
            orderedList: (items) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (index, item) in items.indexed) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        _renderText(context, [('${index + 1}. ', attributes.copyWith(bold: true))]),
                        Expanded(child: _render(context, [item])),
                      ],
                    ),
                  ],
                ],
              );
            },
            codeListing: (code, syntax) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _DocCodeView(code, syntax),
              );
            },
            row: (numberOfColumns, columns) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final column in columns) _render(context, [column]),
                  ],
                ),
              );
            },
            card: (url, contents) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _DocCardView(
                  child: _render(context, contents),
                  onTap: () {
                    debugPrint('card: $url');
                  },
                ),
              );
            },
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// MARK: - components
class _DocImageView extends StatelessWidget {
  const _DocImageView(
    this.variants, {
    this.metadata = const [],
    this.rounded = false,
    required this.attributes,
    required this.references,
  });

  final List<ImageVariant> variants;
  final List<Widget> metadata;
  final bool rounded;
  final DocTextAttributes attributes;
  final Reference? Function(RefId) references;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(rounded ? 12 : 0),
          ),
          child: Image.network(
            _findUrl(context) ?? variants.first.url,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              //restRequestSymbol
              return _baseBackground(context);
            },
            errorBuilder: (context, error, stackTrace) {
              return _baseBackground(context);
            },
          ),
        ),
        ...metadata,
      ],
    );
  }

  String? _findUrl(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    for (final variant in variants) {
      for (final trait in variant.traits) {
        if (trait == 'dark' && brightness == Brightness.dark) {
          return variant.url;
        }
        if (trait == 'light' && brightness == Brightness.light) {
          return variant.url;
        }
      }
    }
    return null;
  }

  Widget _baseBackground(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16.0 / 9.0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _DocAsideView extends StatelessWidget {
  const _DocAsideView(
    this.content, {
    required this.name,
    required this.style,
    required this.attributes,
  });

  final Widget Function() content;
  final String? name;
  final String style;
  final DocTextAttributes attributes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (foreground, background) =
        _color(context) ?? (theme.colorScheme.primary, theme.colorScheme.secondary);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background.withOpacity(0.1),
        border: Border.all(
          color: background,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (name case final name?) ...[
            Text(
              name,
              style: TextStyle(
                color: foreground,
                fontSize: attributes.fontSize + 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
          ],
          content(),
        ],
      ),
    );
  }

  (Color foreground, Color background)? _color(BuildContext context) {
    final theme = Theme.of(context);

    if (style == 'warning') {
      return (theme.colorScheme.error, theme.colorScheme.errorContainer);
    } else if (style == 'important') {
      return (Colors.orange, Colors.orange);
    }
    return null;
  }
}

class _DocCodeView extends StatelessWidget {
  const _DocCodeView(this.code, this.syntax);

  final List<String> code;
  final String syntax;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.1),
        border: Border.all(
          color: theme.colorScheme.secondary,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in code)
            Text(
              line,
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontFeatures: const [
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DocCardView extends StatefulWidget {
  const _DocCardView({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final void Function()? onTap;

  @override
  State<StatefulWidget> createState() => _DocCardViewState();
}

class _DocCardViewState extends State<_DocCardView> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() {
        _scale = 1.02;
      }),
      onTapUp: (_) => setState(() {
        _scale = 1.0;
      }),
      onTapCancel: () => setState(() {
        _scale = 1.0;
      }),
      behavior: HitTestBehavior.translucent,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}

// MARK: - builder
class _TextBlockBuilder {
  final _cursor = <(String, DocTextAttributes)>[];
  final _contents = <DocTextBlock>[];

  void _insertCursor(String text, DocTextAttributes attributes) {
    _cursor.add((text, attributes));
  }

  void _insertContent(DocTextBlock content) {
    _commitIfNeeded();
    _contents.add(content);
  }

  void _commitIfNeeded() {
    if (_cursor.isNotEmpty) {
      _contents.add(DocTextBlock.paragraph([..._cursor]));
      _cursor.clear();
    }
  }

  void insertBlock(
    BlockContent blockContent, {
    required DocTextAttributes attributes,
    required Reference? Function(RefId) references,
  }) {
    blockContent.when(
      heading: (text, level, anchor) {
        final newAttributes = attributes.copyWith(
          fontSize: attributes.fontSize + 12 - level * 2,
          bold: true,
        );
        _insertContent(DocTextBlock.heading(
          [(text, newAttributes)],
          level: level,
          anchor: anchor,
        ));
      },
      paragraph: (inlineContent) {
        for (final content in inlineContent) {
          insertInline(content, attributes: attributes, references: references);
        }
      },
      links: (items, style) {
        for (final item in items) {
          if (references(item) case final reference?) {
            _insertReference(reference, attributes: attributes, references: references);
          }
        }
      },
      unorderedList: (items) {
        final builder = _TextBlockBuilder();
        for (final item in items) {
          for (final content in item.content) {
            builder.insertBlock(content, attributes: attributes, references: references);
          }
        }
        _insertContent(DocTextBlock.unorderedList(items: builder.build()));
      },
      orderedList: (items) {
        final builder = _TextBlockBuilder();
        for (final item in items) {
          for (final content in item.content) {
            builder.insertBlock(content, attributes: attributes, references: references);
          }
        }
        _insertContent(DocTextBlock.orderedList(items: builder.build()));
      },
      termList: (items) {
        for (final item in items) {
          insertBlock(
            BlockContent.paragraph(item.term.inlineContent),
            attributes: attributes,
            references: references,
          );

          final builder = _TextBlockBuilder();
          for (final content in item.definition.content) {
            builder.insertBlock(content, attributes: attributes, references: references);
          }
          _insertContent(DocTextBlock.indent(level: 1, content: builder.build()));
        }
      },
      codeListing: (code, syntax) {
        _insertContent(DocTextBlock.codeListing(code: code, syntax: syntax));
      },
      aside: (content, style, name) {
        final builder = _TextBlockBuilder();
        for (final content in content) {
          builder.insertBlock(content, attributes: attributes, references: references);
        }
        _insertContent(DocTextBlock.aside(contents: builder.build(), name: name, style: style));
      },
      row: (numberOfColumns, columns) {
        final newColumns = columns.expand((column) {
          final builder = _TextBlockBuilder();
          for (final content in column.content) {
            builder.insertBlock(content, attributes: attributes, references: references);
          }
          return builder.build();
        }).toList();
        _insertContent(DocTextBlock.row(numberOfColumns: numberOfColumns, columns: newColumns));
      },
    );
    _commitIfNeeded();
  }

  void insertInline(
    InlineContent inlineContent, {
    required DocTextAttributes attributes,
    required Reference? Function(RefId) references,
  }) {
    inlineContent.when(
      text: (text) {
        _insertCursor(text, attributes);
      },
      emphasis: (inlineContent) {
        final newAttributes = attributes.copyWith(italic: true);
        for (final content in inlineContent) {
          insertInline(content, attributes: newAttributes, references: references);
        }
      },
      codeVoice: (code) {
        _insertCursor(code, attributes.copyWith(monospaced: true));
      },
      reference: (identifier, _) {
        if (references(identifier) case final ref?) {
          _insertReference(ref, attributes: attributes, references: references);
        }
      },
      image: (identifier, metadata) {
        final ref = references(identifier);
        if (ref is ReferenceImage) {
          _insertContent(DocTextBlock.image(ref.variants, metadata: metadata));
        }
      },
      unknown: (type) {
        _insertCursor('unknown: $type', attributes);
      },
    );
  }

  void _insertReference(
    Reference reference, {
    required DocTextAttributes attributes,
    required Reference? Function(RefId) references,
  }) {
    reference.when(
      topic: (kind, role, title, url, images, abstract, fragments, deprecated) {
        final newAttributes = attributes.copyWith(
          link: url.value.startsWith('http') ? Link.url(url.value) : Link.technology(url),
        );

        if (role == Role.sampleCode) {
          final builder = _TextBlockBuilder();
          for (final image in images) {
            if (references(image.identifier) case final ref?) {
              if (ref is ReferenceImage) {
                builder._insertContent(DocTextBlock.image(ref.variants, rounded: true));
              }
            }
          }
          if (title.isNotEmpty) {
            final newAttributes = attributes.copyWith(
              fontSize: attributes.fontSize + 2,
              bold: true,
            );
            builder._insertContent(DocTextBlock.heading([(title, newAttributes)], level: 6));
          }
          for (final abstract in abstract) {
            builder.insertInline(abstract, attributes: attributes, references: references);
          }
          builder._commitIfNeeded();
          builder._insertCursor('View sample code >', newAttributes);

          _insertContent(DocTextBlock.card(url: url.value, contents: builder.build()));
        } else {
          _insertCursor(title, newAttributes);
        }
      },
      link: (title, url) {
        final newAttributes = attributes.copyWith(
          link: Link.url(url),
        );
        _insertCursor(title, newAttributes);
      },
      image: (variants) {
        _insertContent(DocTextBlock.image(variants));
      },
      unknown: (id, type) {
        _insertCursor('unknown: $type', attributes);
      },
    );
  }

  List<DocTextBlock> build() {
    _commitIfNeeded();
    return _contents;
  }
}
