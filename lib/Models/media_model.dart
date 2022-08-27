// ignore_for_file: must_be_immutable

import "package:equatable/equatable.dart";
import 'package:hive/hive.dart';

part 'media_model.g.dart';

class MediaType {
  static const String picture = "picture";
  static const String audio = "audio";
  static const String note = "note";
  static const String video = "video";
}

@HiveType(typeId: 3)
class MediaModel extends Equatable {
  @HiveField(0)
  int? reportId;
  @HiveField(1)
  String? type;
  @HiveField(2)
  String? state;
  @HiveField(3)
  String? uuid;
  @HiveField(4)
  Map<String, dynamic>? deviceInfo;
  @HiveField(5)
  String? createdAt;
  @HiveField(6)
  int? rank;
  @HiveField(7)
  String? filename;
  @HiveField(8)
  String? ext;
  @HiveField(9)
  int? size;
  @HiveField(10)
  String? path;
  @HiveField(11)
  String? thumPath;
  @HiveField(12)
  int? duration;
  @HiveField(13)
  String? content;
  @HiveField(14)
  String? latitude;
  @HiveField(15)
  String? longitude;
  @HiveField(16)
  // int? width;
  // @HiveField(17)
  // int? height;

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
    // this.width = 0,
    // this.height = 0,
  });

  factory MediaModel.fromJson(Map<String, dynamic> map) {
    return MediaModel(
      reportId: map["report_id"] ?? 0,
      type: map["type"] ?? "",
      state: map["state"] ?? "",
      uuid: map["uuid"] ?? "",
      deviceInfo: map["device_info"] ?? <String, dynamic>{},
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
      // width: map["width"] ?? 0,
      // height: map["height"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "report_id": reportId ?? 0,
      "type": type ?? "",
      "state": state ?? "",
      "uuid": uuid ?? "",
      "device_info": deviceInfo ?? <String, dynamic>{},
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
      // "width": width ?? 0,
      // "height": height ?? 0,
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
      // width: model.width,
      // height: model.height,
    );
  }

  @override
  List<Object> get props => [
        reportId!,
        type!,
        state!,
        uuid!,
        deviceInfo ?? <String, dynamic>{},
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
        // width!,
        // height!,
      ];

  @override
  bool get stringify => true;
}
