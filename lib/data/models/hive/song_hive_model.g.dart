// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongHiveModelAdapter extends TypeAdapter<SongHiveModel> {
  @override
  final int typeId = 0;

  @override
  SongHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongHiveModel(
      id: fields[0] as String,
      filePath: fields[1] as String,
      fileName: fields[2] as String,
      title: fields[3] as String,
      artist: fields[4] as String,
      album: fields[5] as String,
      genre: fields[6] as String,
      durationMs: fields[7] as int,
      fileSize: fields[8] as int,
      dateAdded: fields[9] as DateTime,
      artworkPath: fields[10] as String?,
      trackNumber: fields[11] as int,
      year: fields[12] as int,
      isFavorite: fields[13] as bool,
      playCount: fields[14] as int,
      lastPlayedPosition: fields[15] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SongHiveModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.artist)
      ..writeByte(5)
      ..write(obj.album)
      ..writeByte(6)
      ..write(obj.genre)
      ..writeByte(7)
      ..write(obj.durationMs)
      ..writeByte(8)
      ..write(obj.fileSize)
      ..writeByte(9)
      ..write(obj.dateAdded)
      ..writeByte(10)
      ..write(obj.artworkPath)
      ..writeByte(11)
      ..write(obj.trackNumber)
      ..writeByte(12)
      ..write(obj.year)
      ..writeByte(13)
      ..write(obj.isFavorite)
      ..writeByte(14)
      ..write(obj.playCount)
      ..writeByte(15)
      ..write(obj.lastPlayedPosition);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
