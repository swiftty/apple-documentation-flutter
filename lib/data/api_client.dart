import 'dart:convert';

import 'package:http/http.dart';

import 'package:appledocumentationflutter/domain/domain_errors.dart';
import 'package:appledocumentationflutter/entities/technologies.dart';

abstract class ApiClient {
  Future<Technologies> fetchAllTechnologies();
}

/// impl
class ApiClientImpl implements ApiClient {
  ApiClientImpl({
    String baseUrl = 'https://developer.apple.com',
    required Client client,
  })  : _client = client,
        _baseUrl = baseUrl;

  final String _baseUrl;
  final Client _client;

  @override
  Future<Technologies> fetchAllTechnologies() async {
    return await _fetch(
      Uri.parse('$_baseUrl/tutorials/data/documentation/technologies.json'),
      (url) => _client.get(url),
      (json) => Technologies.fromJson(json),
    );
  }

  Future<T> _fetch<T>(
    Uri url,
    Future<Response> Function(Uri) fetcher,
    T Function(dynamic) transform,
  ) async {
    try {
      final response = await fetcher(url);
      switch (response.statusCode) {
        case >= 200 && < 300:
          final json = jsonDecode(response.body);
          return transform(json);

        case >= 400 && < 500:
          throw NetworkError.badRequest(code: response.statusCode, url: url);

        case >= 500:
          throw NetworkError.serverError(code: response.statusCode, url: url);

        default:
          throw NetworkError.unknown(url: url);
      }
    } on DomainError catch (_) {
      rethrow;
    } on ClientException catch (e) {
      throw NetworkError.unknown(url: e.uri, error: e);
    } on Exception catch (e) {
      throw NetworkError.unknown(url: url, error: e);
    }
  }
}
