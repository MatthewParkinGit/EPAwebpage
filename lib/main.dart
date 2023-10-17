// ignore_for_file: deprecated_member_use, unused_local_variable, use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:matty_app/auth.dart';
import 'package:matty_app/firebase_options.dart';
import 'package:matty_app/login.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:xml/xml.dart';
import 'package:file_picker/file_picker.dart';

import 'kml.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'KML Parser',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const AuthPage());
  }
}

class KMLgrid extends StatefulWidget {
  const KMLgrid({super.key});

  @override
  State<KMLgrid> createState() => _KMLgridState();
}

class _KMLgridState extends State<KMLgrid> {
  late User user;
  List<Kml> kmlList = [];

  bool isLoading = true;

  @override
  void initState() {
    setState(() {
      user = FirebaseAuth.instance.currentUser!;
    });
    fetchUserKML();
    super.initState();
  }

  void fetchUserKML() async {
    try {
      var collection = FirebaseFirestore.instance
          .collection('kmlBin')
          .where("userId", isEqualTo: user.uid);
      var querySnapshot = await collection.get();
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        var content = data['kmlContent'];
        var name = data['kmlName'];
        Kml newKML = parseKml(content, name);
        newKML.id = queryDocumentSnapshot.id;
        setState(() {
          kmlList.add(newKML);
        });
      }
      setState(() {
        isLoading = false;
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  XmlElement? getFirstElement(XmlElement element, String query) {
    final elements = element.findElements(query);
    if (elements.isNotEmpty) {
      return elements.first;
    }
    return null;
  }

  Kml parseKml(String kmlContent, String fileName) {
    final document = XmlDocument.parse(kmlContent);
    final placemarks = document.findAllElements('Placemark');
    List<Map<String, dynamic>> coordinatesList = [];
    for (var placemark in placemarks) {
      var name = placemark.findElements('name').first.text;
      // ignore: prefer_typing_uninitialized_variables
      var coordinatesNode;
      var points = placemark.findElements('Point');
      if (points.isNotEmpty) {
        coordinatesNode = points.first.findElements('coordinates').first;
      }
      var polygons = placemark.findElements('Polygon');
      if (coordinatesNode == null && polygons.isNotEmpty) {
        coordinatesNode = polygons.first
            .findElements('outerBoundaryIs')
            .first
            .findElements('LinearRing')
            .first
            .findElements('coordinates')
            .first;
      }
      var linestrings = placemark.findElements('LineString');
      if (coordinatesNode == null && linestrings.isNotEmpty) {
        coordinatesNode = linestrings.first.findElements('coordinates').first;
      }
      if (coordinatesNode != null) {
        var coordinateStrings = coordinatesNode.text
            .trim()
            .split('\n')
            .map((e) => e.trim().replaceAll('\r', ''))
            .map((e) {
          var parts = e.split(',');
          if (parts.last == '0') parts.removeLast(); // Check before removing
          return parts.join(' ');
        }).join(' '); // Join all coordinates into a single string
        coordinatesList.add({name: coordinateStrings});
      }
    }
    final jsonBlob = html.Blob([jsonEncode(coordinatesList)]);
    final url = html.Url.createObjectUrlFromBlob(jsonBlob);

    Kml newKml =
        Kml(fileName: fileName, url: url, coordinatesList: coordinatesList);
    return newKml;
  }

  void downloadFile(String url, String filename, String fileExtension) {
    final anchor = html.AnchorElement(
      href: url,
    )
      ..setAttribute("download", filename + fileExtension)
      ..click();
  }

  List<Kml> selectedKmls = [];

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.white,
              title: Text(
                "KML Convertor, ${user!.email}",
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 30,
                    color: Colors.black),
              ),
              actions: [
                CupertinoButton(
                    onPressed: signOut,
                    child: const Icon(
                      Icons.logout,
                      color: Colors.black,
                    ))
              ],
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(100),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
                          ElevatedButton(
                              child: const Row(children: [
                                Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                Text("Upload"),
                              ]),
                              onPressed: () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['kml'],
                                );
                                if (result != null) {
                                  Uint8List fileBytes =
                                      result.files.first.bytes!;
                                  String kmlContent = utf8.decode(fileBytes);
                                  String fileName = result.files.first.name;
                                  Kml newKml = parseKml(kmlContent, fileName);

                                  try {
                                    DocumentReference dofRef =
                                        await FirebaseFirestore.instance
                                            .collection('kmlBin')
                                            .add({
                                      'kmlContent': kmlContent,
                                      'kmlName': fileName,
                                      'userId': user.uid
                                    });

                                    newKml.id = dofRef.id;
                                    setState(() {
                                      kmlList.add(newKml);
                                    });
                                  } on FirebaseException catch (e) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => const AlertDialog(
                                        title: Text("Failed to upload KML"),
                                        content: Text(
                                            "Please contact: matthew.parkin@hotmail.co.uk"),
                                      ),
                                    );
                                  }
                                }
                              }),
                          const SizedBox(
                            width: 60,
                          ),
                          ElevatedButton(
                              onPressed: selectedKmls.isNotEmpty
                                  ? () {
                                      if (selectedKmls.length > 1) {
                                        Map<String, List<Map<String, dynamic>>>
                                            output = {
                                          for (var kml in selectedKmls)
                                            kml.fileName: kml.coordinatesList
                                        };
                                        final urlblob =
                                            html.Blob([jsonEncode(output)]);
                                        final url =
                                            html.Url.createObjectUrlFromBlob(
                                                urlblob);
                                        downloadFile(
                                            url, "ConvertKMLs", ".txt");
                                      } else {
                                        for (int i = 0;
                                            i < selectedKmls.length;
                                            i++) {
                                          downloadFile(selectedKmls[i].url,
                                              selectedKmls[i].fileName, ".txt");
                                        }
                                      }
                                      setState(() {
                                        selectedKmls.clear();
                                      });
                                    }
                                  : null,
                              child: const Row(children: [
                                Icon(
                                  CupertinoIcons.arrow_down_to_line,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Export as Text",
                                ),
                              ])),
                          const SizedBox(
                            width: 60,
                          ),
                          ElevatedButton(
                            onPressed: selectedKmls.isNotEmpty
                                ? () {
                                    if (selectedKmls.length > 1) {
                                      Map<String, List<Map<String, dynamic>>>
                                          output = {
                                        for (var kml in selectedKmls)
                                          kml.fileName: kml.coordinatesList
                                      };
                                      final urlblob =
                                          html.Blob([jsonEncode(output)]);
                                      final url =
                                          html.Url.createObjectUrlFromBlob(
                                              urlblob);
                                      downloadFile(url, "ConvertKMLs", ".json");
                                    } else {
                                      for (int i = 0;
                                          i < selectedKmls.length;
                                          i++) {
                                        downloadFile(selectedKmls[i].url,
                                            selectedKmls[i].fileName, ".json");
                                      }
                                    }
                                    setState(() {
                                      selectedKmls.clear();
                                    });
                                  }
                                : null,
                            child: const Row(children: [
                              Icon(
                                Icons.file_open_outlined,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Export as JSON",
                              ),
                            ]),
                          ),
                          const SizedBox(
                            width: 60,
                          ),
                          ElevatedButton(
                            onPressed: selectedKmls.isNotEmpty
                                ? () {
                                    for (int i = 0;
                                        i < selectedKmls.length;
                                        i++) {
                                      try {
                                        FirebaseFirestore.instance
                                            .collection("kmlBin")
                                            .doc(selectedKmls[i].id)
                                            .delete();
                                      } on FirebaseException catch (e) {
                                        print(e);
                                      }
                                    }
                                    setState(() {
                                      print(kmlList.length.toString);
                                      selectedKmls.forEach((selectedKML) {
                                        kmlList.removeWhere(
                                            (kml) => kml.id == selectedKML.id);
                                      });
                                      selectedKmls.clear();
                                      print(kmlList.length.toString);
                                    });
                                  }
                                : null,
                            child: const Row(children: [
                              Icon(
                                Icons.clear,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Remove",
                              ),
                            ]),
                          )
                        ],
                      ),
                    ),
                  )),
            ),
            body: Padding(
              padding: const EdgeInsets.only(left: 30, top: 50),
              child: kmlList.isEmpty
                  ? Center(
                      child: Container(
                        height: 600,
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file_outlined,
                                size: 120,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "No Files Uploaded",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 24,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Container(
                        height: 600,
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 50,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 50, right: 50),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Uploaded KML",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  GestureDetector(
                                      child: Text("Clear Selection",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: selectedKmls.isEmpty
                                                ? Colors.grey
                                                : Colors.blue,
                                          )),
                                      onTap: () {
                                        setState(() {
                                          selectedKmls.clear();
                                        });
                                      })
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: kmlList.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.only(
                                      left: 30, right: 30),
                                  child: ListTile(
                                    leading:
                                        selectedKmls.contains(kmlList[index])
                                            ? const Icon(
                                                Icons.check_circle_rounded,
                                                color: Colors.blue,
                                              )
                                            : const Icon(Icons.circle_outlined),
                                    title: Text(
                                      kmlList[index].fileName,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        selectedKmls.contains(kmlList[index])
                                            ? selectedKmls
                                                .remove(kmlList[index])
                                            : selectedKmls.add(kmlList[index]);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          );
  }
}
