class EventModel {
  bool? success;
  int? id;
  String? title;
  String? description;
  String? startDate;
  String? endDate;
  String? place;
  String? formLink;
  String? facebookLink;
  String? category;
  String? status;
  List<Image>? image;

  EventModel(
      {this.success,
      this.id,
      this.title,
      this.description,
      this.startDate,
      this.endDate,
      this.place,
      this.formLink,
      this.facebookLink,
      this.category,
      this.status,
      this.image});

  EventModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    id = json['id'];
    title = json['title'];
    description = json['description'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    place = json['place'];
    formLink = json['formLink'];
    facebookLink = json['facebookLink'];
    category = json['category'];
    status = json['status'];
    // Fix: API returns 'images' (plural) not 'image' (singular)
    if (json['images'] != null) {
      image = <Image>[];
      json['images'].forEach((v) {
        image!.add(Image.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['place'] = place;
    data['formLink'] = formLink;
    data['facebookLink'] = facebookLink;
    data['category'] = category;
    data['status'] = status;
    if (image != null) {
      data['image'] = image!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Image {
  int? id;
  String? imagePath;

  Image({this.id, this.imagePath});

  Image.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imagePath = json['image_path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image_path'] = imagePath;
    return data;
  }
}
