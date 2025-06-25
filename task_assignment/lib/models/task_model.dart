import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String ownerId;
  final List<String> sharedWith;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.sharedWith,
    required this.createdAt,
  });

  factory TaskModel.fromMap(String id, Map<String, dynamic> data) => TaskModel(
    id: id,
    title: data['title'] ?? '',
    description: data['description'] ?? '',
    ownerId: data['ownerId'],
    sharedWith: List<String>.from(data['sharedWith'] ?? []),
    createdAt: (data['createdAt'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'ownerId': ownerId,
    'sharedWith': sharedWith,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
