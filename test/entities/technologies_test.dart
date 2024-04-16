import 'dart:convert';

import 'package:appledocumentationflutter/entities/technologies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixture.dart';

void main() {
  test("decode Technologies", () async {
    final json = jsonDecode(await fixture('technologies.json'));

    final response = Technologies.fromJson(json);
    expect(response.sections.length, 2);
    expect(
      response.sections[0],
      isA<SectionHero>()
          .having((s) => s.kind, 'kind', 'hero')
          .having((s) => s.image, 'image', 'technologies-hero.png'),
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
      isA<Group>()
          .having((g) => g.name, 'name', 'App Frameworks')
          .having((g) => g.technologies.length, 'length', 34),
    );

    final technologies = groups[0].technologies;
    expect(
      technologies[0],
      isA<Technology>()
          .having((t) => t.title, 'title', 'Accessibility')
          .having((t) => t.tags, 'tags', [
        'Accessibility',
        'App Frameworks',
        'Text',
      ]),
    );

    expect(
      technologies[0].destination,
      isA<DestinationReference>().having(
        (d) => d.identifier,
        'identifier',
        const TechnologyId(
            'doc://com.apple.documentation/documentation/accessibility'),
      ),
    );
  });
}
