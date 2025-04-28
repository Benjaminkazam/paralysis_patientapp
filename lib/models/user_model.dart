import 'base_model.dart';

class UserModel extends BaseModel {
  final String id;
  final String name;
  final String role;
  final String email;
  final String? roomNumber;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.roomNumber,
    required DateTime createdAt,
  }) : super(createdAt: createdAt);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      email: json['email'],
      roomNumber: json['room_number'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'room_number': roomNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
