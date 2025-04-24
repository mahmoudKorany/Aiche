class BannerModel {
  String? image;
  String? link;
  String? title;
  String? type;
  int? id;

  BannerModel({this.image, this.link, this.title, this.type, this.id});

  BannerModel.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    link = json['link'];
    title = json['title'];
    type = json['type'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['link'] = link;
    data['title'] = title;
    data['type'] = type;
    data['id'] = id;
    return data;
  }
}