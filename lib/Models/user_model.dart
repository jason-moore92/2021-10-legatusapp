import "package:equatable/equatable.dart";

class UserModel extends Equatable {
  String? name;
  String? organizationName;
  String? email;
  String? token;

  UserModel({
    this.name = "",
    this.organizationName = "",
    this.email = "",
    this.token = "",
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      name: map["name"] ?? "",
      organizationName: map["organization_name"] ?? "",
      email: map["email"] ?? "",
      token: map["token"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name ?? "",
      "organization_name": organizationName ?? "",
      "email": email ?? "",
      "token": token ?? "",
    };
  }

  factory UserModel.copy(UserModel model) {
    return UserModel(
      name: model.name,
      organizationName: model.organizationName,
      email: model.email,
      token: model.token,
    );
  }

  @override
  List<Object> get props => [
        name!,
        organizationName!,
        email!,
        token!,
      ];

  @override
  bool get stringify => true;
}
