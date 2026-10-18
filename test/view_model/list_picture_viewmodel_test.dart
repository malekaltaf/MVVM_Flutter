import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/model/picsum_model.dart';
import 'package:mvvm/services/services.dart';
import 'package:mvvm/view_model/list_picture_viewmodel.dart';

class FakeSuccessPictureService implements PictureService {
  int callCount = 0;

  @override
  Future<List<PicSumModel>> fetchPicturesAPI({int page = 1, int limit = 30}) async {
    callCount++;
    return const [
      PicSumModel(
        id: '1',
        author: 'John Doe',
        width: 1920,
        height: 1080,
        url: 'https://example.com/1',
        downloadUrl: 'https://example.com/download/1',
      ),
    ];
  }
}

class FakeFailurePictureService implements PictureService {
  @override
  Future<List<PicSumModel>> fetchPicturesAPI({int page = 1, int limit = 30}) async {
    throw const ApiException('Network failed', 503);
  }
}

void main() {
  group('ListPictureViewModel', () {
    test('initial state is correct', () {
      final vm = ListPictureViewModel();
      expect(vm.status, ViewStatus.initial);
      expect(vm.isLoading, false);
      expect(vm.hasError, false);
      expect(vm.pictures, isEmpty);
      expect(vm.errorMessage, isNull);
    });

    test('fetchPictures updates status to loading then success', () async {
      final fakeService = FakeSuccessPictureService();
      final vm = ListPictureViewModel(service: fakeService);

      final statusHistory = <ViewStatus>[];
      vm.addListener(() {
        statusHistory.add(vm.status);
      });

      await vm.fetchPictures();

      expect(statusHistory, contains(ViewStatus.loading));
      expect(vm.status, ViewStatus.success);
      expect(vm.pictures.length, 1);
      expect(vm.pictures.first.author, 'John Doe');
      expect(vm.pictures.first.dimensionsText, '1920 × 1080');
      expect(fakeService.callCount, 1);
    });

    test('fetchPictures skips refetch when already loaded and isRefresh is false', () async {
      final fakeService = FakeSuccessPictureService();
      final vm = ListPictureViewModel(service: fakeService);

      await vm.fetchPictures();
      expect(fakeService.callCount, 1);

      await vm.fetchPictures();
      expect(fakeService.callCount, 1);

      await vm.fetchPictures(isRefresh: true);
      expect(fakeService.callCount, 2);
    });

    test('fetchPictures sets error state when service fails', () async {
      final fakeService = FakeFailurePictureService();
      final vm = ListPictureViewModel(service: fakeService);

      await vm.fetchPictures();

      expect(vm.status, ViewStatus.error);
      expect(vm.hasError, true);
      expect(vm.errorMessage, 'Network failed');
      expect(vm.pictures, isEmpty);
    });
  });

  group('PictureViewModel', () {
    test('exposes model properties properly', () {
      const model = PicSumModel(
        id: '42',
        author: 'Jane Doe',
        width: 800,
        height: 600,
        url: 'https://example.com/item',
        downloadUrl: 'https://example.com/dl',
      );
      const vm = PictureViewModel(model);

      expect(vm.id, '42');
      expect(vm.author, 'Jane Doe');
      expect(vm.width, 800);
      expect(vm.height, 600);
      expect(vm.dimensionsText, '800 × 600');
      expect(vm.aspectRatio, closeTo(1.333, 0.01));
      expect(vm.url, 'https://example.com/item');
      expect(vm.downloadUrl, 'https://example.com/dl');
    });
  });
}

