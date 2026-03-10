class Patient {
  int? id;
  String name;
  String age;
  String phone;
  String disease;
  String image;

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.phone,
    required this.disease,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'phone': phone,
      'disease': disease,
      'image': image,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'] ?? '',
      age: map['age'].toString(),
      phone: map['phone'] ?? '',
      disease: map['disease'] ?? '',
      image: map['image'] ?? '',
    );
  }
}