import 'package:appledocumentationflutter/data/api_client.dart';
import 'package:appledocumentationflutter/data/responses/fetch_all_technologies_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("fetch all technologies", () async {
    final apiClient = ApiClientImpl(baseUrl: 'https://developer.apple.com');

    final response = await apiClient.fetchAllTechnologies();
    expect(response.sections.length, greaterThanOrEqualTo(2));
    expect((response.sections[1] as SectionTechnologies).groups.length,
        greaterThanOrEqualTo(1));
  });
}
