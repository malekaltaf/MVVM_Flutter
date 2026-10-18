import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mvvm/services/services.dart';

void main() {
  group('Service', () {
    test('fetchPicturesAPI returns list on status 200', () async {
      final mockData = [
        {
          'id': '1',
          'author': 'Author One',
          'width': 100,
          'height': 100,
          'url': 'https://example.com/1',
          'download_url': 'https://example.com/d1',
        },
        {
          'id': '2',
          'author': 'Author Two',
          'width': 200,
          'height': 200,
          'url': 'https://example.com/2',
          'download_url': 'https://example.com/d2',
        }
      ];

      final client = MockClient((request) async {
        return http.Response(jsonEncode(mockData), 200, headers: {
          'content-type': 'application/json',
        });
      });

      final service = Service(client: client);
      final pictures = await service.fetchPicturesAPI();

      expect(pictures.length, 2);
      expect(pictures[0].id, '1');
      expect(pictures[0].author, 'Author One');
      expect(pictures[1].id, '2');
      expect(pictures[1].author, 'Author Two');
    });

    test('fetchPicturesAPI throws ApiException on 404 or 500', () async {
      final client = MockClient((request) async {
        return http.Response('Server error', 500);
      });

      final service = Service(client: client);

      expect(
        () => service.fetchPicturesAPI(),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('fetchPicturesAPI throws ApiException on invalid JSON body', () async {
      final client = MockClient((request) async {
        return http.Response('not valid json', 200);
      });

      final service = Service(client: client);

      expect(
        () => service.fetchPicturesAPI(),
        throwsA(isA<ApiException>()),
      );
    });
  });
}

