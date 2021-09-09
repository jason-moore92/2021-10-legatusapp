// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'MediaModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaModelAdapter extends TypeAdapter<MediaModel> {
  @override
  final int typeId = 3;

  @override
  MediaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaModel(
      reportId: fields[0] as int?,
      type: fields[1] as String?,
      state: fields[2] as String?,
      uuid: fields[3] as String?,
      deviceInfo: (fields[4] as Map?)?.cast<String, dynamic>(),
      createdAt: fields[5] as String?,
      rank: fields[6] as int?,
      filename: fields[7] as String?,
      ext: fields[8] as String?,
      size: fields[9] as int?,
      path: fields[10] as String?,
      thumPath: fields[11] as String?,
      duration: fields[12] as int?,
      content: fields[13] as String?,
      latitude: fields[14] as String?,
      longitude: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MediaModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.reportId)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.state)
      ..writeByte(3)
      ..write(obj.uuid)
      ..writeByte(4)
      ..write(obj.deviceInfo)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.rank)
      ..writeByte(7)
      ..write(obj.filename)
      ..writeByte(8)
      ..write(obj.ext)
      ..writeByte(9)
      ..write(obj.size)
      ..writeByte(10)
      ..write(obj.path)
      ..writeByte(11)
      ..write(obj.thumPath)
      ..writeByte(12)
      ..write(obj.duration)
      ..writeByte(13)
      ..write(obj.content)
      ..writeByte(14)
      ..write(obj.latitude)
      ..writeByte(15)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
