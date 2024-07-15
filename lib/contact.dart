class Contact {
  int? id;
  String name;
  String phone;
  String? image; // New field for the image

  Contact({this.id, required this.name, required this.phone, this.image});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'image': image,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      image: map['image'],
    );
  }
}
