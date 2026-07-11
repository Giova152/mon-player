// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_hive_model.dart';

class PlaylistHiveModelAdapter extends TypeAdapter<PlaylistHiveModel> {
  @override
  final int typeId = 1;

  @override
  PlaylistHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlaylistHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      songIds: (fields[3] as List).cast<String>(),
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      coverArtSongId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PlaylistHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.songIds)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.coverArtSongId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
