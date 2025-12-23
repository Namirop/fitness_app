// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../workout_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutEntityAdapter extends TypeAdapter<WorkoutEntity> {
  @override
  final int typeId = 1;

  @override
  WorkoutEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutEntity(
      id: fields[0] as String,
      title: fields[1] as String,
      note: fields[2] as String,
      date: fields[3] as DateTime,
      exercices: (fields[4] as List).cast<WorkoutExerciseEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.note)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.exercices);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
