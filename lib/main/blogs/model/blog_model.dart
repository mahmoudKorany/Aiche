class BlogModel {
  int? id;
  String? title;
  String? description;
  String? image;
  User? user;
  String ? createdAt;
  String? updatedAt;

  BlogModel({this.id, this.title, this.description, this.image, this.user,this.createdAt, this.updatedAt});

  BlogModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? title;
  String? imageUrl;
  String? bio;
  String? phone;
  String? linkedInLink;

  User(
      {this.id,
        this.name,
        this.title,
      this.imageUrl,this.linkedInLink,this.phone,this.bio});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    title = json['title'];
    imageUrl = json['image'];
    bio = json['bio'];
    phone = json['phone '];
    linkedInLink = json['linkedin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['title'] = title;
    data['image'] = imageUrl;
    data['bio'] = bio;
    data['phone'] = phone;
    data['linkedin'] = linkedInLink;
    return data;
  }
}