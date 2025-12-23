import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/data/entities/workout/workout_entity.dart';
import 'package:workout_app/data/entities/workout/workout_exercise_entity.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';
import 'package:workout_app/screens/widgets/exercise_search_bar.dart';

class AddWorkoutScreen extends StatefulWidget {
  final WorkoutEntity? workoutToEdit;
  final DateTime? initialDate;
  const AddWorkoutScreen({super.key, this.workoutToEdit, this.initialDate});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  Timer? _debounceTitle;
  Timer? _debounceNote;
  Timer? _debounceSets;
  Timer? _debounceReps;
  Timer? _debounceWeight;
  int? _selectedExerciseIndex; // Index de l'exo sélectionné (null = aucun)

  @override
  void initState() {
    super.initState();
    if (widget.workoutToEdit != null) {
      context.read<WorkoutBloc>().add(
        LoadWorkoutForEdit(widget.workoutToEdit!),
      );
    } else {
      context.read<WorkoutBloc>().add(HasCache(widget.initialDate));
    }
  }

  @override
  void dispose() {
    _debounceTitle?.cancel();
    _debounceNote?.cancel();
    _debounceSets?.cancel();
    _debounceReps?.cancel();
    _debounceWeight?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutBloc, WorkoutState>(
      listenWhen: (previous, current) =>
          // Ici on compare avec previous car sinon le listener serait appelé à CHAQUE rebuild, même si saveWorkoutStatus n'a pas changé (serait appelé des que currentWorkout change => MAUVAIS)
          previous.saveWorkoutStatus != current.saveWorkoutStatus ||
          previous.cacheStatus != current.cacheStatus ||
          previous.deleteWorkoutStatus != current.deleteWorkoutStatus,
      listener: (context, state) async {
        if (state.cacheStatus == CacheStatus.found) {
          final resume = _showCacheDialog();
          // pour éviter les erreurs d'index invalide, et donc d'affichage d'UI.
          setState(() {
            _selectedExerciseIndex = null;
          });
          if (resume == true) {
            if (mounted) {
              context.read<WorkoutBloc>().add(ResumeCache());
            }
          } else {
            if (mounted) {
              context.read<WorkoutBloc>().add(NewCache());
            }
          }
        }
        if (state.cacheStatus == CacheStatus.failure &&
            state.cacheErrorString != null) {
          showSnackBar(state.cacheErrorString!, Colors.orange);
        }
        // Cet état est bien dans un listenWhen car continent une navigation (dans un builder => bug)
        if (state.saveWorkoutStatus == SaveWorkoutStatus.success &&
            state.saveWorkoutSuccessString != null) {
          showSnackBar(state.saveWorkoutSuccessString!, Colors.green);
          // Permet de retourner à MainScreen peu importe d'où on ouvre cette page
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state.saveWorkoutStatus == SaveWorkoutStatus.failure &&
            state.saveWorkoutErrorString != null) {
          showSnackBar(state.saveWorkoutErrorString!, Colors.orange);
          // 'microtask' pour émettre après le listener
          Future.microtask(() {
            context.read<WorkoutBloc>().add(ResetSaveStatus());
          });
        }
        if (state.deleteWorkoutStatus == DeleteWorkoutStatus.success) {
          showSnackBar(state.deleteWorkoutSuccessString!, Colors.green);
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state.deleteWorkoutStatus == DeleteWorkoutStatus.failure) {
          showSnackBar(state.deleteWorkoutErrorString!, Colors.orange);
          Future.microtask(() {
            context.read<WorkoutBloc>().add(ResetDeleteStatus());
          });
        }
      },
      builder: (context, state) {
        if (state.cacheStatus == CacheStatus.loading ||
            state.saveWorkoutStatus == SaveWorkoutStatus.saving) {
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
        final workout = state.currentWorkout;
        final exerciseToDisplay = workout.exercises;
        return Scaffold(
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xfffaedcd),
                ),
                SingleChildScrollView(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Text(
                                  widget.workoutToEdit == null
                                      ? "AJOUTER UN WORKOUT : "
                                      : 'MODIFIER LE WORKOUT :',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      56,
                                      54,
                                      54,
                                    ),
                                    fontSize: 20,
                                    fontFamily: 'Quadrat',
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              SizedBox(width: 7),
                              if (widget.workoutToEdit != null)
                                CustomIconButton(
                                  onTap: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                          'Supprimer le workout actuel ?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Non'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Oui'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true && mounted) {
                                      context.read<WorkoutBloc>().add(
                                        DeleteWorkout(workout!),
                                      );
                                    }
                                  },
                                  size: 30,
                                  color: Colors.transparent,
                                  icon: Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: const Color.fromARGB(
                                      255,
                                      224,
                                      96,
                                      87,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          SizedBox(height: 15),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(179, 240, 225, 185),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                15,
                                10,
                                15,
                                15,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CustomIconButton(
                                        icon: const FaIcon(
                                          FontAwesomeIcons.stopwatch,
                                          size: 23,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "WORKOUT :",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      CustomIconButton(
                                        onTap: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                'Réinitialiser tous les champs ?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text('Non'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text('Oui'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true && mounted) {
                                            context.read<WorkoutBloc>().add(
                                              ResetToEmptyWorkout(),
                                            );
                                          }
                                        },
                                        size: 35,
                                        icon: Icon(
                                          Icons.restart_alt_sharp,
                                          size: 15,
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
                                                          workout.title,
                                                      decoration:
                                                          InputDecoration(
                                                            hintText: "Titre",
                                                            isDense: true,
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                  8,
                                                                ),
                                                          ),
                                                      keyboardType:
                                                          TextInputType.text,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                      ),
                                                      onChanged: (query) {
                                                        _debounceTitle
                                                            ?.cancel();
                                                        _debounceTitle = Timer(
                                                          const Duration(
                                                            milliseconds: 1000,
                                                          ),
                                                          () {
                                                            if (query.length >
                                                                2) {
                                                              context
                                                                  .read<
                                                                    WorkoutBloc
                                                                  >()
                                                                  .add(
                                                                    UpdateWorkoutDetails(
                                                                      title:
                                                                          query,
                                                                    ),
                                                                  );
                                                            }
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 7),
                                              GestureDetector(
                                                onTap: () async {
                                                  final selectedDate =
                                                      await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            workout.date,
                                                        firstDate: DateTime(
                                                          2020,
                                                        ),
                                                        lastDate: DateTime(
                                                          2030,
                                                        ),
                                                      );
                                                  if (selectedDate != null) {
                                                    context
                                                        .read<WorkoutBloc>()
                                                        .add(
                                                          UpdateWorkoutDetails(
                                                            date: selectedDate,
                                                          ),
                                                        );
                                                  }
                                                },
                                                child: Container(
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                      179,
                                                      231,
                                                      206,
                                                      138,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8.0,
                                                          ),
                                                      child: Center(
                                                        child: Text(
                                                          DateFormat(
                                                            'dd/MM/yyyy',
                                                          ).format(
                                                            workout.date,
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                              ),
                                                        ),
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
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Center(
                                                child: TextFormField(
                                                  key: ValueKey(
                                                    'workout_note_${DateTime.now().toString()}',
                                                  ),
                                                  initialValue: workout.note,
                                                  decoration: InputDecoration(
                                                    hintText: "Note",
                                                    isDense: true,
                                                    contentPadding:
                                                        EdgeInsets.all(8),
                                                  ),
                                                  keyboardType:
                                                      TextInputType.multiline,
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
                                                            .read<WorkoutBloc>()
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
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),

                          // ------------------------ EXERCISE SECTION --------------------------
                          Container(
                            height: 185,
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
                                      CustomIconButton(
                                        icon: const FaIcon(
                                          FontAwesomeIcons.dumbbell,
                                          size: 25,
                                        ),
                                        size: 45,
                                      ),

                                      SizedBox(width: 10),
                                      Text(
                                        "Exercices :",
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  Expanded(
                                    child: exerciseToDisplay.isEmpty
                                        ? const Center(
                                            child: Text(
                                              "Aucun exercice",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                        : ListView.builder(
                                            itemCount: exerciseToDisplay.length,
                                            itemBuilder: (_, index) {
                                              final ex =
                                                  exerciseToDisplay[index];
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
                                                onLongPress: () {
                                                  setState(() {
                                                    _selectedExerciseIndex =
                                                        isSelected
                                                        ? null
                                                        : index;
                                                  });
                                                  context
                                                      .read<WorkoutBloc>()
                                                      .add(
                                                        RemoveExercise(
                                                          exerciseId:
                                                              ex.exercise.id,
                                                        ),
                                                      );
                                                },
                                                child: Card(
                                                  color: isSelected
                                                      ? Colors.orange[200]
                                                      : Colors.white,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          3.0,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Image.network(
                                                          ex.exercise.imageUrl,
                                                          width: 45,
                                                          height: 45,
                                                          fit: BoxFit.contain,
                                                        ),
                                                        SizedBox(width: 5),
                                                        Expanded(
                                                          child: Text(
                                                            ex.exercise.name,
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              letterSpacing:
                                                                  -0.5,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
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
                          SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            height: 175,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(179, 240, 225, 185),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                15,
                                20,
                                15,
                                12,
                              ),
                              // "_selectedExerciseIndex! >= workout.exercices.length" => 1 >= 1  → true → Affiche "Sélectionne un exercice" au lieu de crasher
                              child:
                                  _selectedExerciseIndex == null ||
                                      exerciseToDisplay.isEmpty ||
                                      _selectedExerciseIndex! >=
                                          exerciseToDisplay.length
                                  ? const Center(
                                      child: Text(
                                        "Sélectionnez un exercice",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : _buildExerciseDetails(
                                      exerciseToDisplay[_selectedExerciseIndex!],
                                      _selectedExerciseIndex!,
                                    ),
                            ),
                          ),
                          SizedBox(height: 10),
                          ExerciseSearchBar(workout),
                          SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<WorkoutBloc>().add(
                                  SubmitWorkout(),
                                );
                              },
                              icon: Icon(Icons.add, color: Colors.white),
                              label: Text(
                                widget.workoutToEdit == null
                                    ? "Ajouter un workout"
                                    : 'Modifier le workout',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                backgroundColor: const Color.fromARGB(
                                  197,
                                  233,
                                  187,
                                  21,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildExerciseDetails(WorkoutExerciseEntity w, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Row(
              children: [
                CustomIconButton(
                  icon: Icon(Icons.document_scanner, size: 20),
                  size: 35,
                ),
                SizedBox(width: 10),
                Text("Sets", style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 15),
            SizedBox(
              width: 80,
              height: 80,
              child: SleekCircularSlider(
                min: 1,
                max: 10,
                initialValue: w.sets.toDouble(),
                appearance: CircularSliderAppearance(
                  size: 80,
                  customColors: CustomSliderColors(
                    trackColor: const Color.fromARGB(255, 248, 243, 243),
                    progressBarColor: Colors.black,
                    dotColor: Colors.black,
                  ),
                  customWidths: CustomSliderWidths(
                    trackWidth: 3,
                    progressBarWidth: 3,
                    handlerSize: 5,
                  ),
                  infoProperties: InfoProperties(
                    mainLabelStyle: TextStyle(fontSize: 30),
                    modifier: (double value) => '${value.toInt()}',
                  ),
                ),
                onChange: (value) {
                  _debounceSets?.cancel();
                  _debounceSets = Timer(const Duration(milliseconds: 1000), () {
                    context.read<WorkoutBloc>().add(
                      UpdateExerciseDetails(
                        exIndex: index,
                        sets: value.toInt(),
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(width: 15),
        Column(
          children: [
            Row(
              children: [
                CustomIconButton(icon: Icon(Icons.repeat, size: 20), size: 35),
                SizedBox(width: 10),
                Text("Reps", style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 15),
            SizedBox(
              width: 80,
              height: 80,
              child: SleekCircularSlider(
                min: 1,
                max: 20,
                initialValue: w.reps.toDouble(),
                appearance: CircularSliderAppearance(
                  size: 80,
                  customColors: CustomSliderColors(
                    trackColor: const Color.fromARGB(255, 248, 243, 243),
                    progressBarColor: Colors.black,
                    dotColor: Colors.black,
                  ),
                  customWidths: CustomSliderWidths(
                    trackWidth: 3,
                    progressBarWidth: 3,
                    handlerSize: 5,
                  ),
                  infoProperties: InfoProperties(
                    mainLabelStyle: TextStyle(fontSize: 30),
                    modifier: (double value) => '${value.toInt()}',
                  ),
                ),
                onChange: (value) {
                  _debounceReps?.cancel();
                  _debounceReps = Timer(const Duration(milliseconds: 1000), () {
                    context.read<WorkoutBloc>().add(
                      UpdateExerciseDetails(
                        exIndex: index,
                        reps: value.toInt(),
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(width: 15),
        Column(
          children: [
            Row(
              children: [
                CustomIconButton(
                  icon: FaIcon(FontAwesomeIcons.weightHanging, size: 17),
                  size: 35,
                ),
                SizedBox(width: 10),
                Text("Weight", style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 15),
            SizedBox(
              width: 80,
              height: 80,
              child: SleekCircularSlider(
                min: 1,
                max: 150,
                initialValue: w.weight.toDouble(),
                appearance: CircularSliderAppearance(
                  size: 80,
                  customColors: CustomSliderColors(
                    trackColor: const Color.fromARGB(255, 248, 243, 243),
                    progressBarColor: Colors.black,
                    dotColor: Colors.black,
                  ),
                  customWidths: CustomSliderWidths(
                    trackWidth: 3,
                    progressBarWidth: 3,
                    handlerSize: 5,
                  ),
                  infoProperties: InfoProperties(
                    mainLabelStyle: TextStyle(fontSize: 30),
                    modifier: (double value) => '${value.toInt()}',
                  ),
                ),
                onChange: (value) {
                  _debounceWeight?.cancel();
                  _debounceWeight = Timer(
                    const Duration(milliseconds: 1000),
                    () {
                      context.read<WorkoutBloc>().add(
                        UpdateExerciseDetails(
                          exIndex: index,
                          weight: value.toInt(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
          textColor: Colors.white,
        ),
      ),
    );
  }

  Future<bool?> _showCacheDialog() async {
    // Techniquement, quand le showDialog s’affiche, il crée une nouvelle route Flutter (par-dessus la page actuelle).
    // Modifier le state de la page principale pendant que cette route est au-dessus (avant le Navigator.pop) peut causer des comportements indéterminés (warnings ou rebuilds mal synchronisés).
    // En gérant le setState après le await showDialog, on garantit :
    // que le widget parent est toujours mounted,
    // que tu mets à jour ton état dans le bon cycle de build.
    return await showDialog<bool>(
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
  }
}
