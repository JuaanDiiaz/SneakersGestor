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
    this.details,
  });

  bool available;
  String name;
  String? picture;
  double price;
  String? id;
  String brand;
  String gender;
  List<ProductDetails>? details;

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
        details: json["details"] != null
            ? List<ProductDetails>.from(
                json["details"].map((x) => ProductDetails.fromMap(x)))
            : null,
      );

  Map<String, dynamic> toMap() => {
        "available": available,
        "name": name,
        "picture": picture,
        "price": price,
        "id": id,
        "brand": brand,
        "gender": gender,
        "details": details != null
            ? List<dynamic>.from(details!.map((x) => x.toMap()))
            : null,
      };

  Product copy() => Product(
        available: available,
        name: name,
        picture: picture,
        price: price,
        id: id,
        brand: brand,
        gender: gender,
        details: details,
      );
}

class ProductDetails {
  ProductDetails(this.color, this.sizes, this.mainImage, this.images);

  int color;
  List<Map<String, int>> sizes;
  String mainImage;
  List<String> images;

  factory ProductDetails.fromJson(String str) =>
      ProductDetails.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProductDetails.fromMap(Map<String, dynamic> json) => ProductDetails(
        json["color"] ?? 0, // Valor predeterminado para color
        json["sizes"] != null
            ? List<Map<String, int>>.from(json["sizes"].map((x) =>
                Map<String, int>.from(x.map((k, v) => MapEntry(k, v.toInt())))))
            : [], // Lista vacía si sizes es nulo
        json["mainImage"] ?? '', // Cadena vacía si mainImage es nulo
        json["images"] != null
            ? List<String>.from(json["images"].map((x) => x))
            : [], // Lista vacía si images es nulo
      );

  Map<String, dynamic> toMap() => {
        "color": color,
        "sizes": List<dynamic>.from(sizes.map((x) => x)),
        "mainImage": mainImage,
        "images": List<dynamic>.from(images.map((x) => x)),
      };
}
