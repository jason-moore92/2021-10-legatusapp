// ignore_for_file: must_be_immutable

import "package:equatable/equatable.dart";
import 'package:hive/hive.dart';
import 'package:legatus/Models/MediaModel.dart';

part 'LocalReportModel.g.dart';

@HiveType(typeId: 2)
class LocalReportModel extends Equatable {
  @HiveField(0)
  int? reportId;
  @HiveField(1)
  String? uuid;
  @HiveField(2)
  Map<String, dynamic>? deviceInfo;
  @HiveField(3)
  String? date;
  @HiveField(4)
  String? time;
  @HiveField(5)
  String? createdAt;
  @HiveField(6)
  String? name;
  @HiveField(7)
  String? type;
  @HiveField(8)
  String? description;
  @HiveField(9)
  String? street;
  @HiveField(10)
  String? complement;
  @HiveField(11)
  String? zip;
  @HiveField(12)
  String? city;
  @HiveField(13)
  String? latitude;
  @HiveField(14)
  String? longitude;
  @HiveField(15)
  String? customerName;
  @HiveField(16)
  String? customerType;
  @HiveField(17)
  String? customerStreet;
  @HiveField(18)
  String? customerComplement;
  @HiveField(19)
  String? customerZip;
  @HiveField(20)
  String? customerCity;
  @HiveField(21)
  String? customerCorpForm;
  @HiveField(22)
  String? customerCorpSiren;
  @HiveField(23)
  String? customerCorpRcs;
  @HiveField(24)
  String? recipientName;
  @HiveField(25)
  String? recipientPosition;
  @HiveField(26)
  String? recipientBirthDate;
  @HiveField(27)
  String? recipientBirthCity;
  @HiveField(28)
  String? recipientEmail;
  @HiveField(29)
  String? recipientPhone;
  @HiveField(30)
  List<MediaModel>? medias;
  @HiveField(31)
  List<dynamic>? orderList;

  LocalReportModel({
    this.reportId = 0,
    this.uuid = "",
    this.deviceInfo,
    this.date = "",
    this.time = "",
    this.createdAt = "",
    this.name = "",
    this.type = "",
    this.description = "",
    this.street = "",
    this.complement = "",
    this.zip = "",
    this.city = "",
    this.latitude = "",
    this.longitude = "",
    this.customerName = "",
    this.customerType = "",
    this.customerStreet = "",
    this.customerComplement = "",
    this.customerZip = "",
    this.customerCity = "",
    this.customerCorpForm = "",
    this.customerCorpSiren = "",
    this.customerCorpRcs = "",
    this.recipientName = "",
    this.recipientPosition = "",
    this.recipientBirthDate = "",
    this.recipientBirthCity = "",
    this.recipientEmail = "",
    this.recipientPhone = "",
    this.medias,
    this.orderList = const [],
  });

  factory LocalReportModel.fromJson(Map<String, dynamic> map) {
    List<MediaModel>? medias = [];

    if (map["medias"] == null) map["medias"] = [];

    for (var i = 0; i < map["medias"].length; i++) {
      medias.add(MediaModel.fromJson(map["medias"][i]));
    }

    return LocalReportModel(
      reportId: map["report_id"] ?? 0,
      uuid: map["uuid"] ?? "",
      deviceInfo: map["device_info"] ?? Map<String, dynamic>(),
      date: map["date"] ?? "",
      time: map["time"] ?? "",
      createdAt: map["created_at"] ?? "",
      name: map["name"] ?? "",
      type: map["type"] ?? "",
      description: map["description"] ?? "",
      street: map["street"] ?? "",
      complement: map["complement"] ?? "",
      zip: map["zip"] ?? "",
      city: map["city"] ?? "",
      latitude: map["latitude"] ?? "",
      longitude: map["longitude"] ?? "",
      customerName: map["customer_name"] ?? "",
      customerType: map["customer_type"] ?? "",
      customerStreet: map["customer_street"] ?? "",
      customerComplement: map["customer_complement"] ?? "",
      customerZip: map["customer_zip"] ?? "",
      customerCity: map["customer_city"] ?? "",
      customerCorpForm: map["customer_corp_form"] ?? "",
      customerCorpSiren: map["customer_corp_siren"] ?? "",
      customerCorpRcs: map["customer_corp_rcs"] ?? "",
      recipientName: map["recipient_name"] ?? "",
      recipientPosition: map["recipient_position"] ?? "",
      recipientBirthDate: map["recipient_birth_date"] ?? "",
      recipientBirthCity: map["recipient_birth_city"] ?? "",
      recipientEmail: map["recipient_email"] ?? "",
      recipientPhone: map["recipient_phone"] ?? "",
      medias: medias,
      orderList: map["orderList"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    List<dynamic> mediasJson = [];
    if (medias == null) medias = [];
    for (var i = 0; i < medias!.length; i++) {
      mediasJson.add(medias![i].toJson());
    }

    return {
      "report_id": reportId ?? 0,
      "uuid": uuid ?? "",
      "device_info": deviceInfo ?? Map<String, dynamic>(),
      "date": date ?? "",
      "time": time ?? "",
      "created_at": createdAt ?? "",
      "name": name ?? "",
      "type": type ?? "",
      "description": description ?? "",
      "street": street ?? "",
      "complement": complement ?? "",
      "zip": zip ?? "",
      "city": city ?? "",
      "latitude": latitude ?? "",
      "longitude": longitude ?? "",
      "customer_name": customerName ?? "",
      "customer_type": customerType ?? "",
      "customer_street": customerStreet ?? "",
      "customer_complement": customerComplement ?? "",
      "customer_zip": customerZip ?? "",
      "customer_city": customerCity ?? "",
      "customer_corp_form": customerCorpForm ?? "",
      "customer_corp_siren": customerCorpSiren ?? "",
      "customer_corp_rcs": customerCorpRcs ?? "",
      "recipient_name": recipientName ?? "",
      "recipient_position": recipientPosition ?? "",
      "recipient_birth_date": recipientBirthDate ?? "",
      "recipient_birth_city": recipientBirthCity ?? "",
      "recipient_email": recipientEmail ?? "",
      "recipient_phone": recipientPhone ?? "",
      "medias": mediasJson,
      "orderList": orderList,
    };
  }

  factory LocalReportModel.copy(LocalReportModel model) {
    return LocalReportModel(
      reportId: model.reportId,
      uuid: model.uuid,
      deviceInfo: model.deviceInfo,
      date: model.date,
      time: model.time,
      createdAt: model.createdAt,
      name: model.name,
      type: model.type,
      description: model.description,
      street: model.street,
      complement: model.complement,
      zip: model.zip,
      city: model.city,
      latitude: model.latitude,
      longitude: model.longitude,
      customerName: model.customerName,
      customerType: model.customerType,
      customerStreet: model.customerStreet,
      customerComplement: model.customerComplement,
      customerZip: model.customerZip,
      customerCity: model.customerCity,
      customerCorpForm: model.customerCorpForm,
      customerCorpSiren: model.customerCorpSiren,
      customerCorpRcs: model.customerCorpRcs,
      recipientName: model.recipientName,
      recipientPosition: model.recipientPosition,
      recipientBirthDate: model.recipientBirthDate,
      recipientBirthCity: model.recipientBirthCity,
      recipientEmail: model.recipientEmail,
      recipientPhone: model.recipientPhone,
      medias: model.medias,
      orderList: model.orderList,
    );
  }

  @override
  List<Object> get props => [
        reportId!,
        uuid!,
        // deviceInfo!,
        date!,
        time!,
        createdAt!,
        name!,
        type!,
        description!,
        street!,
        complement!,
        zip!,
        city!,
        latitude!,
        longitude!,
        customerName!,
        customerType!,
        customerStreet!,
        customerComplement!,
        customerZip!,
        customerCity!,
        customerCorpForm!,
        customerCorpSiren!,
        customerCorpRcs!,
        recipientName!,
        recipientPosition!,
        recipientBirthDate!,
        recipientBirthCity!,
        recipientEmail!,
        recipientPhone!,
        medias ?? Object(),
        orderList!,
      ];

  @override
  bool get stringify => true;
}
