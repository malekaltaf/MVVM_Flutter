import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/main.dart';
import 'package:mvvm/model/picsum_model.dart';
import 'package:mvvm/services/services.dart';
import 'package:mvvm/view/home.dart';
import 'package:mvvm/view_model/list_picture_viewmodel.dart';

class MockPictureService implements PictureService {
  final List<PicSumModel> Function() onFetch;

  MockPictureService(this.onFetch);

  @override
  Future<List<PicSumModel>> fetchPicturesAPI({int page = 1, int limit = 30}) async {
    return onFetch();
  }
}

void main() {
  testWidgets('Renders loading indicator then picture cards on success', (WidgetTester tester) async {
    final mockService = MockPictureService(() => [
          const PicSumModel(
            id: '1',
            author: 'John Test',
            width: 500,
            height: 500,
            url: 'https://example.com/1',
            downloadUrl: 'https://example.com/1.jpg',
          ),
        ]);

    final viewModel = ListPictureViewModel(service: mockService);

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(viewModel: viewModel),
      ),
    );

    // Initial / loading state
    expect(find.text('MVVM Gallery'), findsOneWidget);

    // Let future complete and frame render
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify content
    expect(find.text('John Test'), findsOneWidget);
  });

  testWidgets('Renders error UI with retry button when service fails', (WidgetTester tester) async {
    final mockService = MockPictureService(() {
      throw const ApiException('Failed to load pictures');
    });

    final viewModel = ListPictureViewModel(service: mockService);

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(viewModel: viewModel),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Oops! Something went wrong'), findsOneWidget);
    expect(find.text('Failed to load pictures'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('MyApp renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('MVVM Gallery'), findsOneWidget);
  });
}
