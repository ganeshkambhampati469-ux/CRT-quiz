import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final int totalQuizzesTaken;
  final double averageScore;
  final double bestScore;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    this.totalQuizzesTaken = 0,
    this.averageScore = 0.0,
    this.bestScore = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'totalQuizzesTaken': totalQuizzesTaken,
      'averageScore': averageScore,
      'bestScore': bestScore,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return UserModel(
      uid: id ?? map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      createdAt: parseDate(map['createdAt']),
      totalQuizzesTaken: (map['totalQuizzesTaken'] as num?)?.toInt() ?? 0,
      averageScore: (map['averageScore'] as num?)?.toDouble() ?? 0.0,
      bestScore: (map['bestScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    DateTime? createdAt,
    int? totalQuizzesTaken,
    double? averageScore,
    double? bestScore,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      totalQuizzesTaken: totalQuizzesTaken ?? this.totalQuizzesTaken,
      averageScore: averageScore ?? this.averageScore,
      bestScore: bestScore ?? this.bestScore,
    );
  }
}
