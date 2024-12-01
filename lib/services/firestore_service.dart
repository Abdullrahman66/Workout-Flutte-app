import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addWorkout(String userId, Map<String, dynamic> workoutData) async {
    await _db.collection('users').doc(userId).collection('workouts').add(workoutData);
  }

  Stream<QuerySnapshot> getWorkouts(String userId) {
    return _db.collection('users').doc(userId).collection('workouts').snapshots();
  }
}
