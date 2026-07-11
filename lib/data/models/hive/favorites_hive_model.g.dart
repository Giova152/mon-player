// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_hive_model.dart';

class FavoritesHiveModelAdapter extends TypeAdapter<FavoritesHiveModel> {
  @override
  final int typeId = 2;

  @override
  FavoritesHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoritesHiveModel(
      favoriteSongIds: (fields[0] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, FavoritesHiveModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.favoriteSongIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoritesHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
