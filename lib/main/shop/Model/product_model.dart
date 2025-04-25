class ProductModel {
  int? id;
  String? name;
  String? image;
  String? link;
  String? price;
  String? createdAt;
  String? updatedAt;

  ProductModel(
      {this.id,
        this.name,
        this.image,
        this.link,
        this.price,
        this.createdAt,
        this.updatedAt});

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    link = json['link'];
    price = json['price'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['link'] = link;
    data['price'] = price;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}