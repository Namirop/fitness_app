import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/data/entities/workout_exercice_entity.dart';
import 'package:workout_app/screens/widgets/exercise_search_bar.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  Timer? _debounceTitle;
  Timer? _debounceNote;
  int? _selectedExerciseIndex; // Index de l'exo sélectionné (null = aucun)

  @override
  void initState() {
    super.initState();
    // Permet d’exécuter une fonction à chaque fois que le texte change dans le TextField.
    // Ici '_showSuggestions' devient true quand il y a + de 2 caractères dans le TextField
    // Ce qui permet de redessiner l’interface en conséquence
    // Sans 'setState', la variable _showSuggestions changerait, mais le widget ne serait jamais reconstruit → rien ne bougerait à l’écran.
    // Le 'addListener' toujours dans le 'initState' car bon moment pour initialiser des objets et leur attacher des listeners.
    // tout ce qu'on connectes ici, on le déconnecte dans 'dispose()'.
    context.read<WorkoutBloc>().add(HasCache());
  }

  @override
  void dispose() {
    _debounceTitle?.cancel();
    _debounceNote?.cancel();
    super.dispose();
  }

  // Pourquoi un BlocConsumer : combine un BlocListener et un BlocBuilder, et ici on a besoin d'un listener pour montrer un effet visuel ponctuel (dialog, snackbar, navigation, faire vibrer le tel, etc.)
  // Donc ici pertinent de mettre tout ça dans un listenWhen car pas besoin de rebuild l'UI.
  // Typiquement, on utilisera un BlocConsumer pour :
  // - Formulaires avec validation (afficher erreurs + snackbar)
  // - Création/Édition (afficher données + navigation après succès)
  // - Toute page avec UI + effets de bord
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutBloc, WorkoutState>(
      // 'listener:' est une fonction appelée quand 'listenWhen' match.
      listenWhen: (previous, current) =>
          current is CacheFound ||
          current is WorkoutValidationError ||
          current is WorkoutSaved ||
          current is WorkoutSavedError,
      listener: (context, state) async {
        if (state is CacheFound) {
          // Techniquement, quand le showDialog s’affiche, il crée une nouvelle route Flutter (par-dessus la page actuelle).
          // Modifier le state de la page principale pendant que cette route est au-dessus (avant le Navigator.pop) peut causer des comportements indéterminés (warnings ou rebuilds mal synchronisés).
          // En gérant le setState après le await showDialog, on garantit :
          // que le widget parent est toujours mounted,
          // que tu mets à jour ton état dans le bon cycle de build.
          final resume = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Reprendre le workout en cours ?'),
              content: const Text(
                'Un brouillon a été trouvé. Voulez-vous le continuer ?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Non, nouveau'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Oui, reprendre'),
                ),
              ],
            ),
          );
          // pour éviter les erreurs d'index invalide, et donc d'affichage d'UI.j'uti
          setState(() {
            _selectedExerciseIndex = null;
          });
          if (resume == true) {
            context.read<WorkoutBloc>().add(ResumeCache());
          } else {
            context.read<WorkoutBloc>().add(NewCache());
          }
        }

        if (state is WorkoutValidationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
                textColor: Colors.white,
              ),
            ),
          );
        }

        // Cet état est bien dans un listenWhen car continent une navigation (dans un builder => bug)
        if (state is WorkoutSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color.fromARGB(255, 153, 207, 155),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
                textColor: Colors.white,
              ),
            ),
          );
          Navigator.pop(context);
        }

        if (state is WorkoutSavedError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color.fromARGB(255, 236, 91, 81),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
                textColor: Colors.white,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is CacheLoading || state is SavingWorkout) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xfffaedcd),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final workout = state.workout;
        return Scaffold(
          body: GestureDetector(
            onTap: () => FocusScope.of(
              context,
            ).unfocus(), // Pour la fermerture du clavier
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xfffaedcd),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ADD A WORKOUT : ",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(179, 240, 225, 185),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.white60,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(15),
                                        ),
                                      ),
                                      child: Center(
                                        child: const FaIcon(
                                          FontAwesomeIcons.stopwatch,
                                          size: 19,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "WORKOUT :",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                SizedBox(
                                  height: 140,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                  179,
                                                  231,
                                                  206,
                                                  138,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Center(
                                                  child: TextFormField(
                                                    key: ValueKey(
                                                      'workout_title_${DateTime.now().toString()}',
                                                    ),
                                                    initialValue:
                                                        workout?.title,
                                                    decoration: InputDecoration(
                                                      hintText: "Titre",
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.all(8),
                                                    ),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                    ),
                                                    onChanged: (value) {
                                                      _debounceTitle?.cancel();
                                                      _debounceTitle = Timer(
                                                        const Duration(
                                                          milliseconds: 1000,
                                                        ),
                                                        () {
                                                          context
                                                              .read<
                                                                WorkoutBloc
                                                              >()
                                                              .add(
                                                                UpdateWorkoutDetails(
                                                                  title: value,
                                                                ),
                                                              );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 7),
                                            Container(
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                  179,
                                                  231,
                                                  206,
                                                  138,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Center(
                                                    child: TextFormField(
                                                      key: ValueKey(
                                                        'workout_note_${DateTime.now().toString()}',
                                                      ),
                                                      initialValue:
                                                          workout?.note,
                                                      decoration:
                                                          InputDecoration(
                                                            hintText: "Note",
                                                            isDense: true,
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                  8,
                                                                ),
                                                          ),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                      ),
                                                      onChanged: (value) {
                                                        _debounceNote?.cancel();
                                                        _debounceNote = Timer(
                                                          const Duration(
                                                            milliseconds: 500,
                                                          ),
                                                          () {
                                                            context
                                                                .read<
                                                                  WorkoutBloc
                                                                >()
                                                                .add(
                                                                  UpdateWorkoutDetails(
                                                                    note: value,
                                                                  ),
                                                                );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            final selectedDate =
                                                await showDatePicker(
                                                  context: context,
                                                  initialDate:
                                                      workout?.date ??
                                                      DateTime.now(),
                                                  firstDate: DateTime(2020),
                                                  lastDate: DateTime(2030),
                                                );
                                            if (selectedDate != null) {
                                              context.read<WorkoutBloc>().add(
                                                UpdateWorkoutDetails(
                                                  date: selectedDate,
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                179,
                                                231,
                                                206,
                                                138,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Text(
                                                workout?.date != null
                                                    ? DateFormat(
                                                        'dd/MM/yyyy',
                                                      ).format(workout!.date)
                                                    : 'DATE',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // ------------------------ EXERCISE SECTION --------------------------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: 175,
                              height: 175,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(179, 240, 225, 185),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  10,
                                  10,
                                  12,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.white60,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(15),
                                            ),
                                          ),
                                          child: Center(
                                            child: const FaIcon(
                                              FontAwesomeIcons.dumbbell,
                                              size: 17,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Exercise",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child:
                                          workout == null ||
                                              workout.exercices.isEmpty
                                          ? const Center(
                                              child: Text(
                                                "Aucun exercise",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount:
                                                  workout.exercices.length,
                                              itemBuilder: (_, index) {
                                                final workoutEx =
                                                    workout.exercices[index];
                                                final isSelected =
                                                    _selectedExerciseIndex ==
                                                    index;
                                                return GestureDetector(
                                                  onDoubleTap: () {
                                                    // Si déjà sélectionné, on désélectionne, sinon, on sélectionne
                                                    setState(() {
                                                      _selectedExerciseIndex =
                                                          isSelected
                                                          ? null
                                                          : index;
                                                    });
                                                  },
                                                  child: Card(
                                                    color: isSelected
                                                        ? Colors.orange[200]
                                                        : Colors.white,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4.0,
                                                          ),
                                                      child: Image.network(
                                                        workoutEx
                                                            .exercise
                                                            .imageUrl,
                                                        width: 40,
                                                        height: 40,
                                                        fit: BoxFit.contain,
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
                            Container(
                              width: 175,
                              height: 175,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(179, 240, 225, 185),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  15,
                                  10,
                                  12,
                                ),
                                // "_selectedExerciseIndex! >= workout.exercices.length" => 1 >= 1  → true → Affiche "Sélectionne un exercice" au lieu de crasher
                                child:
                                    _selectedExerciseIndex == null ||
                                        workout == null ||
                                        workout.exercices.isEmpty ||
                                        _selectedExerciseIndex! >=
                                            workout.exercices.length
                                    ? const Center(
                                        child: Text(
                                          "Sélectionne un exercice",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    : _buildExerciseDetails(
                                        workout
                                            .exercices[_selectedExerciseIndex!],
                                        _selectedExerciseIndex!,
                                      ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // ----------------------- SEARCH BAR -----------------------------------
                        ExerciseSearchBar(workout),
                        FloatingActionButton(
                          onPressed: () {
                            context.read<WorkoutBloc>().add(AddWorkout());
                          },
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExerciseDetails(WorkoutExerciceEntity workoutEx, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          workoutEx.exercise.name,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Sets:', style: TextStyle(fontSize: 11)),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                // On utilise une clé car sinon Flutter réutilise le widget au lieu de le recréer, la clé permet de différencier les deux TF et de ce fait Flutter en recrée.
                key: ValueKey('sets_$index'),
                initialValue: workoutEx.sets.toString(),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.all(8),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 11),
                onChanged: (value) {
                  context.read<WorkoutBloc>().add(
                    UpdateExerciseDetails(
                      exIndex: index,
                      sets: int.tryParse(value) ?? 0,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text('Reps:', style: TextStyle(fontSize: 11)),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                key: ValueKey('reps_$index'),
                initialValue: "${workoutEx.reps}",
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 11),
                onChanged: (value) {
                  context.read<WorkoutBloc>().add(
                    UpdateExerciseDetails(
                      exIndex: index,
                      reps: int.tryParse(value) ?? 0,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Weight
        /* Row(
        children: [
          const Text('Weight:', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(8),
                border: OutlineInputBorder(),
                suffixText: 'kg',
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 11),
              onChanged: (value) {
                // TODO: Update weight
              },
            ),
          ),
        ],
      ), */
      ],
    );
  }
}
