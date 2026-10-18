import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mvvm/view_model/list_picture_viewmode.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  final ListPictureViewModel? viewModel;

  const HomePage({super.key, this.viewModel});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ListPictureViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? ListPictureViewModel();
    _viewModel.fetchPictures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MVVM Gallery',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => _viewModel.fetchPictures(isRefresh: true),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          switch (_viewModel.status) {
            case ViewStatus.initial:
            case ViewStatus.loading:
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading pictures...',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );

            case ViewStatus.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _viewModel.errorMessage ?? 'Unknown error',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () =>
                            _viewModel.fetchPictures(isRefresh: true),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );

            case ViewStatus.success:
              if (_viewModel.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library_outlined,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No pictures found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () =>
                            _viewModel.fetchPictures(isRefresh: true),
                        child: const Text('Reload'),
                      ),
                    ],
                  ),
                );
              }

              final width = MediaQuery.of(context).size.width;
              final crossAxisCount = width > 900
                  ? 4
                  : width > 600
                      ? 3
                      : 2;

              return RefreshIndicator(
                onRefresh: () => _viewModel.fetchPictures(isRefresh: true),
                child: MasonryGridView.count(
                  padding: const EdgeInsets.all(8.0),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  itemCount: _viewModel.pictures.length,
                  itemBuilder: (context, index) {
                    final picture = _viewModel.pictures[index];
                    return _PictureCard(
                      picture: picture,
                      onTap: () => _showPictureDetails(context, picture),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }

  void _showPictureDetails(BuildContext context, PictureViewModel picture) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: picture.aspectRatio > 0
                        ? picture.aspectRatio
                        : 16 / 9,
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: picture.downloadUrl,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 48),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  picture.author,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.straighten, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Dimensions: ${picture.dimensionsText}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.tag, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Photo ID: ${picture.id}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: picture.downloadUrl));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Download URL copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Image Link'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PictureCard extends StatelessWidget {
  final PictureViewModel picture;
  final VoidCallback onTap;

  const _PictureCard({
    required this.picture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: picture.aspectRatio > 0 ? picture.aspectRatio : 1.0,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: picture.downloadUrl,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      picture.author.isNotEmpty ? picture.author[0] : '?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      picture.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
