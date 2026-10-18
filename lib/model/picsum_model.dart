class PicSumModel {
  final String id;
  final String author;
  final int width;
  final int height;
  final String url;
  final String downloadUrl;

  const PicSumModel({
    required this.id,
    required this.author,
    required this.width,
    required this.height,
    required this.url,
    required this.downloadUrl,
  });

  factory PicSumModel.fromJson(Map<String, dynamic> json) {
    return PicSumModel(
      id: json['id']?.toString() ?? '',
      author: json['author'] as String? ?? 'Unknown Author',
      width: (json['width'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      url: json['url'] as String? ?? '',
      downloadUrl: json['download_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'author': author,
      'width': width,
      'height': height,
      'url': url,
      'download_url': downloadUrl,
    };
  }

  double get aspectRatio {
    if (width > 0 && height > 0) {
      return width / height;
    }
    return 1.0;
  }

  PicSumModel copyWith({
    String? id,
    String? author,
    int? width,
    int? height,
    String? url,
    String? downloadUrl,
  }) {
    return PicSumModel(
      id: id ?? this.id,
      author: author ?? this.author,
      width: width ?? this.width,
      height: height ?? this.height,
      url: url ?? this.url,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PicSumModel &&
        other.id == id &&
        other.author == author &&
        other.width == width &&
        other.height == height &&
        other.url == url &&
        other.downloadUrl == downloadUrl;
  }

  @override
  int get hashCode {
    return Object.hash(id, author, width, height, url, downloadUrl);
  }

  @override
  String toString() {
    return 'PicSumModel(id: $id, author: $author, width: $width, height: $height, url: $url, downloadUrl: $downloadUrl)';
  }
}
