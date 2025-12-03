import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/screens/calendar_screen.dart';

class CalendarPreview extends StatelessWidget {
  final List<DateTime> currentWeek;
  // Un Set est une liste mais sans doublon => pratique pour le cas ici.
  final Set<DateTime> workoutDays;

  const CalendarPreview({required this.currentWeek, required this.workoutDays});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutBloc, WorkoutState>(
      buildWhen: (previous, current) => current is GetExistingWorkoutsSuccess,
      builder: (context, state) {
        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CalendarScreen(workoutDays: workoutDays),
              ),
            );
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 248, 227, 178),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: currentWeek.map((day) {
                final hasWorkout = workoutDays.contains(
                  DateTime(day.year, day.month, day.day),
                );
                final isToday = day.day == DateTime.now().day;
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      border: Border.all(
                        width: 2.0,
                        color: isToday
                            ? const Color.fromARGB(255, 230, 186, 57)
                            : Colors.transparent,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            DateFormat('MMM', 'fr_FR').format(day),
                            style: TextStyle(
                              fontSize: 9,
                              color: hasWorkout ? Colors.amber : Colors.black,
                            ),
                          ),
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: hasWorkout ? Colors.amber : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
