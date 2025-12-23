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
import 'package:workout_app/data/repositories/workout_repository.dart';
import 'package:workout_app/data/services/profil_cache_service.dart';
import 'package:workout_app/data/services/workout_cache_service.dart';
import 'package:workout_app/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('fr_FR', null);
  // Indique à l'app que Hive est utilisé
  await Hive.initFlutter();

  // Décommenter quand on fait une modif Hive
  //await Hive.deleteBoxFromDisk('draftWorkout');

  Hive.registerAdapter(WorkoutEntityAdapter());
  Hive.registerAdapter(WorkoutExerciceEntityAdapter());
  Hive.registerAdapter(ExerciceEntityAdapter());
  Hive.registerAdapter(ProfilEntityAdapter());

  // Pourquoi on initialise hive dans le main et pas dans le build ou autre => car c'est une initialisation asynchrone, ce que l'on ne peut pas faire dans un build
  // Et on ne veut qu'une seule instance de la box Hive, on le fait donc ici pour ensuite l'injecter dans le build juste en dessous
  // On instancie donc pas le repo, le cache et la box dans le BLoC mais à l'exterieur (ici), ce qui est mieux, et une seule fois (singleton)
  final workoutBox = await Hive.openBox<WorkoutEntity>(
    'draftWorkout',
  ); // ouverture ici une seule fois
  final profilBox = await Hive.openBox<ProfilEntity>('draftProfil');
  runApp(MyApp(workoutBox: workoutBox, profilBox: profilBox));
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
          create: (context) => WorkoutBloc(
            repository: WorkoutRepository(),
            cacheService: WorkoutCacheService(workoutBox),
          ),
        ),
        BlocProvider(
          create: (context) => NutritionBloc(repository: NutritionRepository()),
        ),
        BlocProvider(
          create: (context) =>
              ProfilBloc(cacheService: ProfilCacheService(profilBox)),
        ),
        BlocProvider(create: (context) => NavigationCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(fontFamily: "Barlow"),
        home: const HomeScreen(),
      ),
    );
  }
}
