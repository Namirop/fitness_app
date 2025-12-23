import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/screens/add_workout_screen.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
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

  // Pas compris mais pas important
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
    return BlocBuilder<WorkoutBloc, WorkoutState>(
      builder: (context, state) {
        return Scaffold(
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 238, 228, 206),
                    Color.fromARGB(255, 243, 239, 227),
                  ],
                ),
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
                            child: CustomIconButton(
                              icon: Icon(Icons.calendar_month, size: 25),
                              size: 45,
                            ),
                          ),
                          SizedBox(width: 10),
                          Transform.scale(
                            scaleY: 1.1,
                            child: Text(
                              "Calendrier :",
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
                      Container(
                        height: 340,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(197, 255, 255, 255),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: _previousMonth,
                                    icon: Icon(Icons.chevron_left, size: 22),
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
                                  IconButton(
                                    onPressed: _nextMonth,
                                    icon: Icon(Icons.chevron_right, size: 22),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              // Expanded pour que le grid ait une base, sinon bug de height
                              Expanded(
                                child: GridView.builder(
                                  physics:
                                      ClampingScrollPhysics(), // Enlève le scroll du GridView
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            7, // Indique le nombre de case par ligne
                                        mainAxisSpacing: 2, // espace vertical
                                        crossAxisSpacing:
                                            2, // espace horizontal
                                      ),
                                  itemCount: daysInMonth.length,
                                  itemBuilder: (context, index) {
                                    final day = daysInMonth[index];
                                    final workoutForThisDay = state
                                        .getWorkoutForDate(day);
                                    final now = DateTime.now();
                                    final isToday =
                                        day.day == now.day &&
                                        day.month == now.month &&
                                        day.year == now.year;
                                    return GestureDetector(
                                      onTap: () async {
                                        final resume = await showDialog<bool>(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                              workoutForThisDay != null
                                                  ? "Modifier le workout à la date du ${workoutForThisDay.date.day}. ${workoutForThisDay.date.month} ?"
                                                  : "Ajouter un workout à la date du ${day.day}. ${day.month} ?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text("Non"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: Text("Oui"),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (resume == true && mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddWorkoutScreen(
                                                    workoutToEdit:
                                                        workoutForThisDay,
                                                    initialDate:
                                                        workoutForThisDay ==
                                                            null
                                                        ? DateTime.now()
                                                        : null,
                                                  ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: isToday
                                              ? const Color.fromARGB(
                                                  255,
                                                  228,
                                                  96,
                                                  87,
                                                )
                                              : workoutForThisDay != null
                                              ? const Color.fromARGB(
                                                  255,
                                                  102,
                                                  185,
                                                  102,
                                                )
                                              : const Color.fromARGB(
                                                  255,
                                                  236,
                                                  238,
                                                  236,
                                                ),
                                        ),
                                        padding: EdgeInsets.all(6),
                                        alignment: isToday
                                            ? Alignment.center
                                            : Alignment.bottomLeft,
                                        width: 50,
                                        height: 50,
                                        child: Text(
                                          "${index + 1}",
                                          style: TextStyle(
                                            fontSize: isToday ? 22 : 15,
                                            fontWeight: isToday
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isToday
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
