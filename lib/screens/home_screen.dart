import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:workout_app/screens/navbar/daily_goals_screen.dart';
import 'package:workout_app/screens/navbar/main_screen.dart';
import 'package:workout_app/screens/navbar/nutrition_screen.dart';
import 'package:workout_app/screens/navbar/workout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int currentScreen = 0;

  final List<Widget> screens = [
    const MainScreen(),
    const WorkoutScreen(),
    const NutritionScreen(),
    const DailyGoalsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // autorise le body à s'étendre derrière la nav bar
      body: screens[currentScreen],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.transparent, // enlève le fond sous l’icône actif
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          child: NavigationBar(
            backgroundColor: Colors.black,
            height: 60,
            onDestinationSelected: (value) {
              setState(() {
                currentScreen = value;
              });
            },
            destinations: [
              NavigationDestination(
                icon: FaIcon(FontAwesomeIcons.house,
                  size: 20,
                  color: currentScreen == 0 
                         ? Color(0xfffaedcd)
                         : Colors.grey
                  ), 
                label: ''
              ),
              NavigationDestination(
                icon: FaIcon(
                  FontAwesomeIcons.dumbbell,
                  size: 20,
                  color: currentScreen == 1 
                         ? Color(0xfffaedcd)
                         : Colors.grey
                  ), 
                label: ''
              ),
              NavigationDestination(
                icon: FaIcon(
                  FontAwesomeIcons.bowlFood, 
                  size: 20,
                  color: currentScreen == 2 
                         ? Color(0xfffaedcd)
                         : Colors.grey
                  ), 
                label: ''
              ),
              NavigationDestination(
                icon: FaIcon(FontAwesomeIcons.solidHeart,
                size: 20,
                color: currentScreen == 3 
                         ? Color(0xfffaedcd)
                         : Colors.grey
                ), 
                label: ''
              ),
            ],
          ),
        ),
      )
    );
  }
}