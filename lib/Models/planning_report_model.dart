import "package:equatable/equatable.dart";
import 'package:legatus/Models/address_model.dart';
import 'package:legatus/Models/MediaModel.dart';

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
    reportId = 0,
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
    this.accounts = accounts ?? [];
    this.customers = customers ?? [];
  }

  factory PlanningReportModel.fromJson(Map<String, dynamic> map) {
    List<CustomerModel>? customers = [];

    for (var i = 0; i < map["customers"].length; i++) {
      customers.add(CustomerModel.fromJson(map["customers"][i]));
    }

    return PlanningReportModel(
      reportId: map["report_id"] ?? 0,
      date: map["date"] ?? "",
      time: map["time"] ?? "",
      name: map["name"] ?? "",
      folderName: map["folder_name"] ?? "",
      zipCity: map["zip_city"] ?? "",
      state: map["state"] ?? "",
      type: map["type"] ?? "",
      price: map["price"] ?? "",
      description: map["description"] ?? "",
      references: map["references"] ?? [],
      addressModel: AddressModel.fromJson(map["address"]),
      accounts: map["accounts"] ?? [],
      customers: customers,
    );
  }

  Map<String, dynamic> toJson() {
    List<dynamic> customersJson = [];

    for (var i = 0; i < customers!.length; i++) {
      customersJson.add(customers![i].toJson());
    }

    return {
      "report_id": reportId ?? 0,
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
      "address": addressModel!.toJson(),
      "accounts": accounts ?? [],
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
