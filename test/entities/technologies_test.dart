import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:appledocumentationflutter/entities/technologies.dart';
import 'package:appledocumentationflutter/entities/value_object/language.dart';
import 'package:appledocumentationflutter/entities/value_object/ref_id.dart';
import 'package:appledocumentationflutter/entities/value_object/reference.dart';
import 'package:appledocumentationflutter/entities/value_object/technology_id.dart';
import 'package:appledocumentationflutter/entities/value_object/text_content.dart';

import '../fixture.dart';

void main() {
  group('Technologies', () {
    test('encode DocId', () {
      const id = RefId('doc://com.apple.documentation/documentation/accessibility');
      expect(id.toJson(), 'doc://com.apple.documentation/documentation/accessibility');
    });

    test("decode Technologies", () async {
      final json = jsonDecode(await fixture('technologies.json'));

      final response = Technologies.fromJson(json);
      expect(response.sections.length, 2);
      expect(
        response.sections[0],
        isA<SectionHero>()
            .having((s) => s.kind, 'kind', 'hero')
            .having((s) => s.image, 'image', const RefId('technologies-hero.png')),
      );
      expect(
        response.sections[1],
        isA<SectionTechnologies>()
            .having((s) => s.kind, 'kind', 'technologies')
            .having((s) => s.groups.length, 'length', 9),
      );

      final groups = (response.sections[1] as SectionTechnologies).groups;
      expect(
        groups[0],
        isA<SectionGroup>()
            .having((g) => g.name, 'name', 'App Frameworks')
            .having((g) => g.technologies.length, 'length', 34),
      );

      final technologies = groups[0].technologies;
      expect(
        technologies[0],
        const Technology(
          title: 'Accessibility',
          content: [],
          languages: [Language.objectiveC(), Language.swift()],
          destination: Destination.reference(
            identifier: RefId(
              'doc://com.apple.documentation/documentation/accessibility',
            ),
            isActive: true,
          ),
          tags: [
            'Accessibility',
            'App Frameworks',
            'Text',
          ],
        ),
      );

      expect(
        response.reference(
          const RefId('doc://com.apple.documentation/documentation/accessibility'),
        ),
        const Reference.topic(
          kind: Kind.symbol,
          role: Role.collection,
          title: 'Accessibility',
          url: TechnologyId('/documentation/Accessibility'),
          abstract: [
            InlineContent.text(
              text: 'Make your apps accessible to everyone who uses Apple devices.',
            ),
          ],
        ),
      );
    });
  });
}
