// ignore_for_file: deprecated_member_use, unused_local_variable, use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:matty_app/new_version.dart';
import 'dart:html' as html;
import 'package:xml/xml.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const KMLgrid());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> kmlDownloadList = [];
  List<String> kmlDownloadTitle = [];

  void parseKml(String kmlContent) {
    final document = XmlDocument.parse(kmlContent);
    final coordinates = document.findAllElements('coordinates');
    List<String> coordinatesList = [];
    for (var coordinate in coordinates) {
      coordinatesList.add(coordinate.text.trim());
    }
    final blob = html.Blob([coordinatesList.join('\n')]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    setState(() {
      kmlDownloadList.add(url);
    });
  }

  void downloadFile(String url, String filename) {
    final anchor = html.AnchorElement(
      href: url,
    )
      ..setAttribute("download", filename)
      ..click();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text(
                  "Select a KML file",
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                content: SizedBox(
                  height: 250,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles();
                          if (result != null) {
                            Uint8List fileBytes = result.files.first.bytes!;
                            String kmlContent = utf8.decode(fileBytes);
                            parseKml(kmlContent);
                            Navigator.pop(context);
                          }
                        },
                        child: const Icon(
                          Icons.upload_file,
                          color: Colors.blue,
                          size: 100,
                        ),
                      ),
                      CupertinoButton.filled(
                          child: const Text("Upload"),
                          onPressed: () {
                            Navigator.pop(context);
                          })
                    ],
                  ),
                ),
              ),
            );
          }),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                "Converted KMLs",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: kmlDownloadList.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: ListTile(
                  trailing: const Icon(
                    CupertinoIcons.arrow_down_to_line_alt,
                    color: Colors.blue,
                  ),
                  title: Text(
                    'Download KML ${index + 1}',
                  ),
                  onTap: () {
                    downloadFile(
                        kmlDownloadList[index], 'coordinates${index + 1}.txt');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
