// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../exercise_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseEntityAdapter extends TypeAdapter<ExerciseEntity> {
  @override
  final int typeId = 0;

  @override
  ExerciseEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseEntity(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      imageUrl: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseEntity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
