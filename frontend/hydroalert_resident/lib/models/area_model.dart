class AreaModel {
  final String id;
  final String suburbName;
  final String municipalityName;

  AreaModel({
    required this.id,
    required this.suburbName,
    required this.municipalityName,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['areaID'],
      suburbName: json['suburbName'],
      municipalityName: json['municipalityName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'areaID': id,
      'suburbName': suburbName,
      'municipalityName': municipalityName,
    };
  }
}