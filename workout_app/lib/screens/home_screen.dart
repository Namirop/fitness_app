import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_app/cubit/navigation_cubit.dart';
import 'package:workout_app/screens/calendar/calendar_screen.dart';
import 'package:workout_app/screens/main/main_screen.dart';
import 'package:workout_app/screens/nutrition/nutrition_main_screen.dart';
import 'package:workout_app/screens/profil/profil_screen.dart';
import 'package:workout_app/screens/widgets/custom_bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentScreen = 0;

  final List<Widget> bnbSreens = [
    const MainScreen(),
    const CalendarScreen(),
    const NutritionScreen(),
    const ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, currentScreen) {
        return Scaffold(
          extendBody: true,
          body: bnbSreens[currentScreen],
          bottomNavigationBar: CustomBottomNavigationBar(
            currentScreen: currentScreen,
            onTap: (index) => context.read<NavigationCubit>().goToPage(index),
          ),
        );
      },
    );
  }
}
