class MemberModel {
  final String id;
  final String name;
  final int age;
  final double weight;
  final String height;
  final double fees;
  final String imagePath;
  final int mobile;
  final String email;



  MemberModel({
    required this.id,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.fees,
    required this.imagePath,
    required this.mobile,
    required this.email,
  });

  // 🔹 Convert to Map (for Firebase or local storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'fees': fees,
      'imagePath': imagePath,
      'mobile': mobile,
      'email': email,

    };
  }

  // 🔹 Create MemberModel from Map
  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      weight: (map['weight'] ?? 0).toDouble(),
      height: map['height'] ?? '',
      fees: (map['fees'] ?? 0).toDouble(),
      imagePath: map['imagePath'] ?? '',
      mobile: map['mobile'] ?? 0,
      email: map['email'] ?? '',
    );
  }
}
