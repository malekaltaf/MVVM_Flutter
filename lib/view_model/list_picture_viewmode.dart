import 'package:flutter/foundation.dart';
import 'package:mvvm/model/picsum_model.dart';
import 'package:mvvm/services/services.dart';

enum ViewStatus {
  initial,
  loading,
  success,
  error,
}

class PictureViewModel {
  final PicSumModel _picSumModel;

  const PictureViewModel(this._picSumModel);

  PicSumModel get picSumModel => _picSumModel;

  String get id => _picSumModel.id;
  String get author => _picSumModel.author;
  String get url => _picSumModel.url;
  String get downloadUrl => _picSumModel.downloadUrl;
  int get width => _picSumModel.width;
  int get height => _picSumModel.height;
  double get aspectRatio => _picSumModel.aspectRatio;
  String get dimensionsText => '${_picSumModel.width} × ${_picSumModel.height}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PictureViewModel && other._picSumModel == _picSumModel;

  @override
  int get hashCode => _picSumModel.hashCode;
}

class ListPictureViewModel extends ChangeNotifier {
  final PictureService _service;

  ListPictureViewModel({PictureService? service})
      : _service = service ?? Service();

  ViewStatus _status = ViewStatus.initial;
  ViewStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<PictureViewModel> _pictures = [];
  List<PictureViewModel> get pictures => List.unmodifiable(_pictures);

  bool get isLoading => _status == ViewStatus.loading;
  bool get hasError => _status == ViewStatus.error;
  bool get isEmpty => _status == ViewStatus.success && _pictures.isEmpty;

  Future<void> fetchPictures({bool isRefresh = false}) async {
    if (!isRefresh && _pictures.isNotEmpty) {
      return;
    }

    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final apiResult = await _service.fetchPicturesAPI();
      _pictures = apiResult.map((e) => PictureViewModel(e)).toList();
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = ViewStatus.error;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _status = ViewStatus.error;
    } finally {
      notifyListeners();
    }
  }
}
