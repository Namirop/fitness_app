import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_bloc.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_event.dart';
import 'package:workout_app/blocs/WorkoutBloc/workout_state.dart';
import 'package:workout_app/data/entities/workout_entity.dart';

class ExerciseSearchBar extends StatefulWidget {
  final WorkoutEntity? workout;
  const ExerciseSearchBar(this.workout);

  @override
  State<ExerciseSearchBar> createState() => _ExerciseSearchBarState();
}

class _ExerciseSearchBarState extends State<ExerciseSearchBar> {
  // Variables pas dans le build car sinon seront recréés en boucle, et on perdra leur états.
  // 'late' indique qu'on ne peux pas l'initialiser au moment de sa déclaration, mais qu'on garantis qu’elle sera prête avant le build => l'initialiser dans 'initState'
  // 'TextEditingController', 'FocusNode', 'ScrollController' → toujours 'final' car on veux garder le même objet tout au long du cycle de vie du widget
  final _controller = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounceSearchExercise;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _showSuggestions = _controller.text.length > 2;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchFocus.dispose();
    _debounceSearchExercise?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _controller,
            focusNode: _searchFocus,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search an exercise',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (query) {
              _debounceSearchExercise?.cancel();
              _debounceSearchExercise = Timer(
                const Duration(milliseconds: 500),
                () {
                  if (query.length > 2) {
                    context.read<WorkoutBloc>().add(FetchExercices(query));
                  }
                },
              );
            },
          ),
        ),
        AnimatedCrossFade(
          crossFadeState: _showSuggestions
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
          firstChild: SizedBox(
            height: 200,
            child: BlocBuilder<WorkoutBloc, WorkoutState>(
              builder: (context, state) {
                if (_controller.text.isEmpty) {
                  return const SizedBox();
                }
                if (state is FetchExercicesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is FetchExercicesFailure) {
                  return Center(
                    child: Text(
                      "Erreur : ${state.message}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (state is FetchExercicesSuccess) {
                  if (state.exercices.isEmpty) {
                    return const Center(child: Text("No result found"));
                  }
                  return ListView.builder(
                    itemCount: state.exercices.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final ex = state.exercices[index];
                      final isAlreadyInWorkout = widget.workout!.exercices.any(
                        (workoutEx) => workoutEx.exercise.id == ex.exerciseId,
                      );
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
                              context.read<WorkoutBloc>().add(
                                RemoveExercise(ex.exerciseId),
                              );
                              setState(() {});
                            },
                          ),
                        );
                      }
                      return ListTile(
                        hoverColor: const Color.fromARGB(255, 37, 35, 35),
                        leading: Image.network(
                          ex.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        title: Text(ex.name),
                        titleTextStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        onTap: () {
                          context.read<WorkoutBloc>().add(
                            AddExerciseToCache(ex.exerciseId),
                          );
                          _controller.clear();
                          _debounceSearchExercise?.cancel();
                          setState(() {
                            () => _showSuggestions = false;
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
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}
