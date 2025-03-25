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

  String get value => '${length}x${width}x$height';

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

  factory BoxSize.fromString(String value) {
    final parts = value.split('x');
    if (parts.length != 3) {
      throw Exception('Invalid box size format');
    }
    return BoxSize(
      length: int.parse(parts[0]),
      width: int.parse(parts[1]),
      height: int.parse(parts[2]),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BoxSize) return false;
    return length == other.length &&
        width == other.width &&
        height == other.height;
  }

  @override
  int get hashCode => length.hashCode ^ width.hashCode ^ height.hashCode;
}
