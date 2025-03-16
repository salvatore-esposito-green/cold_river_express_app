class BoxSize {
  final int? id;
  final int length;
  final int width;
  final int height;

  BoxSize({
    this.id,
    required this.length,
    required this.width,
    required this.height,
  });

  double get volume => (length * width * height) / 1000000;

  String get value => '${length}x${width}x${height}';

  factory BoxSize.fromMap(Map<String, dynamic> map) {
    return BoxSize(
      id: map['id'],
      length: map['length'],
      width: map['width'],
      height: map['height'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'length': length, 'width': width, 'height': height};
  }
}
