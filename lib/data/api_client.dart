import 'dart:convert';

import 'package:http/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:appledocumentationflutter/domain/domain_errors.dart';
import 'package:appledocumentationflutter/entities/technologies.dart';
import 'package:appledocumentationflutter/entities/technology_detail.dart';
import 'package:appledocumentationflutter/entities/value_object/technology_id.dart';

part 'api_client.g.dart';

@riverpod
ApiClient apiClient(ApiClientRef ref) => throw UnimplementedError();

/// interface
abstract class ApiClient {
  Future<Technologies> fetchAllTechnologies();

  Future<TechnologyDetail> fetchTechnology({required TechnologyId id});
}

/// impl
class ApiClientImpl implements ApiClient {
  ApiClientImpl({
    String baseUrl = 'https://developer.apple.com',
    Client? client,
  })  : _baseUrl = baseUrl,
        _client = client ?? Client();

  final String _baseUrl;
  final Client _client;

  @override
  Future<Technologies> fetchAllTechnologies() {
    return _fetch(
      Uri.parse('$_baseUrl/tutorials/data/documentation/technologies.json'),
      onRequest: (url) => _client.get(url),
      onSerialize: (json) => Technologies.fromJson(json),
    );
  }

  @override
  Future<TechnologyDetail> fetchTechnology({required TechnologyId id}) {
    return _fetch(
      Uri.parse('$_baseUrl/tutorials/data/${id.value}.json'),
      onRequest: (url) => _client.get(url),
      onSerialize: (json) => TechnologyDetail.fromJson(json),
    );
  }

  Future<T> _fetch<T>(
    Uri url, {
    required Future<Response> Function(Uri) onRequest,
    required T Function(dynamic) onSerialize,
  }) async {
    try {
      final response = await onRequest(url);
      switch (response.statusCode) {
        case >= 200 && < 300:
          final json = jsonDecode(response.body);
          return onSerialize(json);

        case >= 400 && < 500:
          throw NetworkError.badRequest(code: response.statusCode, url: url);

        case >= 500:
          throw NetworkError.serverError(code: response.statusCode, url: url);

        default:
          throw UnexpectedError(reason: 'url: $url, status: ${response.statusCode}');
      }
    } on DomainError catch (_) {
      rethrow;
    } on ClientException catch (e) {
      throw UnexpectedError(reason: 'url: $url}', error: e);
    } on Exception catch (e) {
      throw UnexpectedError(reason: 'url: $url}', error: e);
    }
  }
}
