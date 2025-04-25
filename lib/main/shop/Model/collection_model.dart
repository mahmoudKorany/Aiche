class CollectionModel {
  int? id;
  String? name;
  String? description;
  String? image;
  String? total;
  String? createdAt;
  String? updatedAt;

  CollectionModel(
      {this.id,
        this.name,
        this.description,
        this.image,
        this.total,
        this.createdAt,
        this.updatedAt});

  CollectionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    total = json['total'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image'] = image;
    data['total'] = total;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}