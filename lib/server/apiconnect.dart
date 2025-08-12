import 'dart:io';

import 'package:dashboard_ui/corps/object.dart';
import 'package:dashboard_ui/corps/userinterface.dart';
import 'package:dashboard_ui/pdf_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'dart:convert';


import 'package:syncfusion_flutter_pdf/pdf.dart';



//'https://myimmoserver.vercel.app'
//http://127.0.0.1:1338
class ServerHandler {
  String IP = 'https://myimmoserver.vercel.app';
  Map<String, String> Headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };
  String Request;
  Map<String, dynamic> sendData;
  ServerHandler({required this.Request, required this.sendData});
  Uri initUrl() {
    Uri request_url = Uri.parse("${IP}$Request");
    return request_url;
  }

  Future<String> LoginUser() async {
    try {
      Uri request_url = initUrl();
      final response = await http.post(request_url,
          headers: Headers, body: jsonEncode(sendData));
      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = jsonDecode(response.body);
        UserData userData = UserData();
        userData.token = responseMap['token'];
        return responseMap['token'].toString();
      } else {
        Map<String, dynamic> responseMap = jsonDecode(response.body);
        if (responseMap['token'] == 'no_user') {
          return 'no_user';
        }
      }
    } catch (e) {
      print('during run error $e');
      return 'error';
    }
    return 'error';
  }

  Future<UserData> getUserData() async {
    Uri request_url = initUrl();
    final response = await http.post(request_url,
        headers: Headers, body: jsonEncode(sendData));
    if (response.statusCode == 200) {
      Map<String, dynamic> responseMap = jsonDecode(response.body);
      Map<String, dynamic> data = responseMap['response'];

      UserData userData = UserData.fromJson(data);

      return userData;
    }
    return UserData();
  }

  Future<String> RegisterUser() async {
    try {
      Uri request_url = initUrl();
      final response = await http.post(request_url,
          headers: Headers, body: jsonEncode(sendData));
      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = jsonDecode(response.body);
        UserData userData = UserData();
        userData.token = responseMap['token'];
        return responseMap['token'].toString();
      } else {
        Map<String, dynamic> responseMap = jsonDecode(response.body);
        if (responseMap["message"] == 'Username-already-exists') {
          return 'already_exist';
        } else if (responseMap['message'] == 'wrong_code') {
          return 'wrong_code';
        }
      }
    } catch (a) {
      print('during run error');
      return 'error';
    }
    return 'error';
  }

  Future<String> InitializeRegistration() async {
    try {
      Uri request_url = initUrl();
      final response = await http.post(request_url,
          headers: Headers, body: jsonEncode(sendData));
      if (response.statusCode == 200) {
        return 'success';
      } else {
        return 'error';
      }
    } catch (e) {
      return 'error';
    }
  }

  Future<List<Objects>> RequestObjects() async {
    try {
      print('hey');
      Uri request_url = initUrl();
      final response = await http.post(request_url,
          headers: Headers, body: jsonEncode(sendData));
      if (response.statusCode == 200) {
        print('hey');
        Map<String, dynamic> responseMap = jsonDecode(response.body);
        print(responseMap);
        dynamic objectsfromserver = responseMap['response'];
        List<Objects> temporary = [];
        if (objectsfromserver != []) {
          for (dynamic property in objectsfromserver) {
            temporary.add(Objects.fromJson(property));
          }
          print(temporary);
          return temporary;
        }
        return [];
      }
    } catch (e) {
      print('error during runnnnn');
      print(e);
      return [];
    }
    print('miay');
    return [];
  }

  Future<String> uploadObjects() async {
    try {
      Uri request_url = initUrl();
      final response = await http.post(request_url,
          headers: Headers, body: jsonEncode(sendData));
      if (response.statusCode == 200) {
        return 'success';
      }
    } catch (e) {
      print('during run error $e');
      return 'error';
    }
    return 'error';
  }

  //later adjustment
  Future<String> changeObjectdetails() async {
    Uri request_url = initUrl();
    final respone = await http.post(request_url,
        headers: Headers, body: jsonEncode(sendData));
    if (respone.statusCode == 200) {
      return 'success';
    }
    return 'error';
  }

  Future<String> changeTenantdetails() async {
    Uri request_url = initUrl();
    final respone = await http.post(request_url,
        headers: Headers, body: jsonEncode(sendData));
    if (respone.statusCode == 200) {
      return 'success';
    }
    return 'error';
  }

  Future<String> createPDF() async {
    Uri request_url = initUrl();
    final response = await http.post(request_url,
        headers: Headers, body: jsonEncode(sendData));
    if (response.statusCode == 200) {
      return 'success';
    }
    return 'error';
  }

  Future<String> uploadAbrechnung() async {
    Uri request_url = initUrl();
    final response = await http.post(request_url,
        headers: Headers, body: jsonEncode(sendData));
    if (response.statusCode == 200) {
      return 'success';
    }
    return 'error';
  }

  Future<Map<String, dynamic>> receiveAbrechnung() async {
    Uri request_url = initUrl();
    final response = await http.post(request_url,
        headers: Headers, body: jsonEncode(sendData));
    if (response.statusCode == 200) {
      Map<String, dynamic> responseMap = jsonDecode(response.body);
      Map<String, dynamic> data = responseMap['response'];

      Abrechnungs abrechnung = Abrechnungs(
          abrechnungId: data['abrechnung_id'],
          objectId: data['object_id'],
          year: data['year'],
          kosten: data['kosten']);

      Map<String, dynamic> endabrechnung = abrechnung.toJson();
      print(responseMap.toString());
      print(abrechnung.abrechnungId);
      print(endabrechnung);

      return endabrechnung;
    }
    return {};
  }

  Future<int> getAbrechnunggesamt() async {
    int kosten = 0;
    Uri request_url = initUrl();
    final response = await http.post(request_url,
        headers: Headers, body: jsonEncode(sendData));
    if (response.statusCode == 200) {
      Map<String, dynamic> responseMap = jsonDecode(response.body);
      int data = responseMap['response'];
      kosten = data;
      return kosten;
    }
    return kosten;
  }

  Future<String> changeRentIncrease() async {
    Uri request_url = initUrl();
    final respone = await http.post(request_url,
        headers: Headers, body: jsonEncode(sendData));
    if (respone.statusCode == 200) {
      return 'success';
    }
    return 'error';
  }

  Future<Map<String, dynamic>> scandocument() async {
    Uri request_url = initUrl();
    final response = await http.post(request_url,
        headers: Headers, body: jsonEncode(sendData));
    if (response.statusCode == 200) {
      Map<String, dynamic> responseMap = jsonDecode(response.body);
      Map<String, dynamic> data = responseMap['response'];

      return data;
    }
    return {};
  }

  //ich muss alle mieter jahreabrechnung erstellen
  //das heisst ich brauche die ids von allen
  Future<void> createAbrechnungall(
      List<Map<String, dynamic>> ids, BuildContext context) async {
    final dir = await getTemporaryDirectory();
    final requestUrl = initUrl();

    final mergedDocument = PdfDocument();

    for (final id in ids) {
      sendData['tenantid'] = id['tenantid'];
      sendData['unitid'] = id['unitid'];

      try {
        final response = await http.post(
          requestUrl,
          headers: Headers,
          body: jsonEncode(sendData),
        );

        if (response.statusCode != 200) {
          debugPrint(
              'Fehler bei Tenant ${id['tenantid']} - Status: ${response.statusCode}');
          continue;
        }

        final bytes = response.bodyBytes;
        final srcPdf = PdfDocument(inputBytes: bytes);

        for (var p = 0; p < srcPdf.pages.count; p++) {
          final srcPage = srcPdf.pages[p];

          // Template aus Quellseite
          final template = srcPage.createTemplate();

          // Volle Seitengröße inkl. Ränder
          final fullSize = Size(srcPage.size.width, srcPage.size.height);

          // Section ohne Ränder erstellen
          final section = mergedDocument.sections!.add();
          section.pageSettings.margins.all = 0;
          section.pageSettings.size = fullSize;

          // Zielseite anlegen und Template exakt einzeichnen
          final dstPage = section.pages.add();
          dstPage.graphics
              .drawPdfTemplate(template, const Offset(0, 0), fullSize);
        }

        srcPdf.dispose();
      } catch (e) {
        debugPrint('Fehler beim Verarbeiten von ${id['tenantid']}: $e');
        continue;
      }
    }

    final mergedBytes = await mergedDocument.save();
    mergedDocument.dispose();

    final mergedFile = File('${dir.path}/all_tenants.pdf');
    await mergedFile.writeAsBytes(mergedBytes);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFLoaderScreen(pdfPath: mergedFile.path),
      ),
    );
  }

  Future<void> createAbrechnungallmainscreen(
      List<Map<String, dynamic>> ids, BuildContext context) async {
    final dir = await getTemporaryDirectory();
    final requestUrl = initUrl();

    final mergedDocument = PdfDocument();

    for (final id in ids) {
      sendData['objectid'] = id['objectid'];
      for (final m in id['unitdata']) {
        sendData['tenantid'] = m['tenantid'];
        sendData['unitid'] = m['unitid'];
        try {
          final response = await http.post(
            requestUrl,
            headers: Headers,
            body: jsonEncode(sendData),
          );

          if (response.statusCode != 200) {
            debugPrint(
                'Fehler bei Tenant ${id['tenantid']} - Status: ${response.statusCode}');
            continue;
          }

          final bytes = response.bodyBytes;
          final srcPdf = PdfDocument(inputBytes: bytes);

          for (var p = 0; p < srcPdf.pages.count; p++) {
            final srcPage = srcPdf.pages[p];

            // Template aus Quellseite
            final template = srcPage.createTemplate();

            // Volle Seitengröße inkl. Ränder
            final fullSize = Size(srcPage.size.width, srcPage.size.height);

            // Section ohne Ränder erstellen
            final section = mergedDocument.sections!.add();
            section.pageSettings.margins.all = 0;
            section.pageSettings.size = fullSize;

            // Zielseite anlegen und Template exakt einzeichnen
            final dstPage = section.pages.add();
            dstPage.graphics
                .drawPdfTemplate(template, const Offset(0, 0), fullSize);
          }

          srcPdf.dispose();
        } catch (e) {
          debugPrint('Fehler beim Verarbeiten von ${id['tenantid']}: $e');
          continue;
        }
      }
    }

    final mergedBytes = await mergedDocument.save();
    mergedDocument.dispose();

    final mergedFile = File('${dir.path}/all_tenants.pdf');
    await mergedFile.writeAsBytes(mergedBytes);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFLoaderScreen(pdfPath: mergedFile.path),
      ),
    );
  }

  Future<void> createErhohungallmainscreen(
      List<Map<String, dynamic>> ids, BuildContext context) async {
    final dir = await getTemporaryDirectory();
    final requestUrl = initUrl();

    final mergedDocument = PdfDocument();

    for (final id in ids) {
      sendData['objectid'] = id['objectid'];
      for (final m in id['unitdata']) {
        sendData['tenantid'] = m['tenantid'];
        sendData['unitid'] = m['unitid'];
        try {
          final response = await http.post(
            requestUrl,
            headers: Headers,
            body: jsonEncode(sendData),
          );

          if (response.statusCode != 200) {
            debugPrint(
                'Fehler bei Tenant ${id['tenantid']} - Status: ${response.statusCode}');
            continue;
          }

          final bytes = response.bodyBytes;
          final srcPdf = PdfDocument(inputBytes: bytes);

          for (var p = 0; p < srcPdf.pages.count; p++) {
            final srcPage = srcPdf.pages[p];

            // Template aus Quellseite
            final template = srcPage.createTemplate();

            // Volle Seitengröße inkl. Ränder
            final fullSize = Size(srcPage.size.width, srcPage.size.height);

            // Section ohne Ränder erstellen
            final section = mergedDocument.sections!.add();
            section.pageSettings.margins.all = 0;
            section.pageSettings.size = fullSize;

            // Zielseite anlegen und Template exakt einzeichnen
            final dstPage = section.pages.add();
            dstPage.graphics
                .drawPdfTemplate(template, const Offset(0, 0), fullSize);
          }

          srcPdf.dispose();
        } catch (e) {
          debugPrint('Fehler beim Verarbeiten von ${id['tenantid']}: $e');
          continue;
        }
      }
    }

    final mergedBytes = await mergedDocument.save();
    mergedDocument.dispose();

    final mergedFile = File('${dir.path}/all_tenants.pdf');
    await mergedFile.writeAsBytes(mergedBytes);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFLoaderScreen(pdfPath: mergedFile.path),
      ),
    );
  }

  Future<void> createErhohungall(
      List<Map<String, dynamic>> ids, BuildContext context) async {
    final dir = await getTemporaryDirectory();
    final requestUrl = initUrl();

    final mergedDocument = PdfDocument();

    for (final id in ids) {
      sendData['tenantid'] = id['tenantid'];
      sendData['unitid'] = id['unitid'];

      try {
        final response = await http.post(
          requestUrl,
          headers: Headers,
          body: jsonEncode(sendData),
        );

        if (response.statusCode != 200) {
          debugPrint(
              'Fehler bei Tenant ${id['tenantid']} - Status: ${response.statusCode}');
          continue;
        }

        final bytes = response.bodyBytes;
        final srcPdf = PdfDocument(inputBytes: bytes);

        for (var p = 0; p < srcPdf.pages.count; p++) {
          final srcPage = srcPdf.pages[p];

          // Template aus Quellseite
          final template = srcPage.createTemplate();

          // Volle Seitengröße inkl. Ränder
          final fullSize = Size(srcPage.size.width, srcPage.size.height);

          // Section ohne Ränder erstellen
          final section = mergedDocument.sections!.add();
          section.pageSettings.margins.all = 0;
          section.pageSettings.size = fullSize;

          // Zielseite anlegen und Template exakt einzeichnen
          final dstPage = section.pages.add();
          dstPage.graphics
              .drawPdfTemplate(template, const Offset(0, 0), fullSize);
        }

        srcPdf.dispose();
      } catch (e) {
        debugPrint('Fehler beim Verarbeiten von ${id['tenantid']}: $e');
        continue;
      }
    }

    final mergedBytes = await mergedDocument.save();
    mergedDocument.dispose();

    final mergedFile = File('${dir.path}/all_tenants.pdf');
    await mergedFile.writeAsBytes(mergedBytes);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFLoaderScreen(pdfPath: mergedFile.path),
      ),
    );
  }
}
