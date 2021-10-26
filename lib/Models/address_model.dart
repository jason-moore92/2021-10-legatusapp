// ignore_for_file: must_be_immutable

import "package:equatable/equatable.dart";

class AddressModel extends Equatable {
  String? street;
  String? complement;
  String? zip;
  String? city;
  String? latitude;
  String? longitude;

  AddressModel({
    this.street = "",
    this.complement = "",
    this.zip = "",
    this.city = "",
    this.latitude = "",
    this.longitude = "",
  });

  factory AddressModel.fromJson(Map<String, dynamic> map) {
    return AddressModel(
      street: map["street"] ?? "",
      complement: map["complement"] ?? "",
      zip: map["zip"] ?? "",
      city: map["city"] ?? "",
      latitude: map["latitude"] ?? "",
      longitude: map["longitude"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "street": street ?? "",
      "complement": complement ?? "",
      "zip": zip ?? "",
      "city": city ?? "",
      "latitude": latitude ?? "",
      "longitude": longitude ?? "",
    };
  }

  factory AddressModel.copy(AddressModel model) {
    return AddressModel(
      street: model.street,
      complement: model.complement,
      zip: model.zip,
      city: model.city,
      latitude: model.latitude,
      longitude: model.longitude,
    );
  }

  @override
  List<Object> get props => [
        street!,
        complement!,
        zip!,
        city!,
        latitude!,
        longitude!,
      ];

  @override
  bool get stringify => true;
}
