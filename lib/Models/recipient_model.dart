// ignore_for_file: must_be_immutable

import "package:equatable/equatable.dart";

class RecipientModel extends Equatable {
  String? name;
  String? position;
  String? email;
  String? mobilePhone;

  RecipientModel({
    this.name = "",
    this.position = "",
    this.email = "",
    this.mobilePhone = "",
  });

  factory RecipientModel.fromJson(Map<String, dynamic> map) {
    return RecipientModel(
      name: map["name"] ?? "",
      position: map["position"] ?? "",
      email: map["email"] ?? "",
      mobilePhone: map["mobile_phone"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name ?? "",
      "position": position ?? "",
      "email": email ?? "",
      "mobile_phone": mobilePhone ?? "",
    };
  }

  factory RecipientModel.copy(RecipientModel model) {
    return RecipientModel(
      name: model.name,
      position: model.position,
      email: model.email,
      mobilePhone: model.mobilePhone,
    );
  }

  @override
  List<Object> get props => [
        name!,
        position!,
        email!,
        mobilePhone!,
      ];

  @override
  bool get stringify => true;
}
