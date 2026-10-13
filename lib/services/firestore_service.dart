import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/quiz_model.dart';
import '../models/attempt_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _quizzesCollection =>
      _firestore.collection('quizzes');

  // --- USER OPERATIONS ---

  /// Stream of user document
  Stream<UserModel?> getUserProfileStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromMap(snapshot.data()!, id: snapshot.id);
      }
      return null;
    });
  }

  /// Fetch user document once
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, id: doc.id);
    }
    return null;
  }

  /// Create new user profile document
  Future<void> createUserProfile(UserModel user) async {
    await _usersCollection.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  /// Update user profile document
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _usersCollection.doc(uid).update(data);
  }

  // --- QUIZ OPERATIONS ---

  /// Stream of all active quizzes
  Stream<List<QuizModel>> getQuizzesStream() {
    return _quizzesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return QuizModel.fromMap(doc.data(), id: doc.id);
      }).toList();
    });
  }

  /// Fetch single quiz by ID
  Future<QuizModel?> getQuizById(String quizId) async {
    final doc = await _quizzesCollection.doc(quizId).get();
    if (doc.exists && doc.data() != null) {
      return QuizModel.fromMap(doc.data()!, id: doc.id);
    }
    return null;
  }

  // --- ATTEMPT OPERATIONS & STATS ---

  /// Record a completed quiz attempt and recalculate user aggregates
  Future<void> recordQuizAttempt({
    required String uid,
    required AttemptModel attempt,
  }) async {
    final userRef = _usersCollection.doc(uid);
    final attemptsRef = userRef.collection('attempts').doc();

    await _firestore.runTransaction((transaction) async {
      // 1. Fetch current user document
      final userSnapshot = await transaction.get(userRef);

      int currentTotalQuizzes = 0;
      double currentAverage = 0.0;
      double currentBest = 0.0;

      if (userSnapshot.exists && userSnapshot.data() != null) {
        final userData = userSnapshot.data()!;
        currentTotalQuizzes = (userData['totalQuizzesTaken'] as num?)?.toInt() ?? 0;
        currentAverage = (userData['averageScore'] as num?)?.toDouble() ?? 0.0;
        currentBest = (userData['bestScore'] as num?)?.toDouble() ?? 0.0;
      }

      // 2. Compute new stats
      final newTotalQuizzes = currentTotalQuizzes + 1;
      final newAverage = ((currentAverage * currentTotalQuizzes) + attempt.score) / newTotalQuizzes;
      final newBest = attempt.score > currentBest ? attempt.score : currentBest;

      // 3. Write attempt document
      transaction.set(attemptsRef, attempt.toMap());

      // 4. Update user aggregate stats
      transaction.set(
        userRef,
        {
          'totalQuizzesTaken': newTotalQuizzes,
          'averageScore': double.parse(newAverage.toStringAsFixed(1)),
          'bestScore': double.parse(newBest.toStringAsFixed(1)),
        },
        SetOptions(merge: true),
      );
    });
  }

  /// Stream of user attempts (ordered by attemptedAt descending)
  Stream<List<AttemptModel>> getUserAttemptsStream(String uid) {
    return _usersCollection
        .doc(uid)
        .collection('attempts')
        .orderBy('attemptedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AttemptModel.fromMap(doc.data(), id: doc.id);
      }).toList();
    });
  }
}
