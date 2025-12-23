// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profil_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfilEntityAdapter extends TypeAdapter<ProfilEntity> {
  @override
  final int typeId = 3;

  @override
  ProfilEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfilEntity(
      fields[0] as String,
      fields[1] as String,
      fields[2] as int,
      fields[3] as double,
      fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProfilEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.gender)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.weight)
      ..writeByte(4)
      ..write(obj.height);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfilEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
