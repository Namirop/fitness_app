import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/cubit/navigation_cubit.dart';

class CalendarPreview extends StatelessWidget {
  final List<DateTime> currentWeek;
  const CalendarPreview({super.key, required this.currentWeek});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutBloc, WorkoutState>(
      buildWhen: (previous, current) =>
          previous.workoutDays != current.workoutDays,
      builder: (context, state) {
        return GestureDetector(
          onTap: () => context.read<NavigationCubit>().goToPage(1),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 248, 227, 178),
              borderRadius: BorderRadius.all(
                Radius.circular(AppBorderRadius.medium),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: currentWeek.map((day) {
                final hasWorkout = state.workoutDays.contains(
                  DateTime(day.year, day.month, day.day),
                );
                final isToday = day.day == DateTime.now().day;
                return _buildCalendarDayItem(day, isToday, hasWorkout);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarDayItem(DateTime day, bool isToday, bool hasWorkout) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(AppBorderRadius.small),
          ),
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
                  fontFamily: "Michroma",
                  color: hasWorkout ? Colors.amber : Colors.black,
                ),
              ),
              Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: "Michroma",
                  fontWeight: FontWeight.bold,
                  color: hasWorkout ? Colors.amber : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
