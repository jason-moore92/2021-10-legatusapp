import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:legatus/Models/index.dart';
import 'package:path_provider/path_provider.dart';

import 'date_time_convert.dart';

class FileHelpers {
  static Future<File?> writeTextFile(
      {@required String? text, String? path = ""}) async {
    try {
      if (path == "") {
        path = await getDirectory();
        if (path == null) return null;
        await Directory(path).create();
        path += "/" + DateTime.now().millisecondsSinceEpoch.toString() + ".txt";
      }
      File file = File(path!);
      await file.writeAsString(text!);
      return file;
    } catch (e) {
      print("Couldn't write text file");
      return null;
    }
  }

  static Future<String?> readTextFile({String? path}) async {
    String text;
    try {
      final File file = File(path!);
      text = await file.readAsString();
      return text;
    } catch (e) {
      print("Couldn't read file");
      return null;
    }
  }

  static Future<File?> writeImageFile(
      {@required XFile? imageFile, @required String? path}) async {
    try {
      if (path == "") {
        path = await getDirectory();
        if (path == null) return null;
        Directory(path).createSync();
        path += "/" +
            DateTime.now().millisecondsSinceEpoch.toString() +
            "." +
            imageFile!.path.split('.').last;
      }
      await imageFile!.saveTo(path!);
      File file = File(path);
      return file;
    } catch (e) {
      print("Couldn't write image file");
      return null;
    }
  }

  static Future<File?> writeVideoFile(
      {@required XFile? videoFile, @required String? path}) async {
    try {
      if (path == "") {
        path = await getDirectory();
        if (path == null) return null;
        Directory(path).createSync();
        path += "/" +
            DateTime.now().millisecondsSinceEpoch.toString() +
            "." +
            videoFile!.path.split(".").last;
      }
      await videoFile!.saveTo(path!);
      File file = File(path);
      return file;
    } catch (e) {
      print("Couldn't write video file");
      return null;
    }
  }

  static Future<File?> writeAudioFile(
      {@required String? tmpPath, @required String? path}) async {
    try {
      if (path == "") {
        path = await getDirectory();
        if (path == null) return null;
        Directory(path).createSync();
        path += "/" +
            DateTime.now().millisecondsSinceEpoch.toString() +
            "." +
            tmpPath!.split(".").last;
      }
      File tmpFile = File(tmpPath!);
      File file = File(path!);
      await file.writeAsBytes(tmpFile.readAsBytesSync());
      return file;
    } catch (e) {
      print("Couldn't write audio file");
      return null;
    }
  }

  static Future<String?> getFilePath({
    @required String? mediaType,
    String? subDirectory,
    String? createAt,
    @required int? rank,
    @required String? fileType,
  }) async {
    try {
      String? path = await getDirectory(subDirectory: subDirectory);
      if (path == null) return null;

      Directory directory = await Directory(path).create();
      bool isExists = await directory.exists();
      if (!isExists) return null;

      String fileName = "";
      if (createAt == null) {
        fileName = KeicyDateTime.convertDateTimeToDateString(
            dateTime: DateTime.now(), formats: "YmdHis");
      } else {
        DateTime createAtTime =
            KeicyDateTime.convertDateStringToDateTime(dateString: createAt)!;
        fileName = KeicyDateTime.convertDateTimeToDateString(
            dateTime: createAtTime, formats: "YmdHis");
      }
      if (mediaType == MediaType.picture) {
        mediaType = "photographie";
      } else {
        if (mediaType == MediaType.audio) {
          mediaType = "dictee";
        }
      }

      fileName = "$fileName-$rank-$mediaType.$fileType";

      return "$path/$fileName";
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, int>> dirStatSync({String dirPath = ""}) async {
    int fileNum = 0;
    int totalSize = 0;
    Directory dir;
    if (dirPath == "") {
      String? path = await getDirectory();
      dir = Directory(path!);
    } else
      dir = Directory(dirPath);

    try {
      if (await dir.exists()) {
        dir
            .listSync(recursive: true, followLinks: false)
            .forEach((FileSystemEntity entity) {
          if (entity is File) {
            fileNum++;
            totalSize += entity.lengthSync() ~/ 1024;
          }
        });
      }
    } catch (e) {
      print(e.toString());
    }

    return {'fileNum': fileNum, 'size': totalSize};
  }

  static Future<String?> getDirectory({String? subDirectory}) async {
    Directory? directory;
    String path = "";
    try {
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }
      path = directory!.path;
      path += "/medias";
      if (subDirectory != null) {
        Directory directory = await Directory(path).create();
        bool isExists = await directory.exists();
        if (!isExists) return null;
        path += "/$subDirectory";
      }

      return path;
    } catch (e) {
      return null;
    }
  }
}
