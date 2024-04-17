import 'dart:convert';

import 'package:http/http.dart';

import 'package:appledocumentationflutter/entities/technologies.dart';

abstract class ApiClient {
  Future<Technologies> fetchAllTechnologies();
}

/// impl
class ApiClientImpl implements ApiClient {
  factory ApiClientImpl({
    String baseUrl = 'https://developer.apple.com',
    Client? client,
  }) =>
      _instance ??= ApiClientImpl._(
        baseUrl: baseUrl,
        client: client ?? Client(),
      );

  ApiClientImpl._({
    required this.baseUrl,
    required this.client,
  });

  static ApiClientImpl? _instance;

  final String baseUrl;
  final Client client;

  @override
  Future<Technologies> fetchAllTechnologies() async {
    final uri = Uri.parse('$baseUrl/tutorials/data/documentation/technologies.json');
    final response = await client.get(uri);
    final json = jsonDecode(response.body);

    return Technologies.fromJson(json);
  }
}
