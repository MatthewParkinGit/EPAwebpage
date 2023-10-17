class Kml {
  String? id;
  String fileName;
  String url;
  List<Map<String, dynamic>> coordinatesList;

  Kml(
      {this.id,
      required this.fileName,
      required this.url,
      required this.coordinatesList});
}