import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:appledocumentationflutter/data/api_client.dart';
import 'package:appledocumentationflutter/domain/domain_errors.dart';

import '../fixture.dart';

import 'api_client_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('fetchAllTechnologies', () {
    test('when json data then returns expected entity', () async {
      final client = MockClient();

      when(client.get(any)).thenAnswer((_) async {
        return http.Response(
          await fixture('technologies.json'),
          200,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
          },
        );
      });

      final apiClient = ApiClientImpl(client: client);

      await apiClient.fetchAllTechnologies();

      verify(client.get(
          Uri.parse('https://developer.apple.com/tutorials/data/documentation/technologies.json')));
    });

    test('when broken json data then returns unknown error', () async {
      final client = MockClient();

      when(client.get(any)).thenAnswer((_) async {
        return http.Response(
          'broken json',
          200,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
          },
        );
      });

      final apiClient = ApiClientImpl(client: client);

      expect(
        () async => await apiClient.fetchAllTechnologies(),
        throwsA(isA<UnexpectedError>()),
      );
    });

    test('when server error then returns serverError', () async {
      final client = MockClient();

      when(client.get(any)).thenAnswer((_) async {
        return http.Response(
          'server error',
          500,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
          },
        );
      });

      final apiClient = ApiClientImpl(client: client);

      expect(
        () async => await apiClient.fetchAllTechnologies(),
        throwsA(isA<NetworkErrorServerError>()),
      );
    });
  });
}
