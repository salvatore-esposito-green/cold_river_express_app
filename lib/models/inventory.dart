import 'dart:convert';

class Inventory {
  final String id;
  final String boxNumber;
  final List<String> contents;
  final String? imagePath;
  final String size;
  final String position;
  final DateTime lastUpdated;

  Inventory({
    required this.id,
    required this.boxNumber,
    required this.contents,
    this.imagePath,
    required this.size,
    required this.position,
    required this.lastUpdated,
  });

  factory Inventory.fromMap(Map<String, dynamic> map) {
    return Inventory(
      id: map['id'],
      boxNumber: map['boxNumber'],
      contents: List<String>.from(jsonDecode(map['contents'])),
      imagePath: map['imagePath'],
      size: map['size'],
      position: map['position'],
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'boxNumber': boxNumber,
      'contents': jsonEncode(contents),
      'imagePath': imagePath,
      'size': size,
      'position': position,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  Inventory copyWith({
    String? id,
    String? boxNumber,
    List<String>? contents,
    String? imagePath,
    String? size,
    String? position,
    DateTime? lastUpdated,
  }) {
    return Inventory(
      id: id ?? this.id,
      boxNumber: boxNumber ?? this.boxNumber,
      contents: contents ?? this.contents,
      imagePath: imagePath ?? this.imagePath,
      size: size ?? this.size,
      position: position ?? this.position,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
