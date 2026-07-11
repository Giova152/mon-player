// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_hive_model.dart';

class AppSettingsHiveModelAdapter extends TypeAdapter<AppSettingsHiveModel> {
  @override
  final int typeId = 3;

  @override
  AppSettingsHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettingsHiveModel(
      isDarkMode: fields[0] as bool,
      playbackSpeed: fields[1] as double,
      isShuffleEnabled: fields[2] as bool,
      repeatMode: fields[3] as int,
      sortOrder: fields[4] as String,
      lastPlayedSongId: fields[5] as String?,
      lastPlayedPositionMs: fields[6] as int,
      lastQueue: (fields[7] as List).cast<String>(),
      volume: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettingsHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.playbackSpeed)
      ..writeByte(2)
      ..write(obj.isShuffleEnabled)
      ..writeByte(3)
      ..write(obj.repeatMode)
      ..writeByte(4)
      ..write(obj.sortOrder)
      ..writeByte(5)
      ..write(obj.lastPlayedSongId)
      ..writeByte(6)
      ..write(obj.lastPlayedPositionMs)
      ..writeByte(7)
      ..write(obj.lastQueue)
      ..writeByte(8)
      ..write(obj.volume);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
