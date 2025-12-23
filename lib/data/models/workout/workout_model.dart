import 'package:workout_app/data/entities/workout/workout_entity.dart';
import 'package:workout_app/data/models/workout/workout_exercise_model.dart';

// WorkoutModel hérite de WorkoutEntity, càd qu'il possède les propriétés de WorkoutEntity (id, title, date).
// WorkoutModel ajoute par-dessus des choses spécifiques, ici surtout la conversion JSON.
class WorkoutModel extends WorkoutEntity {
  // Constructeur :
  WorkoutModel({
    required super.id,
    required super.title,
    required super.note,
    required super.date,
    required super.exercises,
  });

  factory WorkoutModel.fromEntity(WorkoutEntity entity) {
    return WorkoutModel(
      id: entity.id,
      title: entity.title,
      note: entity.note,
      date: entity.date,
      exercises: entity.exercises,
    );
  }

  // "factory" indique que le constructeur "WorkoutModel" ne crée pas forcément un nouvel objet directement comme un new.
  // Cette fonction lit un Map JSON et le transforme en un objet WorkoutModel.
  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'].toString(),
      title: json['title'],
      note: json['note'],
      date: DateTime.parse(json['date']),
      // 'json['exercises'] => le type renvoyé est dynamic, et pour pouvoir appeler un 'map' il nous faut un type List.
      // Donc on dit explicitement a Dart qu'il doit considérer ça comme une List.
      // Ensuite le '.toList()' comme on l'a vu permet de convertir un Iterable (ce qui est renvoyer par un map par défaut) en une liste, car c'est ce qui est demandé dans le modèle ("List<WorkoutExerciceEntity>")
      exercises: (json['exercises'] as List)
          .map((ex) => WorkoutExerciseModel.fromJson(ex))
          .toList(),
    );
  }

  // Cette fonction prends l'objet et le sérialise en un Map que l'on peux envoyer à une API, Firebase, etc.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'date': date.toUtc().toIso8601String(),
      'exercises': exercises
          .map((ex) => WorkoutExerciseModel.fromEntity(ex).toJson())
          .toList(),
    };
  }
}

// Le Model est lié à la source de données (JSON, DB).
// Si tu changes ton backend ou la façon dont tu stockes les données, tu ne veux pas que ton UI ou Bloc soit impacté.
// L’UI/Bloc manipule les Entities, le Model s’occupe de la conversion.
// Donc dans l'UI, on utilisera WorkoutEntity, qui fonctionnera dans tout les cas vu qu'il étend WorkoutModel.
// => comme WorkoutModel hérite de WorkoutEntity, tu peux le traiter comme un WorkoutEntity partout où tu en as besoin.
