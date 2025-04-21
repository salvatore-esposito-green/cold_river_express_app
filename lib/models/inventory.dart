import 'dart:convert';

class Inventory {
  final String id;
  // ignore: non_constant_identifier_names
  final String box_number;
  final List<String> contents;
  // ignore: non_constant_identifier_names
  final String? image_path;
  final String size;
  final String? position;
  final String? environment;
  // ignore: non_constant_identifier_names
  final DateTime last_updated;
  final bool isDeleted;

  Inventory({
    required this.id,
    // ignore: non_constant_identifier_names
    required this.box_number,
    required this.contents,
    // ignore: non_constant_identifier_names
    this.image_path,
    required this.size,
    this.position,
    this.environment,
    // ignore: non_constant_identifier_names
    required this.last_updated,
    required this.isDeleted,
  });

  factory Inventory.fromMap(Map<String, dynamic> map) {
    return Inventory(
      id: map['id'],
      box_number: map['box_number'],
      contents: List<String>.from(jsonDecode(map['contents'])),
      image_path: map['image_path'],
      size: map['size'],
      position: map['position'],
      environment: map['environment'],
      last_updated: DateTime.parse(map['last_updated']),
      isDeleted: map['isDeleted'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'box_number': box_number,
      'contents': jsonEncode(contents),
      'image_path': image_path,
      'size': size,
      'position': position,
      'environment': environment,
      'last_updated': last_updated.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  Inventory copyWith({
    String? id,
    // ignore: non_constant_identifier_names
    String? box_number,
    List<String>? contents,
    // ignore: non_constant_identifier_names
    String? image_path,
    String? size,
    String? position,
    String? environment,
    // ignore: non_constant_identifier_names
    DateTime? last_updated,
    bool? isDeleted,
  }) {
    return Inventory(
      id: id ?? this.id,
      box_number: box_number ?? this.box_number,
      contents: contents ?? this.contents,
      image_path: image_path ?? this.image_path,
      size: size ?? this.size,
      position: position ?? this.position,
      environment: environment ?? this.environment,
      last_updated: last_updated ?? this.last_updated,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
