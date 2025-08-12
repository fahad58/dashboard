import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  String? token;
  String? name;
  String? surname;
  String? email;
  String? street;
  String? housenumber;
  String? postalcode;
  String? city;
  UserData(
      {this.token,
      this.name,
      this.surname,
      this.email,
      this.city,
      this.housenumber,
      this.postalcode,
      this.street});
  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token').toString();
    return token;
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      token: json['token'],
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      street: json['street'],
      housenumber: json['housenumber'],
      postalcode: json['postalcode'],
      city: json['city'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'name': name,
      'surname': surname,
      'email': email,
      'street': street,
      'housenumber': housenumber,
      'postalcode': postalcode,
      'city': city,
    };
  }

  bool get isEmpty => name!.isEmpty && email!.isEmpty;
}
