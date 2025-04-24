class MaterialModel {
  String? name;
  String? department;
  String? semester;
  String? link;

  MaterialModel({this.name, this.department, this.semester, this.link});

  MaterialModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    department = json['department'];
    semester = json['semester'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['department'] = department;
    data['semester'] = semester;
    data['link'] = link;
    return data;
  }
}