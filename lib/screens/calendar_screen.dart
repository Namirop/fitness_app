import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  final workoutDays;
  const CalendarScreen({super.key, this.workoutDays});

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

  void _setToCurrentMonth() {
    setState(() {
      _currentDate = DateTime.now();
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
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              color: const Color(0xfffaedcd),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.white60,
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: const Icon(Icons.arrow_back, size: 18),
                          ),
                        ),
                        SizedBox(width: 30),
                        Text(
                          "Calendrier des séances",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Container(
                      height: 350,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: _previousMonth,
                                  icon: Icon(Icons.chevron_left, size: 22),
                                ),
                                Text(
                                  "${DateFormat('MMM', 'fr_FR').format(_currentDate)} ${DateFormat('yyyy', 'fr_FR').format(_currentDate)}",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _nextMonth,
                                  icon: Icon(Icons.chevron_right, size: 22),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            // Expanded pour que le grid ai une base, sinon bug de height
                            Expanded(
                              child: GridView.builder(
                                physics:
                                    ClampingScrollPhysics(), // Enlève le scroll du GridView
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          7, // Indique le nombre de case par ligne
                                      mainAxisSpacing: 2, // espace vertical
                                      crossAxisSpacing: 2, // espace horizontal
                                    ),
                                itemCount: daysInMonth.length,
                                itemBuilder: (context, index) {
                                  final day = daysInMonth[index];
                                  final hasWorkout = widget.workoutDays
                                      .contains(
                                        DateTime(day.year, day.month, day.day),
                                      );
                                  final isToday =
                                      day.day == DateTime.now().day &&
                                      day.month == DateTime.now().month;
                                  return GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: isToday
                                            ? const Color.fromARGB(
                                                255,
                                                228,
                                                96,
                                                87,
                                              )
                                            : hasWorkout
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
                                          fontSize: isToday ? 15 : 9,
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
          ],
        ),
      ),
    );
  }
}
