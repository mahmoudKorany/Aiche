class AwardsModel {
  int? id;
  String? title;
  String? description;
  String? date;

  AwardsModel({this.id, this.title, this.description, this.date});

  AwardsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['date'] = date;
    return data;
  }
}
