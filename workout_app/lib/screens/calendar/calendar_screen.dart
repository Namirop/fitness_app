import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/screens/calendar/widgets/calendar_grid_view.dart';
import 'package:workout_app/screens/calendar/widgets/draggable_workout_information_container.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';
import 'package:workout_app/screens/workout/addWorkoutScreen/add_workout_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutBloc, WorkoutState>(
      buildWhen: (previous, current) =>
          previous.selectedCalendarDate != current.selectedCalendarDate ||
          previous.existingWorkouts != current.existingWorkouts,
      builder: (context, state) {
        return Scaffold(
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.screenBackground,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: CustomIcon(
                                  icon: Icon(Icons.calendar_month, size: 25),
                                  size: 45,
                                ),
                              ),
                              SizedBox(width: 10),
                              Transform.scale(
                                scaleY: 1.1,
                                child: Text(
                                  "Calendar :",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          CalendarGridView(state: state),
                        ],
                      ),
                    ),
                  ),
                ),
                state.getWorkoutForTheSelectedDate == null
                    ? _buildAddWorkoutButton(
                        state.selectedCalendarDate,
                        context,
                      )
                    : DraggableWorkoutInformationContainer(
                        workout: state.getWorkoutForTheSelectedDate!,
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddWorkoutButton(DateTime date, BuildContext context) {
    return Positioned(
      bottom: 300,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {
          context.read<WorkoutBloc>().add(
            SetEditingWorkout(isEditingMode: false),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddWorkoutScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              color: AppColors.buttonColor,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 15, 10, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIcon(
                    topPadding: 4,
                    icon: Icon(Icons.check),
                    size: 28,
                    color: Colors.white,
                  ),
                  SizedBox(width: 13),
                  Text(
                    "Ajouter un workout pour le ${DateFormat('dd', 'fr_FR').format(date)} ${DateFormat('MMM', 'fr_FR').format(date)} ?",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
