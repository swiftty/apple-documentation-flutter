import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:appledocumentationflutter/entities/value_object/ref_id.dart';
import 'package:appledocumentationflutter/entities/value_object/reference.dart';
import 'package:appledocumentationflutter/entities/value_object/text_content.dart';

part 'doc_text_view.freezed.dart';

@freezed
class DocTextBlock with _$DocTextBlock {
  const factory DocTextBlock.paragraph(
    List<(String, DocTextAttributes)> contents,
  ) = _Paragraph;

  const factory DocTextBlock.heading(
    List<(String, DocTextAttributes)> contents, {
    required int level,
    String? anchor,
  }) = _Heading;

  const factory DocTextBlock.image({
    required ReferenceImage data,
  }) = _Image;

  const factory DocTextBlock.aside({
    required List<DocTextBlock> contents,
    required String? name,
    required String style,
  }) = _Aside;

  const factory DocTextBlock.unorderedList({
    required List<DocTextBlock> items,
  }) = _UnorderedList;
}

@freezed
class DocTextAttributes with _$DocTextAttributes {
  const factory DocTextAttributes({
    @Default(16) double fontSize,
    @Default(false) bool bold,
    @Default(false) bool italic,
    @Default(false) bool underline,
    @Default(null) String? link,
  }) = _DocTextAttributes;
}

class DocTextView extends StatelessWidget {
  const DocTextView(
    this.textBlocks, {
    required this.references,
    this.attributes = const DocTextAttributes(),
    super.key,
  });

  factory DocTextView.fromBlock(
    BlockContent blockContent, {
    required Reference? Function(RefId) references,
    DocTextAttributes attributes = const DocTextAttributes(),
    Key? key,
  }) {
    final builder = _TextBlockBuilder();
    builder.insertBlock(blockContent, attributes: attributes, references: references);

    return DocTextView(
      builder.build(),
      references: references,
      attributes: attributes,
      key: key,
    );
  }

  factory DocTextView.fromInline(
    List<InlineContent> inlineContent, {
    required Reference? Function(RefId) references,
    DocTextAttributes attributes = const DocTextAttributes(),
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
      key: key,
    );
  }

  final List<DocTextBlock> textBlocks;
  final DocTextAttributes attributes;
  final Reference? Function(RefId) references;

  @override
  Widget build(BuildContext context) {
    return _render(context, textBlocks);
  }

  RichText _renderText(BuildContext context, List<(String, DocTextAttributes)> contents) {
    final theme = Theme.of(context);

    return RichText(
      text: TextSpan(children: [
        for (final (text, attributes) in contents)
          TextSpan(
            text: text,
            style: TextStyle(
              fontSize: attributes.fontSize,
              fontWeight: attributes.bold ? FontWeight.bold : null,
              fontStyle: attributes.italic ? FontStyle.italic : null,
              decoration: attributes.underline ? TextDecoration.underline : null,
              color: attributes.link != null ? theme.colorScheme.primary : null,
            ),
            recognizer: attributes.link != null
                ? (TapGestureRecognizer()
                  ..onTap = () {
                    debugPrint('link: ${attributes.link}');
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
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _renderText(context, contents),
              );
            },
            image: (data) {
              return _DocImageView(data);
            },
            aside: (contents, name, style) {
              return _DocAsideView(
                () => _render(context, contents),
                name: name,
                style: style,
                attributes: attributes,
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
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// MARK: - components
class _DocImageView extends StatelessWidget {
  const _DocImageView(this.image);

  final ReferenceImage image;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _findUrl(context) ?? image.variants.first.url,
    );
  }

  String? _findUrl(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    for (final variant in image.variants) {
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.1),
        border: Border.all(
          color: theme.colorScheme.secondary,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (name case final name?) ...[
            Text(
              name,
              style: TextStyle(
                color: theme.colorScheme.secondary,
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
        final newText = '${'#' * level}${level > 0 ? ' ' : ''}$text';
        final newAttributes = attributes.copyWith(
          fontSize: attributes.fontSize + 12 - level * 2,
          bold: true,
        );
        _insertContent(DocTextBlock.heading(
          [(newText, newAttributes)],
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
        _insertCursor('Links: $items', attributes);
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
      termList: (items) {
        _insertCursor('Term list: $items', attributes);
      },
      aside: (content, style, name) {
        final builder = _TextBlockBuilder();
        for (final content in content) {
          builder.insertBlock(content, attributes: attributes, references: references);
        }
        _insertContent(DocTextBlock.aside(contents: builder.build(), name: name, style: style));
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
      reference: (identifier, _) {
        if (references(identifier) case final ref?) {
          _insertReference(ref, attributes: attributes, references: references);
        }
      },
      image: (identifier) {
        final ref = references(identifier);
        if (ref is ReferenceImage) {
          _insertContent(DocTextBlock.image(data: ref));
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
      topic: (kind, role, title, url, contents, deprecated) {
        final newAttributes = attributes.copyWith(
          underline: true,
          link: url.value,
        );
        _insertCursor(title, newAttributes);
      },
      link: (title, url) {
        final newAttributes = attributes.copyWith(
          underline: true,
          link: url,
        );
        _insertCursor(title, newAttributes);
      },
      image: (variants) {},
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