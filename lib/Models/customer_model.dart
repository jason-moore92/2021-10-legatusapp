// ignore_for_file: must_be_immutable

import "package:equatable/equatable.dart";
import 'package:legatus/Models/address_model.dart';
// import 'package:legatus/Models/MediaModel.dart';
import 'package:legatus/Models/recipient_model.dart';

class CustomerModel extends Equatable {
  String? name;
  String? type;
  String? email;
  String? phone;
  String? corpNumber;
  List<dynamic>? representation;
  AddressModel? addressModel;
  List<RecipientModel>? recipients;

  CustomerModel({
    name = "",
    type = "",
    email = "",
    phone = "",
    corpNumber = "",
    representation,
    addressModel,
    accounts,
    recipients,
  }) {
    this.name = name;
    this.type = type;
    this.email = email;
    this.phone = phone;
    this.corpNumber = corpNumber;
    this.representation = representation ?? [];
    this.addressModel = addressModel ?? AddressModel();
    this.recipients = recipients ?? [];
  }

  factory CustomerModel.fromJson(Map<String, dynamic> map) {
    List<RecipientModel>? recipients = [];
    if (map["recipients"] != null) {
      for (var i = 0; i < map["recipients"].length; i++) {
        recipients.add(RecipientModel.fromJson(map["recipients"][i]));
      }
    }

    return CustomerModel(
      name: map["name"] ?? "",
      type: map["type"] ?? "",
      email: map["email"] ?? "",
      phone: map["phone"] ?? "",
      corpNumber: map["corp_number"] ?? "",
      representation: map["representation"] ?? [],
      addressModel: AddressModel.fromJson(map["address"]),
      recipients: recipients,
    );
  }

  Map<String, dynamic> toJson() {
    List<dynamic> recipientsJson = [];

    for (var i = 0; i < recipients!.length; i++) {
      recipientsJson.add(recipients![i].toJson());
    }

    return {
      "name": name ?? "",
      "type": type ?? "",
      "email": email ?? "",
      "phone": phone ?? "",
      "corp_number": corpNumber ?? "",
      "representation": representation ?? [],
      "address": addressModel!.toJson(),
      "recipients": recipientsJson,
    };
  }

  factory CustomerModel.copy(CustomerModel model) {
    return CustomerModel(
      name: model.name,
      type: model.type,
      email: model.email,
      phone: model.phone,
      corpNumber: model.corpNumber,
      representation: model.representation,
      addressModel: model.addressModel,
      recipients: model.recipients,
    );
  }

  @override
  List<Object> get props => [
        name!,
        type!,
        email!,
        phone!,
        corpNumber!,
        representation!,
        addressModel!,
        recipients!,
      ];

  @override
  bool get stringify => true;
}
