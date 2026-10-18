import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mvvm/model/picsum_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() =>
      statusCode != null ? 'ApiException ($statusCode): $message' : 'ApiException: $message';
}

abstract class PictureService {
  Future<List<PicSumModel>> fetchPicturesAPI({int page = 1, int limit = 30});
}

class Service implements PictureService {
  static const String baseUrl = 'https://picsum.photos/v2/list';
  final http.Client _client;

  Service({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<PicSumModel>> fetchPicturesAPI({
    int page = 1,
    int limit = 30,
  }) async {
    final uri = Uri.parse('$baseUrl?page=$page&limit=$limit');

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decodedJson = jsonDecode(response.body);
        if (decodedJson is List) {
          return decodedJson
              .whereType<Map<String, dynamic>>()
              .map((item) => PicSumModel.fromJson(item))
              .toList();
        }
        throw const ApiException('Invalid response format: expected a list of pictures');
      } else {
        throw ApiException(
          'Failed to load pictures from server',
          response.statusCode,
        );
      }
    } on SocketException catch (e) {
      throw ApiException('No internet connection: ${e.message}');
    } on TimeoutException {
      throw const ApiException('Connection timed out. Please try again.');
    } on FormatException {
      throw const ApiException('Failed to parse server response.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('An unexpected error occurred: $e');
    }
  }
}
