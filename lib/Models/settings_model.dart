import "package:equatable/equatable.dart";

class SettingsModel extends Equatable {
  // bool? allowCamera;
  // bool? allowMicrophone;
  // bool? allowLocation;
  // bool? withRestriction;
  int? photoResolution;
  int? videoResolution;

  SettingsModel({
    // this.allowCamera = true,
    // this.allowMicrophone = true,
    // this.allowLocation = true,
    // this.withRestriction = false,
    this.photoResolution = 2,
    this.videoResolution = 0,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> map) {
    return SettingsModel(
      // allowCamera: map["allowCamera"] ?? true,
      // allowMicrophone: map["allowMicrophone"] ?? true,
      // allowLocation: map["allowLocation"] ?? true,
      // withRestriction: map["withRestriction"] ?? false,
      photoResolution: map["photoResolution"] ?? 2,
      videoResolution: map["videoResolution"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // "allowCamera": allowCamera ?? true,
      // "allowMicrophone": allowMicrophone ?? true,
      // "allowLocation": allowLocation ?? true,
      // "withRestriction": withRestriction ?? false,
      "photoResolution": photoResolution ?? 2,
      "videoResolution": videoResolution ?? 0,
    };
  }

  factory SettingsModel.copy(SettingsModel model) {
    return SettingsModel(
      // allowCamera: model.allowCamera,
      // allowMicrophone: model.allowMicrophone,
      // allowLocation: model.allowLocation,
      // withRestriction: model.withRestriction,
      photoResolution: model.photoResolution,
      videoResolution: model.videoResolution,
    );
  }

  @override
  List<Object> get props => [
        // allowCamera!,
        // allowMicrophone!,
        // allowLocation!,
        // withRestriction!,
        photoResolution!,
        videoResolution!,
      ];

  @override
  bool get stringify => true;
}
