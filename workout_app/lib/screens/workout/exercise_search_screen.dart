import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/core/constants/app_constants.dart';
import 'package:workout_app/screens/widgets/custom_icon_button.dart';

class ExerciseSearchScreen extends StatefulWidget {
  const ExerciseSearchScreen({super.key});

  @override
  State<ExerciseSearchScreen> createState() => _ExerciseSearchScreenState();
}

class _ExerciseSearchScreenState extends State<ExerciseSearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceExerciseSearch;
  final _searchFocus = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _showSuggestions = _searchController.text.length > 2;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _debounceExerciseSearch?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: BoxDecoration(gradient: AppColors.screenBackground),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 10, 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(127, 248, 249, 248),
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.small,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(15, 4, 12, 4),
                            child: Row(
                              children: [
                                Icon(Icons.search),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    focusNode: _searchFocus,
                                    cursorColor: Colors.black,
                                    cursorWidth: 1.0,
                                    cursorHeight: 18.0,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-ZÀ-ÿ\s]'),
                                      ),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: 'Rechercher',
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    style: TextStyle(
                                      fontSize: 19,
                                      color: Colors.black,
                                    ),
                                    onChanged: (query) {
                                      _debounceExerciseSearch?.cancel();
                                      _debounceExerciseSearch = Timer(
                                        const Duration(milliseconds: 500),
                                        () {
                                          context.read<WorkoutBloc>().add(
                                            SearchExercises(query),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                CustomIcon(
                                  onTap: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                  size: 25,
                                  icon: FaIcon(
                                    FontAwesomeIcons.remove,
                                    size: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      CustomIcon(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        color: Colors.transparent,
                        icon: FaIcon(FontAwesomeIcons.remove, size: 22),
                      ),
                    ],
                  ),
                ),
                _buildExerciseListItemContainer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseListItemContainer() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.large),
            topRight: Radius.circular(AppBorderRadius.large),
          ),
          color: const Color.fromARGB(141, 255, 255, 255),
        ),
        child: AnimatedCrossFade(
          crossFadeState: _showSuggestions
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
          firstChild: BlocBuilder<WorkoutBloc, WorkoutState>(
            builder: (context, state) {
              if (state.searchExercisesStatus ==
                  SearchExercisesStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.searchExercisesStatus ==
                  SearchExercisesStatus.failure) {
                return Center(
                  child: Text(
                    "${state.fetchExercisesErrorString}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              if (state.searchExercisesStatus ==
                  SearchExercisesStatus.success) {
                if (state.exercisesList.isEmpty) {
                  return const Center(child: Text("No result found"));
                }
                return ListView.builder(
                  itemCount: state.exercisesList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final ex = state.exercisesList[index];
                    final isAlreadyInWorkout = state.currentWorkout.exercises
                        .any((workoutEx) => workoutEx.exercise.id == ex.id);
                    if (isAlreadyInWorkout) {
                      return ListTile(
                        leading: Image.network(
                          ex.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                          color: Colors.grey,
                        ),
                        title: Text(ex.name),
                        titleTextStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        trailing: IconButton(
                          color: const Color.fromARGB(255, 211, 107, 101),
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            Navigator.pop(context);
                            context.read<WorkoutBloc>().add(
                              RemoveExercise(exerciseId: ex.id),
                            );
                          },
                        ),
                      );
                    }
                    return ListTile(
                      hoverColor: const Color.fromARGB(255, 37, 35, 35),
                      leading: SizedBox(
                        width: 50,
                        height: 50,
                        child: CachedNetworkImage(
                          imageUrl: ex.imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                                color: const Color.fromARGB(255, 167, 106, 84),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.fitness_center,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      title: Text(ex.name),
                      titleTextStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.read<WorkoutBloc>().add(
                          AddExercise(exercise: ex),
                        );
                        _searchController.clear();
                        _debounceExerciseSearch?.cancel();
                        setState(() {
                          _showSuggestions = false;
                        });
                        _searchFocus.unfocus();
                      },
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
          secondChild: BlocBuilder<WorkoutBloc, WorkoutState>(
            builder: (context, state) {
              if (_searchController.text.length <= 2) {
                return Expanded(
                  child: Center(child: Text("Rechercher un exercice")),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
