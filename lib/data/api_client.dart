import 'dart:convert';

import 'package:appledocumentationflutter/data/responses/fetch_all_technologies_response.dart';
import 'package:http/http.dart';

abstract class ApiClient {
  Future<FetchAllTechnologiesResponse> fetchAllTechnologies();
}

/// impl
class ApiClientImpl implements ApiClient {
  factory ApiClientImpl({
    String baseUrl = 'https://developer.apple.com',
  }) =>
      _instance ??= ApiClientImpl._(baseUrl: baseUrl);

  ApiClientImpl._({required this.baseUrl});

  static ApiClientImpl? _instance;

  final String baseUrl;

  @override
  Future<FetchAllTechnologiesResponse> fetchAllTechnologies() async {
    final uri =
        Uri.parse('$baseUrl/tutorials/data/documentation/technologies.json');
    final response = await get(uri);
    final json = jsonDecode(response.body);

    return FetchAllTechnologiesResponse.fromJson(json);
  }
}
