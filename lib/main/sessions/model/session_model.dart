class SessionModel {
  int? id;
  String? title;
  String? description;
  String? link;
  String? date;
  User? user;

  SessionModel(
      {this.id, this.title, this.description, this.link, this.date, this.user});

  SessionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    link = json['link'];
    date = json['date'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['link'] = link;
    data['date'] = date;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? name;
  String? title;

  User({this.name, this.title});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['title'] = title;
    return data;
  }
}