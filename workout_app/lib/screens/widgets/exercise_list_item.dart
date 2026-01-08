import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/data/entities/workout/workout_exercise_entity.dart';

class ExerciseListItem extends StatelessWidget {
  final List<WorkoutExerciseEntity> exercises;
  final bool isExpanded;
  final double? iconSize;
  final double? fontSize;
  const ExerciseListItem({
    super.key,
    required this.exercises,
    this.isExpanded = true,
    this.iconSize,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final listView = Scrollbar(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final ex = exercises[index];
          return _buildExerciseItem(ex);
        },
      ),
    );

    return isExpanded ? Expanded(child: listView) : listView;
  }

  Widget _buildExerciseItem(WorkoutExerciseEntity ex) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10, right: 9),
      child: Row(
        children: [
          Container(
            width: iconSize ?? 50,
            height: iconSize ?? 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.large),
            ),
            child: CachedNetworkImage(
              imageUrl: ex.exercise.imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    color: const Color.fromARGB(255, 167, 106, 84),
                  ),
                ),
              ),
              errorWidget: (context, url, error) =>
                  Icon(Icons.fitness_center, size: 45, color: Colors.grey),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              ex.exercise.name,
              style: TextStyle(
                color: Colors.black,
                fontSize: fontSize ?? 18,
                overflow: TextOverflow.ellipsis,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(width: 15),
          Text(
            "${ex.sets}x${ex.reps}",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
