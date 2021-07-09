import "package:equatable/equatable.dart";

class MediaType {
  String picture = "picture";
  String audio = "audio";
  String note = "note";
  String video = "video";
}

class MediaModel extends Equatable {
  int? reportId;
  String? type;
  String? state;
  String? uuid;
  String? deviceInfo;
  String? createdAt;
  int? rank;
  String? filename;
  String? ext;
  int? size;
  String? path;
  int? duration;
  String? content;
  String? latitude;
  String? longitude;

  MediaModel({
    this.reportId = -1,
    this.type = "",
    this.state = "",
    this.uuid = "",
    this.deviceInfo = "",
    this.createdAt = "",
    this.rank = -1,
    this.filename = "",
    this.ext = "",
    this.size = -1,
    this.path = "",
    this.duration = -1,
    this.content = "",
    this.latitude = "",
    this.longitude = "",
  });

  factory MediaModel.fromJson(Map<String, dynamic> map) {
    return MediaModel(
      reportId: map["report_id"] ?? -1,
      type: map["type"] ?? "",
      state: map["state"] ?? "",
      uuid: map["uuid"] ?? "",
      deviceInfo: map["device_info"] ?? "",
      createdAt: map["created_at"] ?? "",
      rank: map["rank"] ?? -1,
      filename: map["filename"] ?? "",
      ext: map["extension"] ?? "",
      size: map["size"] ?? -1,
      path: map["path"] ?? "",
      duration: map["duration"] ?? -1,
      content: map["content"] ?? "",
      latitude: map["latitude"] ?? "",
      longitude: map["longitude"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "report_id": reportId ?? -1,
      "type": type ?? "",
      "state": state ?? "",
      "uuid": uuid ?? "",
      "device_info": deviceInfo ?? "",
      "created_at": createdAt ?? "",
      "rank": rank ?? -1,
      "filename": filename ?? "",
      "extension": ext ?? "",
      "size": size ?? -1,
      "path": path ?? "",
      "duration": duration ?? -1,
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
        deviceInfo!,
        createdAt!,
        rank!,
        filename!,
        ext!,
        size!,
        path!,
        duration!,
        content!,
        latitude!,
        longitude!,
      ];

  @override
  bool get stringify => true;
}
