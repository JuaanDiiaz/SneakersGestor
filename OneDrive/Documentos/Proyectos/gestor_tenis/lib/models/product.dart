// To parse this JSON data, do
//
//     final product = productFromMap(jsonString);

import 'dart:convert';

class Product {
    Product({
        required this.available,
        required this.name,
        this.picture,
        required this.price,
        this.id,
        required this.brand,
        required this.gender,
        required this.size,
        required this.color,
    });

    bool available;
    String name;
    String? picture;
    double price;
    String? id;
    String brand;
    String gender;
    String size;
    String color;

    factory Product.fromJson(String str) => Product.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory Product.fromMap(Map<String, dynamic> json) => Product(
        available: json["available"],
        name: json["name"],
        picture: json["picture"],
        price: json["price"].toDouble(),
        id: json["id"],
        brand: json["brand"],
        gender: json["gender"],
        size: json["size"],
        color: json["color"],
    );

    Map<String, dynamic> toMap() => {
        "available": available,
        "name": name,
        "picture": picture,
        "price": price,
        "id": id,
        "brand": brand,
        "gender": gender,
        "size": size,
        "color": color,
    };

    Product copy() => Product(
      available: available,
      name: name,
      picture: picture,
      price: price,
      id: id,
      brand: brand,
      gender: gender,
      size: size,
      color: color,
    );
}
