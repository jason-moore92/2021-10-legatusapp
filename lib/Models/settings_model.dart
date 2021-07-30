import "package:equatable/equatable.dart";

class SettingsModel extends Equatable {
  // bool? allowCamera;
  // bool? allowMicrophone;
  // bool? allowLocation;
  bool? withRestriction;

  SettingsModel({
    // this.allowCamera = true,
    // this.allowMicrophone = true,
    // this.allowLocation = true,
    this.withRestriction = true,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> map) {
    return SettingsModel(
      // allowCamera: map["allowCamera"] ?? true,
      // allowMicrophone: map["allowMicrophone"] ?? true,
      // allowLocation: map["allowLocation"] ?? true,
      withRestriction: map["withRestriction"] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // "allowCamera": allowCamera ?? true,
      // "allowMicrophone": allowMicrophone ?? true,
      // "allowLocation": allowLocation ?? true,
      "withRestriction": withRestriction ?? true,
    };
  }

  factory SettingsModel.copy(SettingsModel model) {
    return SettingsModel(
      // allowCamera: model.allowCamera,
      // allowMicrophone: model.allowMicrophone,
      // allowLocation: model.allowLocation,
      withRestriction: model.withRestriction,
    );
  }

  @override
  List<Object> get props => [
        // allowCamera!,
        // allowMicrophone!,
        // allowLocation!,
        withRestriction!,
      ];

  @override
  bool get stringify => true;
}
