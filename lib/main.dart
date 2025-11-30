import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/data/entities/exercice_entity.dart';
import 'package:workout_app/data/entities/workout_entity.dart';
import 'package:workout_app/data/entities/workout_exercice_entity.dart';
import 'package:workout_app/data/repositories/api_repository.dart';
import 'package:workout_app/data/services/workout_cache_service.dart';
import 'package:workout_app/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  // Indique à l'app que Hive est utilisé
  await Hive.initFlutter();

  // Décommenter quand on fait une modif Hive
  //await Hive.deleteBoxFromDisk('draftWorkout');

  Hive.registerAdapter(WorkoutEntityAdapter());
  Hive.registerAdapter(WorkoutExerciceEntityAdapter());
  Hive.registerAdapter(ExerciceEntityAdapter());

  // Pourquoi on initialise hive dans le main et pas dans le build ou autre => car c'est une initialisation asynchrone, ce que l'on ne peut pas faire dans un build
  // Et on ne veut qu'une seule instance de la box Hive, on le fait donc ici pour ensuite l'injecter dans le build juste en dessous
  // On instancie donc pas le repo, le cache et la box dans le BLoC mais à l'exterieur (ici), ce qui est mieux, et une seule fois (singleton)
  final box = await Hive.openBox<WorkoutEntity>('draftWorkout'); // ouverture ici une seule fois
  runApp(MyApp(box: box));
}

class MyApp extends StatelessWidget {
  final Box<WorkoutEntity> box;
  const MyApp({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => WorkoutBloc(
        repository: ApiRepository(),
        cacheService: WorkoutCacheService(box)
      ))],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: "Michroma",
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
