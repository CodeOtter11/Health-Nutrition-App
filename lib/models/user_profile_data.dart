class UserProfileData {
  // ---------------- AUTH / BASIC ----------------
  String? name;
  String? email;
  String? phone;
  DateTime? createdAt; // ✅ JOINED DATE

  // ---------------- PERSONAL ----------------
  int? age;
  String? gender;
  int? height;
  int? weight;
  String? city;

  // ---------------- DIET & HEALTH ----------------
  List<String> diseases = [];
  String? dietType;
  Map<String, dynamic>? healthDetails;

  // ---------------- LIFESTYLE ----------------
  String? activityLevel;
  List<String>? habits;

  // ---------------- GOALS ----------------
  String? goal;
  int? targetWeight;

  // ---------------- MARKETING ----------------
  List<String>? referralSource;

  // ---------------- CONSTRUCTOR ----------------
  UserProfileData({
    this.name,
    this.email,
    this.phone,
    this.createdAt,
  });

  // ---------------- FROM BACKEND ----------------
  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    )
      ..age = json['age']
      ..gender = json['gender']
      ..height = json['height']
      ..weight = json['weight']
      ..city = json['city']
      ..dietType = json['dietType']
      ..diseases = List<String>.from(json['diseases'] ?? [])
      ..healthDetails = json['healthDetails']
      ..activityLevel = json['activityLevel']
      ..habits = json['habits'] != null
          ? List<String>.from(json['habits'])
          : null
      ..goal = json['goal']
      ..targetWeight = json['targetWeight']
      ..referralSource = json['referralSource'] != null
          ? List<String>.from(json['referralSource'])
          : null;
  }

  // ---------------- TO BACKEND ----------------
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "city": city,
      "age": age,
      "gender": gender,
      "height": height,
      "weight": weight,
      "dietType": dietType,
      "diseases": diseases,
      "healthDetails": healthDetails,
      "activityLevel": activityLevel,
      "habits": habits,
      "goal": goal,
      "targetWeight": targetWeight,
      "referralSource": referralSource,
    };
  }
}