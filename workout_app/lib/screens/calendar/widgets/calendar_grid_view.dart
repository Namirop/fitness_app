import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';

class CalendarGridView extends StatefulWidget {
  final WorkoutState state;
  const CalendarGridView({super.key, required this.state});

  @override
  State<CalendarGridView> createState() => _CalendarGridViewState();
}

class _CalendarGridViewState extends State<CalendarGridView> {
  DateTime _currentDate = DateTime.now();

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    });
  }

  List<DateTime> _getDaysInMonth() {
    final firstDay = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDay = DateTime(_currentDate.year, _currentDate.month + 1, 0);

    List<DateTime> days = [];
    for (int i = 0; i < lastDay.day; i++) {
      days.add(firstDay.add(Duration(days: i)));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _getDaysInMonth();
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(197, 255, 255, 255),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(width: 2, color: AppColors.containerBorderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomIcon(
                  icon: Icon(Icons.chevron_left, size: 22),
                  color: Colors.transparent,
                  onTap: () => _previousMonth(),
                ),
                Transform.scale(
                  scaleY: 1.1,
                  child: Text(
                    "${DateFormat('MMM', 'fr_FR').format(_currentDate)} ${DateFormat('yyyy', 'fr_FR').format(_currentDate)}",
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                CustomIcon(
                  icon: Icon(Icons.chevron_right, size: 22),
                  color: Colors.transparent,
                  onTap: () => _nextMonth(),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 260,
              child: GridView.builder(
                physics: ClampingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemCount: daysInMonth.length,
                itemBuilder: (context, index) {
                  final date = daysInMonth[index];
                  final now = DateTime.now();
                  final isToday =
                      date.day == now.day &&
                      date.month == now.month &&
                      date.year == now.year;
                  final bool isSelected =
                      date.day == widget.state.selectedCalendarDate.day &&
                      date.month == widget.state.selectedCalendarDate.month &&
                      date.year == widget.state.selectedCalendarDate.year;
                  final workoutForThisDay = widget.state.getWorkoutOfTheDay(
                    date,
                  );
                  return _buildCalendarDayCell(
                    date,
                    isToday,
                    isSelected,
                    index,
                    workoutForThisDay != null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDayCell(
    DateTime date,
    bool isToday,
    bool isSelected,
    int index,
    bool hasWorkout,
  ) {
    return GestureDetector(
      onTap: () async {
        context.read<WorkoutBloc>().add((SetSelectedCalendarDate(date)));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          color: isToday
              ? const Color.fromARGB(239, 228, 96, 87)
              : hasWorkout
              ? const Color.fromARGB(183, 76, 175, 79)
              : const Color.fromARGB(255, 236, 238, 236),
          border: Border.all(
            color: isSelected && isToday
                ? Colors.red
                : isSelected && hasWorkout
                ? Colors.green
                : isSelected && !hasWorkout
                ? Colors.grey
                : Colors.transparent,
            width: isToday ? 2.5 : 2,
          ),
        ),
        padding: EdgeInsets.all(6),
        alignment: isSelected || isToday
            ? Alignment.center
            : Alignment.bottomLeft,
        width: 50,
        height: 50,
        child: Text(
          "${index + 1}",
          style: TextStyle(
            fontSize: isToday || isSelected ? 23 : 16,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
