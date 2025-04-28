import 'package:intl/intl.dart';

abstract class BaseModel {
  final DateTime createdAt;

  BaseModel({required this.createdAt});

  String get formattedCreatedAt {
    return DateFormat('MMM d, y HH:mm').format(createdAt.toLocal());
  }

  Map<String, dynamic> toJson();

  @override
  String toString() {
    return toJson().toString();
  }
}
