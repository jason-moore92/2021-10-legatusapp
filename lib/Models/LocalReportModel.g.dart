// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'LocalReportModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalReportModelAdapter extends TypeAdapter<LocalReportModel> {
  @override
  final int typeId = 2;

  @override
  LocalReportModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalReportModel(
      reportId: fields[0] as int?,
      uuid: fields[1] as String?,
      deviceInfo: (fields[2] as Map?)?.cast<String, dynamic>(),
      date: fields[3] as String?,
      time: fields[4] as String?,
      createdAt: fields[5] as String?,
      name: fields[6] as String?,
      type: fields[7] as String?,
      description: fields[8] as String?,
      street: fields[9] as String?,
      complement: fields[10] as String?,
      zip: fields[11] as String?,
      city: fields[12] as String?,
      latitude: fields[13] as String?,
      longitude: fields[14] as String?,
      customerName: fields[15] as String?,
      customerType: fields[16] as String?,
      customerStreet: fields[17] as String?,
      customerComplement: fields[18] as String?,
      customerZip: fields[19] as String?,
      customerCity: fields[20] as String?,
      customerCorpForm: fields[21] as String?,
      customerCorpSiren: fields[22] as String?,
      customerCorpRcs: fields[23] as String?,
      recipientName: fields[24] as String?,
      recipientPosition: fields[25] as String?,
      recipientBirthDate: fields[26] as String?,
      recipientBirthCity: fields[27] as String?,
      recipientEmail: fields[28] as String?,
      recipientPhone: fields[29] as String?,
      medias: (fields[30] as List?)?.cast<MediaModel>(),
      orderList: (fields[31] as List?)?.cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, LocalReportModel obj) {
    writer
      ..writeByte(32)
      ..writeByte(0)
      ..write(obj.reportId)
      ..writeByte(1)
      ..write(obj.uuid)
      ..writeByte(2)
      ..write(obj.deviceInfo)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.time)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.name)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.street)
      ..writeByte(10)
      ..write(obj.complement)
      ..writeByte(11)
      ..write(obj.zip)
      ..writeByte(12)
      ..write(obj.city)
      ..writeByte(13)
      ..write(obj.latitude)
      ..writeByte(14)
      ..write(obj.longitude)
      ..writeByte(15)
      ..write(obj.customerName)
      ..writeByte(16)
      ..write(obj.customerType)
      ..writeByte(17)
      ..write(obj.customerStreet)
      ..writeByte(18)
      ..write(obj.customerComplement)
      ..writeByte(19)
      ..write(obj.customerZip)
      ..writeByte(20)
      ..write(obj.customerCity)
      ..writeByte(21)
      ..write(obj.customerCorpForm)
      ..writeByte(22)
      ..write(obj.customerCorpSiren)
      ..writeByte(23)
      ..write(obj.customerCorpRcs)
      ..writeByte(24)
      ..write(obj.recipientName)
      ..writeByte(25)
      ..write(obj.recipientPosition)
      ..writeByte(26)
      ..write(obj.recipientBirthDate)
      ..writeByte(27)
      ..write(obj.recipientBirthCity)
      ..writeByte(28)
      ..write(obj.recipientEmail)
      ..writeByte(29)
      ..write(obj.recipientPhone)
      ..writeByte(30)
      ..write(obj.medias)
      ..writeByte(31)
      ..write(obj.orderList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalReportModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
