import 'package:appledocumentationflutter/entities/technology.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("decode Technology", () {
    final json = {
      "title": "Flutter",
      "description": {
        "identifier": "flutter",
        "title": "Flutter",
        "value": "flutter",
        "abstract":
            "UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase."
      },
      "tags": ["mobile", "web", "desktop"],
      "languages": ["swift", "occ", "data"],
    };

    final technology = Technology.fromJson(json);

    expect(technology.title, "Flutter");
    expect(technology.description.identifier, const TechnologyId("flutter"));
    expect(technology.description.title, "Flutter");
    expect(technology.description.value,
        const TechnologyDestinationValue("flutter"));
    expect(technology.description.abstract,
        "UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.");
    expect(technology.tags, ["mobile", "web", "desktop"]);
    expect(technology.languages,
        [Language.swift, Language.objectiveC, Language.other]);
  });
}
