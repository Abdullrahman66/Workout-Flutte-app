import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  _WorkoutPlanScreenState createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  final _workoutNameController = TextEditingController();
  final _exerciseNameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _targetDateController = TextEditingController();
  final _restTimeController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  void _logout() async {
    try {
      await _authService.logout();
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  void _saveWorkoutPlan() async {
    if (_validateInputs()) {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not authenticated')));
        return;
      }

      final workoutData = {
        'workoutName': _workoutNameController.text,
        'exercises': [
          {
            'exerciseName': _exerciseNameController.text,
            'sets': int.parse(_setsController.text),
            'reps': int.parse(_repsController.text),
            'restTime': _restTimeController.text,
            'targetDate': _targetDateController.text,
          }
        ],
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestoreService.addWorkout(userId, workoutData);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workout plan saved')));
      _clearInputs();
    }
  }

  bool _validateInputs() {
    if (_workoutNameController.text.isEmpty ||
        _exerciseNameController.text.isEmpty ||
        _setsController.text.isEmpty ||
        _repsController.text.isEmpty ||
        _restTimeController.text.isEmpty ||
        _targetDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields are required')));
      return false;
    }

    if (int.tryParse(_setsController.text) == null ||
        int.tryParse(_repsController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sets, reps, and rest time must be numbers')));
      return false;
    }

    return true;
  }

  void _clearInputs() {
    _workoutNameController.clear();
    _exerciseNameController.clear();
    _setsController.clear();
    _repsController.clear();
    _restTimeController.clear();
    _targetDateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue[200],
          title: const Text('Create Workout Plan'),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.of(context).pushNamed('/workoutHistory');
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _workoutNameController, decoration: const InputDecoration(labelText: 'Workout Name')),
            const SizedBox(height: 20),
            TextField(controller: _exerciseNameController, decoration: const InputDecoration(labelText: 'Exercise Name')),
            const SizedBox(height: 20),
            TextField(controller: _setsController, decoration: const InputDecoration(labelText: 'Number of Sets'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            TextField(controller: _repsController, decoration: const InputDecoration(labelText: 'Number of reps'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            TextField(controller: _targetDateController, decoration: const InputDecoration(labelText: 'Duration Time (seconds)')),
            const SizedBox(height: 20),
            TextField(controller: _restTimeController, decoration: const InputDecoration(labelText: 'Rest Time (seconds)')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveWorkoutPlan, child: const Text('Save Workout Plan')),

          ],
        ),
      ),
    );
  }
}
