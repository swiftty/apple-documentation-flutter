import 'package:flutter/material.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:appledocumentationflutter/entities/value_object/ref_id.dart';
import 'package:appledocumentationflutter/entities/value_object/reference.dart';
import 'package:appledocumentationflutter/entities/value_object/text_content.dart';

part 'doc_text_view.freezed.dart';

@freezed
class DocTextAttributes with _$DocTextAttributes {
  const factory DocTextAttributes({
    @Default(16) double fontSize,
    @Default(false) bool bold,
    @Default(false) bool italic,
    @Default(false) bool underline,
  }) = _DocTextAttributes;
}

class DocTextView extends StatelessWidget {
  const DocTextView(
    this.blockContent, {
    required this.references,
    this.attributes = const DocTextAttributes(),
    super.key,
  });

  factory DocTextView.fromInline(
    List<InlineContent> inlineContent, {
    required Reference? Function(RefId) references,
    DocTextAttributes attributes = const DocTextAttributes(),
    Key? key,
  }) =>
      DocTextView(
        BlockContent.paragraph(inlineContent),
        references: references,
        attributes: attributes,
        key: key,
      );

  final BlockContent blockContent;
  final Reference? Function(RefId) references;
  final DocTextAttributes attributes;

  @override
  Widget build(BuildContext context) {
    return blockContent.when(
      heading: _buildHeading(context),
      paragraph: _buildParagraph(context),
      links: (items, style) => Text('Links: $items'),
      unorderedList: (items) => Text('Unordered list: $items'),
      termList: (items) => Text('Term list: $items'),
      aside: (content, style, name) => Text('Aside: $content'),
    );
  }

  Widget Function(String text, int level, String anchor) _buildHeading(BuildContext context) {
    final theme = Theme.of(context);

    return (text, level, anchor) {
      return Text(
        '${'#' * level}${level > 0 ? ' ' : ''}$text',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      );
    };
  }

  Widget Function(List<InlineContent> inlineContent) _buildParagraph(BuildContext context) {
    return (inlineContent) {
      final builder = _TextSpanBuilder();
      for (final content in inlineContent) {
        builder.insert(content, attributes: attributes, references: references);
      }
      return _render(context, builder.build());
    };
  }

  Widget _render(BuildContext context, List<_TextContent> contents) {
    return Column(
      children: [
        for (final content in contents)
          content.when(
            paragraph: (texts) {
              return RichText(
                text: TextSpan(children: [
                  for (final (text, attributes) in texts)
                    TextSpan(
                      text: text,
                      style: TextStyle(
                        fontSize: attributes.fontSize,
                        fontWeight: attributes.bold ? FontWeight.bold : null,
                        fontStyle: attributes.italic ? FontStyle.italic : null,
                        decoration: attributes.underline ? TextDecoration.underline : null,
                      ),
                    ),
                ]),
              );
            },
            image: (data) {
              return _DocImageView(data);
            },
          ),
      ],
    );
  }
}

// MARK: - components
class _DocImageView extends StatelessWidget {
  const _DocImageView(this.image, {super.key});

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

// MARK: - builder
@freezed
class _TextContent with _$TextContent {
  const factory _TextContent.paragraph(
    List<(String, DocTextAttributes)> contents,
  ) = _Paragraph;

  const factory _TextContent.image({
    required ReferenceImage data,
  }) = _Image;
}

class _TextSpanBuilder {
  final _cursor = <(String, DocTextAttributes)>[];
  final _contents = <_TextContent>[];

  void _insertCursor(String text, DocTextAttributes attributes) {
    _cursor.add((text, attributes));
  }

  void _insertContent(_TextContent content) {
    if (_cursor.isNotEmpty) {
      _contents.add(_TextContent.paragraph(_cursor));
      _cursor.clear();
    }
    _contents.add(content);
  }

  void insert(
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
          insert(content, attributes: newAttributes, references: references);
        }
      },
      reference: (identifier, _) {
        _insertCursor('ref: ${identifier.value}', attributes);
      },
      image: (identifier) {
        final ref = references(identifier);
        if (ref is ReferenceImage) {
          _insertContent(_TextContent.image(data: ref));
        }
      },
      unknown: (type) {
        _insertCursor('unknown: $type', attributes);
      },
    );
  }

  List<_TextContent> build() {
    if (_cursor.isNotEmpty) {
      _contents.add(_TextContent.paragraph(_cursor));
    }
    return _contents;
  }
}
