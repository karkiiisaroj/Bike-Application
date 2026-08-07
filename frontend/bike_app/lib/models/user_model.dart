class ProfileModel {
  final String phone;
  final String address;
  final String city;
  final String? avatar;
  final String? dateOfBirth;

  ProfileModel({
    this.phone = '',
    this.address = '',
    this.city = '',
    this.avatar,
    this.dateOfBirth,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    phone: json['phone'] ?? '',
    address: json['address'] ?? '',
    city: json['city'] ?? '',
    avatar: json['avatar'],
    dateOfBirth: json['date_of_birth'],
  );

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'address': address,
    'city': city,
    if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
  };
}

class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final ProfileModel profile;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    username: json['username'] ?? '',
    email: json['email'] ?? '',
    firstName: json['first_name'] ?? '',
    lastName: json['last_name'] ?? '',
    profile: ProfileModel.fromJson(json['profile'] ?? {}),
  );
}
