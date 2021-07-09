import "package:equatable/equatable.dart";
import 'package:legutus/Models/address_model.dart';
import 'package:legutus/Models/media_model.dart';

import 'customer_model.dart';

class PlanningReportModel extends Equatable {
  int? reportId;
  String? date;
  String? time;
  String? name;
  String? folderName;
  String? zipCity;
  String? state;
  String? type;
  String? price;
  String? description;
  List<dynamic>? references;
  AddressModel? addressModel;
  List<dynamic>? accounts;
  List<CustomerModel>? customers;

  PlanningReportModel({
    reportId = -1,
    date = "",
    time = "",
    name = "",
    folderName = "",
    zipCity = "",
    state = "",
    type = "",
    price = "",
    description = "",
    references,
    addressModel,
    accounts,
    customers,
  }) {
    this.reportId = reportId;
    this.date = date;
    this.time = time;
    this.name = name;
    this.folderName = folderName;
    this.zipCity = zipCity;
    this.state = state;
    this.type = type;
    this.price = price;
    this.description = description;
    this.references = references ?? [];
    this.addressModel = addressModel ?? AddressModel();
    this.accounts = accounts ?? Map<String, dynamic>();
    this.customers = customers ?? [];
  }

  factory PlanningReportModel.fromJson(Map<String, dynamic> map) {
    List<MediaModel>? customers = [];

    for (var i = 0; i < map["customers"].length; i++) {
      customers.add(MediaModel.fromJson(map["customers"][i]));
    }

    return PlanningReportModel(
      reportId: map["report_id"] ?? -1,
      date: map["date"] ?? "",
      time: map["time"] ?? "",
      name: map["name"] ?? "",
      folderName: map["folder_name"] ?? "",
      zipCity: map["zip_city"] ?? "",
      state: map["state"] ?? "",
      type: map["type"] ?? "",
      price: map["price"] ?? "",
      description: map["description"] ?? "",
      references: map["references"] ?? "",
      addressModel: AddressModel.fromJson(map["addressModel"]),
      accounts: map["accounts"] ?? Map<String, dynamic>(),
      customers: customers,
    );
  }

  Map<String, dynamic> toJson() {
    List<dynamic> customersJson = [];

    for (var i = 0; i < customers!.length; i++) {
      customersJson.add(customers![i].toJson());
    }

    return {
      "report_id": reportId ?? -1,
      "date": date ?? "",
      "time": time ?? "",
      "name": name ?? "",
      "folder_name": folderName ?? "",
      "zip_city": zipCity ?? "",
      "state": state ?? "",
      "type": type ?? "",
      "price": price ?? "",
      "description": description ?? "",
      "references": references ?? [],
      "addressModel": addressModel!.toJson(),
      "accounts": accounts ?? Map<String, dynamic>(),
      "customers": customersJson,
    };
  }

  factory PlanningReportModel.copy(PlanningReportModel model) {
    return PlanningReportModel(
      reportId: model.reportId,
      date: model.date,
      time: model.time,
      name: model.name,
      folderName: model.folderName,
      zipCity: model.zipCity,
      state: model.state,
      type: model.type,
      price: model.price,
      description: model.description,
      references: model.references,
      addressModel: model.addressModel,
      accounts: model.accounts,
      customers: model.customers,
    );
  }

  @override
  List<Object> get props => [
        reportId!,
        date!,
        time!,
        name!,
        folderName!,
        zipCity!,
        state!,
        type!,
        price!,
        description!,
        references!,
        addressModel!,
        accounts!,
        customers!,
      ];

  @override
  bool get stringify => true;
}
