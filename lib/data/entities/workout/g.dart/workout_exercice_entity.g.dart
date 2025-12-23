// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../workout_exercise_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutExerciceEntityAdapter extends TypeAdapter<WorkoutExerciseEntity> {
  @override
  final int typeId = 2;

  @override
  WorkoutExerciseEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutExerciseEntity(
      exercise: fields[0] as ExerciseEntity,
      sets: fields[1] as int,
      reps: fields[2] as int,
      weight: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutExerciseEntity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.exercise)
      ..writeByte(1)
      ..write(obj.sets)
      ..writeByte(2)
      ..write(obj.reps)
      ..writeByte(3)
      ..write(obj.weight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutExerciceEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
