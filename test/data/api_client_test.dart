import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:appledocumentationflutter/data/api_client.dart';
import 'package:appledocumentationflutter/domain/domain_errors.dart';
import 'package:appledocumentationflutter/entities/technologies.dart';
import 'package:appledocumentationflutter/entities/technology_detail.dart';
import 'package:appledocumentationflutter/entities/value_object/technology_id.dart';

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
        throwsA(isA<NetworkExceptionServerError>()),
      );
    });
  });

  group('fetchTechnology', () {
    test('when json data then returns expected entity', () async {
      final client = MockClient();

      when(client.get(any)).thenAnswer((_) async {
        return http.Response(
          await fixture('detail_accessibility.json'),
          200,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
          },
        );
      });

      final apiClient = ApiClientImpl(client: client);

      await apiClient.fetchTechnology(id: const TechnologyId('/target_id'));

      verify(client.get(Uri.parse('https://developer.apple.com/tutorials/data/target_id.json')));
    });
  });

  group('integration', () {
    final apiClient = ApiClientImpl();

    test('fetchAllTechnologies', () async {
      expect(await apiClient.fetchAllTechnologies(), isA<Technologies>());
    });

    test('fetchTechnology', () async {
      const targets = [
        'Accelerate',
        'AudioDriverKit',
        'CoreAudio',
        'Foundation',
        'SwiftUI',
        'UIKit',
      ];
      for (final target in targets) {
        expect(
          await apiClient.fetchTechnology(id: TechnologyId('/documentation/$target')),
          isA<TechnologyDetail>(),
        );
      }
    });
  });
}
