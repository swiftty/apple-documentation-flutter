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
        "text: $text, level: $level, anchor: $anchor",
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      );
    };
  }

  Widget Function(List<InlineContent> inlineContent) _buildParagraph(BuildContext context) {
    return (inlineContent) {
      return Column(
        children: [
          for (final content in inlineContent)
            content.when(
              text: (text) => Text("text: $text"),
              reference: (identifier, _) => Text('Reference: ${identifier.value}'),
              unknown: (type) => Text('Unknown type: $type'),
            ),
        ],
      );
    };
  }
}

// @freezed
// class _TextContent with _$_TextContent {
//   const factory _TextContent.text({
//     required String text,
//     required DocTextAttributes attributes,
//   }) = _Text;
// }

// class _TextSpanBuilder {
//   var _contents = <_TextContent>[];

//   void build(
//     BlockContent block,
//     DocTextAttributes attributes,
//   ) {

//   }
// }
