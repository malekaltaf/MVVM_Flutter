import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/model/picsum_model.dart';

void main() {
  group('PicSumModel', () {
    final sampleJson = {
      'id': '10',
      'author': 'Paul Jarvis',
      'width': 2500,
      'height': 1667,
      'url': 'https://unsplash.com/photos/6J--NXulQCs',
      'download_url': 'https://picsum.photos/id/10/2500/1667',
    };

    test('fromJson parses all fields correctly', () {
      final model = PicSumModel.fromJson(sampleJson);

      expect(model.id, '10');
      expect(model.author, 'Paul Jarvis');
      expect(model.width, 2500);
      expect(model.height, 1667);
      expect(model.url, 'https://unsplash.com/photos/6J--NXulQCs');
      expect(model.downloadUrl, 'https://picsum.photos/id/10/2500/1667');
    });

    test('fromJson handles null values gracefully with defaults', () {
      final model = PicSumModel.fromJson({});

      expect(model.id, '');
      expect(model.author, 'Unknown Author');
      expect(model.width, 0);
      expect(model.height, 0);
      expect(model.url, '');
      expect(model.downloadUrl, '');
      expect(model.aspectRatio, 1.0);
    });

    test('toJson serializes correctly', () {
      final model = PicSumModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json, sampleJson);
    });

    test('aspectRatio computes width / height', () {
      const model = PicSumModel(
        id: '1',
        author: 'Test',
        width: 1000,
        height: 500,
        url: '',
        downloadUrl: '',
      );

      expect(model.aspectRatio, 2.0);
    });

    test('copyWith updates specified fields', () {
      final model = PicSumModel.fromJson(sampleJson);
      final updated = model.copyWith(author: 'New Author');

      expect(updated.author, 'New Author');
      expect(updated.id, model.id);
    });

    test('equality and hashCode works', () {
      final model1 = PicSumModel.fromJson(sampleJson);
      final model2 = PicSumModel.fromJson(sampleJson);

      expect(model1, equals(model2));
      expect(model1.hashCode, equals(model2.hashCode));
    });
  });
}

