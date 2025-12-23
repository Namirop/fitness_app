// Représente l'objet métier pur, la logique de ton application.
// Il ne dépend pas d’une source de données (API, Firebase, DB locale).
// Je peux l’utiliser partout dans l'app (Bloc, UI) sans me soucier du format JSON.
// C'est cette entité qu'on traitera/manipulera dans notre code coté UI/BLoC, et non "WorkoutModel", qui est lié à la source de données, et qui sert de conversion principalement.

import 'package:hive_flutter/adapters.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_app/data/entities/workout/workout_exercise_entity.dart';

// HIVE :
// 🔹 Hive est une base de données locale (NoSQL) utilisée pour stocker des données directement sur l’appareil, sans serveur.
// ➜ Elle permet de garder des données persistantes (offline) rapidement et simplement.
// Chaque classe que l’on veut stocker dans Hive doit être annotée avec : @HiveType(typeId: X) ➜ "typeId" = identifiant unique pour chaque entité dans tout le projet
// Chaque champ de la classe est annoté avec : @HiveField(n) ➜ "n" = index du champ (ne jamais modifier après création, sinon les données cassent).
// La ligne : part 'xxx.g.dart'; ➜ indique à Dart qu’un fichier généré contiendra le code automatique (TypeAdapter).
// On génère ce code avec : flutter packages pub run build_runner build
// Cela crée un fichier 'xxx.g.dart' contenant le "TypeAdapter" ➜ Ce TypeAdapter permet à Hive de convertir ta classe <-> données binaires locales.
// L'utilisation de hive generator permet de générer le code dans les fichiers 'xxx.g.dart'.

part 'g.dart/workout_entity.g.dart';

@HiveType(typeId: 1)
class WorkoutEntity {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String note;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final List<WorkoutExerciseEntity> exercises;

  WorkoutEntity({
    required this.id,
    required this.title,
    required this.note,
    required this.date,
    required this.exercises,
  });

  // J'ai modif static final en factory, pourquoi ? :
  // static final : crée une SEULE FOIS l'objet, au démarrage, Dart charge cette classe et execute cette méthode.
  // Il stocke ce WorkoutEntity dans la mémoire comme constante empty.
  // À chaque fois que j'utilise WorkoutEntity.empty, je récupère le même objet avec le même UUID.
  // Factory lui crée un nouvel objet à chaque appel !
  // Il ya d'autre moyen aussi de faire, mais utiliser factory est plus propre et conventionel
  factory WorkoutEntity.empty() {
    return WorkoutEntity(
      id: const Uuid().v4(),
      title: '',
      note: '',
      date: DateTime.now(),
      exercises: [],
    );
  }

  // Comme WorkoutEntity est immuable (utilise 'final' partout), il faut une fonction 'copyWith()' qui permet de "recréer" un workout avec des champs modifiés, sans casser l’immuabilité.
  WorkoutEntity copyWith({
    String? id,
    String? title,
    String? note,
    DateTime? date,
    List<WorkoutExerciseEntity>? exercises,
  }) {
    return WorkoutEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
    );
  }
}
