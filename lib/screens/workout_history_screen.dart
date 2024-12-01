import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  _WorkoutHistoryScreenState createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  String _searchQuery = '';
  String _filterCriteria = 'Workout Name';

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('User not authenticated')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[200],
        title: const Text('Workout History'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: _filterCriteria,
                  items: const [
                    DropdownMenuItem(value: 'Workout Name', child: Text('Workout Name')),
                    DropdownMenuItem(value: 'Exercise Name', child: Text('Exercise Name')),
                    DropdownMenuItem(value: 'Number of Reps', child: Text('Number of Reps')),
                    DropdownMenuItem(value: 'Number of Sets', child: Text('Number of Sets')),
                    DropdownMenuItem(value: 'Duration', child: Text('Duration')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterCriteria = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getWorkouts(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading workouts'));
          }

          final workouts = snapshot.data?.docs ?? [];

          if (workouts.isEmpty) {
            return const Center(child: Text('No workouts found'));
          }

          // Filter workouts based on search query and selected criteria
          final filteredWorkouts = workouts.where((doc) {
            final workout = doc.data() as Map<String, dynamic>;
            final exercises = workout['exercises'] as List<dynamic>? ?? [];

            switch (_filterCriteria) {
              case 'Workout Name':
                return (workout['workoutName'] ?? '').toString().toLowerCase().contains(_searchQuery);
              case 'Exercise Name':
                return exercises.any((exercise) =>
                    (exercise['name'] ?? '').toString().toLowerCase().contains(_searchQuery));
              case 'Number of Reps':
                return exercises.any((exercise) =>
                    (exercise['reps'] ?? '').toString().toLowerCase().contains(_searchQuery));
              case 'Number of Sets':
                return exercises.any((exercise) =>
                    (exercise['sets'] ?? '').toString().toLowerCase().contains(_searchQuery));
              case 'Duration':
                return exercises.any((exercise) =>
                    (exercise['duration'] ?? '').toString().toLowerCase().contains(_searchQuery));
              default:
                return false;
            }
          }).toList();

          return ListView.builder(
            itemCount: filteredWorkouts.length,
            itemBuilder: (context, index) {
              final workout = filteredWorkouts[index].data() as Map<String, dynamic>;
              final workoutName = workout['workoutName'] ?? 'No Name';
              final exercises = workout['exercises'] as List<dynamic>? ?? [];

              return Card(
                child: ExpansionTile(
                  title: Text(workoutName),
                  children: exercises.map((exercise) {
                    final exerciseName = exercise['exerciseName'] ?? 'Unnamed Exercise';
                    final reps = exercise['reps'] ?? 'N/A';
                    final sets = exercise['sets'] ?? 'N/A';
                    final duration = exercise['duration'] ?? 'N/A';

                    return ListTile(
                      title: Text(exerciseName),
                      subtitle: Text('Reps: $reps, Sets: $sets, Duration: $duration'),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
