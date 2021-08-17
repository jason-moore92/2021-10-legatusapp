import "package:equatable/equatable.dart";

class MediaType {
  static const String picture = "picture";
  static const String audio = "audio";
  static const String note = "note";
  static const String video = "video";
}

class MediaModel extends Equatable {
  int? reportId;
  String? type;
  String? state;
  String? uuid;
  Map<String, dynamic>? deviceInfo;
  String? createdAt;
  int? rank;
  String? filename;
  String? ext;
  int? size;
  String? path;
  String? thumPath;
  int? duration;
  String? content;
  String? latitude;
  String? longitude;

  MediaModel({
    this.reportId = 0,
    this.type = "",
    this.state = "",
    this.uuid = "",
    this.deviceInfo,
    this.createdAt = "",
    this.rank = -1,
    this.filename = "",
    this.ext = "",
    this.size = -1,
    this.path = "",
    this.thumPath = "",
    this.duration = 0,
    this.content = "",
    this.latitude = "",
    this.longitude = "",
  });

  factory MediaModel.fromJson(Map<String, dynamic> map) {
    return MediaModel(
      reportId: map["report_id"] ?? 0,
      type: map["type"] ?? "",
      state: map["state"] ?? "",
      uuid: map["uuid"] ?? "",
      deviceInfo: map["device_info"] ?? Map<String, dynamic>(),
      createdAt: map["created_at"] ?? "",
      rank: map["rank"] ?? -1,
      filename: map["filename"] ?? "",
      ext: map["extension"] ?? "",
      size: map["size"] ?? -1,
      path: map["path"] ?? "",
      thumPath: map["thumPath"] ?? "",
      duration: map["duration"] ?? 0,
      content: map["content"] ?? "",
      latitude: map["latitude"] ?? "",
      longitude: map["longitude"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "report_id": reportId ?? 0,
      "type": type ?? "",
      "state": state ?? "",
      "uuid": uuid ?? "",
      "device_info": deviceInfo ?? Map<String, dynamic>(),
      "created_at": createdAt ?? "",
      "rank": rank ?? -1,
      "filename": filename ?? "",
      "extension": ext ?? "",
      "size": size ?? -1,
      "path": path ?? "",
      "thumPath": thumPath ?? "",
      "duration": duration ?? 0,
      "content": content ?? "",
      "latitude": latitude ?? "",
      "longitude": longitude ?? "",
    };
  }

  factory MediaModel.copy(MediaModel model) {
    return MediaModel(
      reportId: model.reportId,
      type: model.type,
      state: model.state,
      uuid: model.uuid,
      deviceInfo: model.deviceInfo,
      createdAt: model.createdAt,
      rank: model.rank,
      filename: model.filename,
      ext: model.ext,
      size: model.size,
      path: model.path,
      thumPath: model.thumPath,
      duration: model.duration,
      content: model.content,
      latitude: model.latitude,
      longitude: model.longitude,
    );
  }

  @override
  List<Object> get props => [
        reportId!,
        type!,
        state!,
        uuid!,
        deviceInfo ?? Map<String, dynamic>(),
        createdAt!,
        rank!,
        filename!,
        ext!,
        size!,
        path!,
        thumPath!,
        duration!,
        content!,
        latitude!,
        longitude!,
      ];

  @override
  bool get stringify => true;
}
