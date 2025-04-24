class UserModel {
  int? id;
  String? name;
  String? email;
  String? emailVerifiedAt;
  String? fcmToken;
  String? createdAt;
  String? updatedAt;
  String? imageUrl;
  String? bio;
  String? phone;
  String? linkedInLink;

  UserModel(
      {this.id,
      this.name,
      this.email,
      this.emailVerifiedAt,
      this.fcmToken,
      this.createdAt,
      this.updatedAt,
      this.imageUrl,
      this.bio,
      this.phone,
      this.linkedInLink});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'] ?? '';
    fcmToken = json['fcm_token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    imageUrl = json['image_url'] ?? '';
    bio = json['bio'] ?? '';
    phone = json['phone'] ?? '';
    linkedInLink = json['linkedIn_link'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['email_verified_at'] = emailVerifiedAt;
    data['fcm_token'] = fcmToken;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['image_url'] = imageUrl;
    data['bio'] = bio;
    data['phone'] = phone;
    data['linkedIn_link'] = linkedInLink;
    return data;
  }
}
