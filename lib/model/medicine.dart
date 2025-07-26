import 'dart:convert';

class medicine {
  final dynamic id; // can be String (Mongo _id) or int (FakeStore)
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final Rating? rating;
  bool isFavorite;

  medicine({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    this.rating,
    this.isFavorite = false,
  });

  factory medicine.fromJson(Map<String, dynamic> json) {
    // Support both fakestoreapi and backend formats
    final dynamic id = json['id'] ?? json['_id'];
    final String title = json['title'] ?? json['name'] ?? '';
    final String image = json['image'] ?? json['imageUrl'] ?? '';
    final ratingJson = json['rating'];

    return medicine(
      id: id,
      title: title,
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      category: json['category'] ?? 'unknown',
      image: image,
      rating: ratingJson != null ? Rating.fromJson(ratingJson) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      if (rating != null) 'rating': rating!.toJson(),
      'isFavorite': isFavorite,
    };
  }

  medicine copyWith({
    dynamic id,
    String? title,
    double? price,
    String? description,
    String? category,
    String? image,
    Rating? rating,
    bool? isFavorite,
  }) {
    return medicine(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class Rating {
  final double rate;
  final int count;

  Rating({required this.rate, required this.count});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(rate: json['rate'].toDouble(), count: json['count']);
  }

  Map<String, dynamic> toJson() {
    return {'rate': rate, 'count': count};
  }
}

List<medicine> productsFromJson(String str) {
  final List<dynamic> jsonData = json.decode(str);
  return jsonData.map((x) => medicine.fromJson(x)).toList();
}

String productsToJson(List<medicine> data) {
  final List<Map<String, dynamic>> jsonData = data
      .map((x) => x.toJson())
      .toList();
  return json.encode(jsonData);
}
