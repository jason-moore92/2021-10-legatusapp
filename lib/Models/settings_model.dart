import "package:equatable/equatable.dart";

class SettingsModel extends Equatable {
  // bool? allowCamera;
  // bool? allowMicrophone;
  // bool? allowLocation;
  bool? withRestriction;
  int? photoResolution;
  int? videoResolution;

  SettingsModel({
    // this.allowCamera = true,
    // this.allowMicrophone = true,
    // this.allowLocation = true,
    this.withRestriction = true,
    this.photoResolution = 2,
    this.videoResolution = 2,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> map) {
    return SettingsModel(
      // allowCamera: map["allowCamera"] ?? true,
      // allowMicrophone: map["allowMicrophone"] ?? true,
      // allowLocation: map["allowLocation"] ?? true,
      withRestriction: map["withRestriction"] ?? true,
      photoResolution: map["photoResolution"] ?? 2,
      videoResolution: map["videoResolution"] ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // "allowCamera": allowCamera ?? true,
      // "allowMicrophone": allowMicrophone ?? true,
      // "allowLocation": allowLocation ?? true,
      "withRestriction": withRestriction ?? true,
      "photoResolution": photoResolution ?? 2,
      "videoResolution": videoResolution ?? 2,
    };
  }

  factory SettingsModel.copy(SettingsModel model) {
    return SettingsModel(
      // allowCamera: model.allowCamera,
      // allowMicrophone: model.allowMicrophone,
      // allowLocation: model.allowLocation,
      withRestriction: model.withRestriction,
      photoResolution: model.photoResolution,
      videoResolution: model.videoResolution,
    );
  }

  @override
  List<Object> get props => [
        // allowCamera!,
        // allowMicrophone!,
        // allowLocation!,
        withRestriction!,
        photoResolution!,
        videoResolution!,
      ];

  @override
  bool get stringify => true;
}
