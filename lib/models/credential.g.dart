// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CredentialAdapter extends TypeAdapter<Credential> {
  @override
  final int typeId = 0;

  @override
  Credential read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Credential(
      title: fields[0] as String,
      username: fields[1] as String,
      password: fields[2] as String,
      note: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Credential obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CredentialAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
