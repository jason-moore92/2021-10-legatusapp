import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legutus/Config/config.dart';
import 'package:legutus/Helpers/http_plus.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Models/local_report_model.dart';

class DebugApiProvider {
  static Future<Map<String, dynamic>> debugReport({
    @required List<dynamic>? planningData,
    @required List<dynamic>? localReports,
    @required UserModel? userModel,
    @required SettingsModel? settingsModel,
  }) async {
    String apiUrl = '/debug-local-reports';

    try {
      String url = AppConfig.apiBaseUrl + apiUrl;

      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "planning": [
            {
              "date": "2020-12-30",
              "literal_date": "Mercredi 30 Décembre 2020",
              "reports": [
                {
                  "report_id": 450,
                  "date": "2021-01-28",
                  "time": "14:58:00",
                  "name": "Nom du constat",
                  "folder_name": "Nom du dossier",
                  "zip_city": "69006 Lyon",
                  "state": "Confirmé",
                  "type": "Libre",
                  "price": "125,54€ TTC",
                  "references": ["Dossier C456321", "Ref 8744467"],
                  "description":
                      "Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet",
                  "address": {
                    "street": "78 boulevard du 11 Novembre 1918",
                    "complement": "immeuble le Rapsody",
                    "zip": "69100",
                    "city": "Villeurbanne",
                    "latitude": "47.4299257898514",
                    "longitude": "2.7389353772979352"
                  },
                  "accounts": [
                    {"name": "Maître Gérard Dupont"}
                  ],
                  "customers": [
                    {
                      "name": "Immobilier SARL",
                      "type": "Société",
                      "address": {
                        "street": "78 boulevard du 11 Novembre 1918",
                        "complement": "immeuble le Rapsody",
                        "zip": "69100",
                        "city": "Villeurbanne",
                        "latitude": "47.4299257898514",
                        "longitude": "2.7389353772979352"
                      },
                      "phone": "01 02 03 04 05",
                      "representation": ["Antoine Bouvier", "né le 17/02/1986", "Gérant", "Nationalité française"],
                      "corp_number": "123 567 876 RSC Lyon",
                      "recipients": [
                        {
                          "name": "Gérard Dupont",
                          "position": "Chef de chantier",
                          "email": "gerard.dupont@email.com",
                          "mobile_phone": "06 02 03 04 05"
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ],
          "user": {
            "name": "John Doe",
            "organization_name": "Etude Dupont & Associés",
            "email": "vladimir@legatus.fr",
            "token":
                "1Uatqy4mir6n7prbf8e9vfw9s3rwccvwwgqznorsaqfplxhvd04xujgng9a9vhk577mrf2gx7lpfa31shvtss3mbg0vr1v4ecpjhb48mtm6wwi6tetipbkssxot4uyrg0gz8r05foipc4ergjzzdncudfui8s781andnpx004ujonskhy9y1mhgncnmgf9f869c7a3uujzk8vx3lijveh8n87rzpi00s3d5dyvpdO1"
          },
          "settings": {"allow_camera": true, "allow_microphone": true, "allow_location": true, "width_restriction": true},
          "local_reports": [
            {
              "report_id": 7654,
              "uuid": "095be615-a8ad-4c33-8e9c-c7612fbf6c9f",
              "device_info": "device_info object as json string",
              "date": "2021-30-06",
              "time": "15:06:45",
              "created_at": "2021-30-06 15:06:45",
              "name": "The report name",
              "type": "free",
              "description":
                  "Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis.",
              "street": "129 rue vauban",
              "complement": "Immeuble le Méridien",
              "zip": "69006",
              "city": "Lyon",
              "latitude": "45.766020",
              "longitude": "4.855060",
              "customer_name": "HUISSIO SAS",
              "customer_type": "individual",
              "customer_street": "78 boulevard du 11 Novembre 1918",
              "customer_complement": "4ème étage",
              "customer_zip": "69100",
              "customer_city": "Villeurbanne",
              "customer_corp_form": "SARL",
              "customer_corp_siren": "123 456 789",
              "customer_corp_rcs": "Lyon",
              "recipient_name": "Vladimir Lorentz",
              "recipient_position": "Gérant",
              "recipient_birth_date": "1986-02-17",
              "recipient_birth_city": "Bron",
              "recipient_email": "vladimir@legatus.fr",
              "recipient_phone": "01 02 03 04 50",
              "medias": [
                {
                  "report_id": null,
                  "type": "picture",
                  "state": "captured",
                  "uuid": "095be615-a8ad-4c33-8e9c-c7612fbf6c9f",
                  "device_info": "device_info object as json string",
                  "created_at": "2021-06-12 14:54:32",
                  "rank": 3,
                  "filename": "20210615102054-1-photographie",
                  "extension": "jpeg",
                  "size": 564345,
                  "path": "your/representation/of/file/path/on/device",
                  "duration": 75,
                  "content":
                      "Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.",
                  "latitude": "45.766020",
                  "longitude": "4.855060"
                }
              ]
            }
          ]
        }),
      );
      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": json.decode(response.body),
          "statusCode": response.statusCode,
        };
      } else {
        return {
          "success": false,
          "data": json.decode(response.body),
          "statusCode": response.statusCode,
        };
      }
    } on SocketException catch (e) {
      return {
        "success": false,
        "message": "Something went wrong",
        "statusCode": e.osError!.errorCode,
      };
    } on PlatformException catch (e) {
      return {
        "success": false,
        "message": "Something went wrong",
        "statusCode": 500,
      };
    } catch (e) {
      print(e);
      return {
        "success": false,
        "message": "Something went wrong",
        "statusCode": 500,
      };
    }
  }
}
