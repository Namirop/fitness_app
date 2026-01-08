import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workout_app/blocs/NutritionBloc/nutrition_bloc.dart';
import 'package:workout_app/blocs/ProfilBloc/profil_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/cubit/navigation_cubit.dart';
import 'package:workout_app/data/entities/profil/profil_entity.dart';
import 'package:workout_app/data/entities/workout/exercise_entity.dart';
import 'package:workout_app/data/entities/workout/workout_entity.dart';
import 'package:workout_app/data/entities/workout/workout_exercise_entity.dart';
import 'package:workout_app/data/repositories/nutrition_repository.dart';
import 'package:workout_app/data/repositories/profil_repository.dart';
import 'package:workout_app/data/repositories/workout_repository.dart';
import 'package:workout_app/data/services/profil_cache_service.dart';
import 'package:workout_app/data/services/workout_cache_service.dart';
import 'package:workout_app/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeDateFormatting('fr_FR', null);
    await Hive.initFlutter();
    //await Hive.deleteBoxFromDisk('draftProfil');
    //await Hive.deleteBoxFromDisk('draftWorkout');
    Hive.registerAdapter(WorkoutEntityAdapter());
    Hive.registerAdapter(WorkoutExerciseEntityAdapter());
    Hive.registerAdapter(ExerciseEntityAdapter());
    Hive.registerAdapter(ProfilEntityAdapter());
    final workoutBox = await Hive.openBox<WorkoutEntity>('draftWorkout');
    final profilBox = await Hive.openBox<ProfilEntity>('draftProfil');
    runApp(MyApp(workoutBox: workoutBox, profilBox: profilBox));
  } catch (e) {
    return runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Erreur d\'initialisation'))),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final Box<WorkoutEntity> workoutBox;
  final Box<ProfilEntity> profilBox;
  const MyApp({super.key, required this.workoutBox, required this.profilBox});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => WorkoutBloc(
            repository: WorkoutRepository(),
            cacheService: WorkoutCacheService(workoutBox),
          ),
        ),
        BlocProvider(
          create: (_) => NutritionBloc(repository: NutritionRepository()),
        ),
        BlocProvider(
          create: (_) => ProfilBloc(
            cacheService: ProfilCacheService(profilBox),
            repository: ProfilRepository(),
          ),
        ),
        BlocProvider(create: (_) => NavigationCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fitness App',
        theme: ThemeData(fontFamily: "Barlow", useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}
