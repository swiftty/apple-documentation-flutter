import 'dart:convert';

import 'package:appledocumentationflutter/data/responses/fetch_all_technologies_response.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixture.dart';

void main() {
  test("fetch all technologies", () async {
    final json =
        jsonDecode(await fixture('fetch_all_technologies_response.json'));

    final response = FetchAllTechnologiesResponse.fromJson(json);
    expect(response.sections.length, greaterThanOrEqualTo(2));
    expect((response.sections[1] as SectionTechnologies).groups.length,
        greaterThanOrEqualTo(1));
  });
}
