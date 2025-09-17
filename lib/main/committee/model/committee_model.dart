class CommitteeModel {
  int? id;
  String? name;
  String? description;
  String? img;
  List<Admins>? admins;

  CommitteeModel({this.id, this.name, this.description, this.img, this.admins});

  CommitteeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    img = json['img'];
    if (json['admins'] != null) {
      admins = <Admins>[];
      json['admins'].forEach((v) {
        if (v['name'] != 'admin' &&
            v['name'] != 'Fatma Gamal' &&
            v['name'] != 'abdallah' &&
            v['name'] != 'fatma g') {
          admins!.add(Admins.fromJson(v));
        }
      });
      // remove duplicates
      final ids = <String>{};
      admins = admins!.where((admin) => ids.add(admin.title!)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['img'] = img;
    if (admins != null) {
      data['admins'] = admins!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Admins {
  int? id;
  String? name;
  String? title;
  Profile? profile;

  Admins({this.id, this.name, this.title, this.profile});

  Admins.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    title = json['title'];
    profile =
        json['profile'] != null ? Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['title'] = title;
    if (profile != null) {
      data['profile'] = profile!.toJson();
    }
    return data;
  }
}

class Profile {
  int? id;
  int? userId;
  String? image;
  String? bio;
  String? phone;
  String? linkedin;
  String? createdAt;
  String? updatedAt;

  Profile(
      {this.id,
      this.userId,
      this.image,
      this.bio,
      this.phone,
      this.linkedin,
      this.createdAt,
      this.updatedAt});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'] is String ? int.tryParse(json['id']) : json['id'];
    userId = json['user_id'] is String
        ? int.tryParse(json['user_id'])
        : json['user_id'];
    image = json['image'];
    bio = json['bio'];
    phone = json['phone'];
    linkedin = json['linkedin'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['image'] = image;
    data['bio'] = bio;
    data['phone'] = phone;
    data['linkedin'] = linkedin;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
