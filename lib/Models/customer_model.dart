import "package:equatable/equatable.dart";
import 'package:legutus/Models/address_model.dart';
import 'package:legutus/Models/media_model.dart';
import 'package:legutus/Models/recipient_model.dart';

class CustomerModel extends Equatable {
  String? name;
  String? type;
  String? phone;
  String? corpNumber;
  List<dynamic>? representation;
  AddressModel? addressModel;
  List<RecipientModel>? recipients;

  CustomerModel({
    name = "",
    type = "",
    phone = "",
    corpNumber = "",
    representation,
    addressModel,
    accounts,
    recipients,
  }) {
    this.name = name;
    this.type = type;
    this.phone = phone;
    this.corpNumber = corpNumber;
    this.representation = representation ?? [];
    this.addressModel = addressModel ?? AddressModel();
    this.recipients = recipients ?? [];
  }

  factory CustomerModel.fromJson(Map<String, dynamic> map) {
    List<MediaModel>? recipients = [];

    for (var i = 0; i < map["recipients"].length; i++) {
      recipients.add(MediaModel.fromJson(map["recipients"][i]));
    }

    return CustomerModel(
      name: map["name"] ?? "",
      type: map["type"] ?? "",
      phone: map["phone"] ?? "",
      corpNumber: map["corp_number"] ?? "",
      representation: map["representation"] ?? "",
      addressModel: AddressModel.fromJson(map["addressModel"]),
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
      "phone": phone ?? "",
      "corp_number": corpNumber ?? "",
      "representation": representation ?? [],
      "addressModel": addressModel!.toJson(),
      "recipients": recipientsJson,
    };
  }

  factory CustomerModel.copy(CustomerModel model) {
    return CustomerModel(
      name: model.name,
      type: model.type,
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
        phone!,
        corpNumber!,
        representation!,
        addressModel!,
        recipients!,
      ];

  @override
  bool get stringify => true;
}
