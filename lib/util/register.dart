import 'dart:convert';

import 'package:dashboard_ui/const/constant.dart';
import 'package:dashboard_ui/screens/main_screen.dart';
import 'package:dashboard_ui/server/apiconnect.dart';
import 'package:dashboard_ui/util/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

const String kGoogleApiKey = "AIzaSyDtkobiOYUM6siPJZSrTATgadHKxohxrLU";

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pwdController = TextEditingController();
  final _controlpwdController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  String _passwordInput = '';

  bool agreed = false;
  bool _isPwdObscured = true;
  bool _isControlPwdObscured = true;
  bool isLoading = false;
  String _geschlechtamount = 'Herr';
  final List<String> _geschlechterOption = ['Herr', "Frau"];
  bool initialpwdinsert = false;

  List<Map<String, String>> _suggestions = [];
  void _searchPlace(String input) async {
    if (input.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$kGoogleApiKey&language=de&components=country:de';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List predictions = data['predictions'];

      setState(() {
        _suggestions = predictions
            .map<Map<String, String>>((p) => {
                  'description': p['description'],
                  'place_id': p['place_id'],
                })
            .toList();
      });
    } else {
      print("Autocomplete Fehler: ${response.body}");
    }
  }

  Future<void> _getAddressDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$kGoogleApiKey&language=de';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final components = data['result']['address_components'] as List;

      for (var component in components) {
        final types = component['types'] as List;

        if (types.contains('route')) {
          _streetController.text = component['long_name'];
        } else if (types.contains('street_number')) {
          _houseNumberController.text = component['long_name'];
        } else if (types.contains('locality')) {
          _cityController.text = component['long_name'];
        } else if (types.contains('postal_code')) {
          _postalCodeController.text = component['long_name'];
        }
      }
    } else {
      print("Details Fehler: ${response.body}");
    }
  }

  void _onSuggestionTap(String description, String placeId) async {
    setState(() {
      _streetController.text = description;
      _suggestions = [];
    });

    await _getAddressDetails(placeId);
  }

  void showEmailSharePopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true, // falls Keyboard den Inhalt schiebt
      builder: (BuildContext context) {
        // FokusNodes & Controller für 6 Felder anlegen
        final int codeLength = 6;
        List<FocusNode> focusNodes =
            List.generate(codeLength, (_) => FocusNode());
        List<TextEditingController> controllers =
            List.generate(codeLength, (_) => TextEditingController());

        void onChanged(String value, int index) {
          if (value.length == 1 && index < codeLength - 1) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(focusNodes[index - 1]);
          }
        }

        String getEnteredCode() {
          return controllers.map((c) => c.text).join();
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Verifizierungscode Eingeben",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  Text(
                      "Bitte geben Sie den Code ein, den wir an Ihre Email ${_emailController.text} gesendet haben."),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(codeLength, (index) {
                      return SizedBox(
                        width: 40,
                        child: TextFormField(
                          autofocus: index == 0,
                          controller: controllers[index],
                          focusNode: focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            counterText: '',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          onChanged: (value) {
                            onChanged(value, index);
                            setState(() {}); // falls du UI Updates brauchst
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            icolor.blue)), // bleib bei deinem style
                    onPressed: () async {
                      final code = getEnteredCode();
                      if (code.length < codeLength ||
                          code.contains(RegExp(r'[^0-9]'))) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Bitte geben Sie den vollständigen 6-stelligen Code ein.')),
                        );
                        return;
                      }

                      ServerHandler server =
                          ServerHandler(Request: '/register', sendData: {
                        "name": _nameController.text,
                        "surname": _surnameController.text,
                        "email": _emailController.text,
                        "password": _pwdController.text,
                        "gender": _geschlechtamount,
                        "street": _streetController.text,
                        "city": _cityController.text,
                        "house_number": _houseNumberController.text,
                        "postal_code": _postalCodeController.text,
                        "code": code
                      });
                      String response = await server.RegisterUser();

                      if (response != 'error' && response != 'already_exist') {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setBool('registered', true);
                        prefs.setString("token", response);
                        prefs.setString("Email", _emailController.text);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MainScreen()),
                        );
                      } else {
                        _showErrorDialog(
                          response == 'already_exist'
                              ? "Die Email Adresse ist bereits vergeben!"
                              : "Es ist ein Fehler aufgetreten",
                        );
                      }

                      print('Eingegebener Code: $code');
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Absenden',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 120,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: icolor.blue.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: icolor.blue,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Registrierung',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Property Manager',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 360, right: 360),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 20),
            const Text(
              'Registrieren Sie einen Account',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 23,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 25),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Anrede',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: icolor.blue, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: icolor.blue, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon:
                          Icon(Icons.person_3_outlined, color: icolor.blue),
                    ),
                    value: _geschlechtamount,
                    onChanged: (value) =>
                        setState(() => _geschlechtamount = value!),
                    items: _geschlechterOption
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(_surnameController, 'Name', Icons.person),
                  const SizedBox(height: 12),
                  _buildTextField(
                      _nameController, 'Vorname', Icons.person_4_outlined),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _streetController,
                    onChanged: _searchPlace,
                    decoration: InputDecoration(
                      hintText: 'Adresse',
                      hintStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(
                        Icons.location_on,
                        color: icolor.blue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: icolor.blue,
                          width: 2.0, // <-- hier dicker gemacht
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: icolor.blue,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: icolor.blue,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  ..._suggestions.map((s) => ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: icolor.blue,
                        ),
                        title: Text(s['description']!),
                        onTap: () =>
                            _onSuggestionTap(s['description']!, s['place_id']!),
                      )),
                  const SizedBox(height: 12),
                  _buildTextField(_houseNumberController, 'Hausnummer',
                      Icons.confirmation_number,
                      isNumber: true),
                  const SizedBox(height: 12),
                  _buildTextField(_postalCodeController, 'Postleitzahl',
                      Icons.local_post_office_outlined,
                      isNumber: true),
                  const SizedBox(height: 12),
                  _buildTextField(
                      _cityController, 'Stadt', Icons.location_city),
                  const SizedBox(height: 12),
                  _buildTextField(
                      _emailController, 'Email-Adresse', Icons.mail),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _pwdController,
                    'Passwort',
                    Icons.lock,
                    obscureText: _isPwdObscured,
                    showToggle: true,
                    onToggleObscure: () {
                      setState(() => _isPwdObscured = !_isPwdObscured);
                    },
                    onChanged: (val) {
                      setState(() {
                        _passwordInput = val;
                        initialpwdinsert = true;
                      });
                    },
                  ),
                  initialpwdinsert
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildConditionRow(
                                'Mindestens 8 Zeichen',
                                _passwordInput.length >= 8,
                              ),
                              _buildConditionRow(
                                'Mindestens ein Großbuchstabe',
                                RegExp(r'[A-Z]').hasMatch(_passwordInput),
                              ),
                              _buildConditionRow(
                                'Mindestens ein Sonderzeichen',
                                RegExp(r'''[!@#\$&*~_+\-=\$\${}|\\:;"\'<>,.?/^]''')
                                    .hasMatch(_passwordInput),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _controlpwdController,
                    'Passwort wiederholen',
                    Icons.lock_clock,
                    obscureText: _isControlPwdObscured,
                    showToggle: true,
                    onToggleObscure: () {
                      setState(
                          () => _isControlPwdObscured = !_isControlPwdObscured);
                    },
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    checkColor: Colors.white,
                    activeColor: icolor.teal,
                    title: const Text(
                      'Ich stimme den Datenschutzbestimmungen zu.',
                      style: TextStyle(fontSize: 16),
                    ),
                    value: agreed,
                    onChanged: (value_) {
                      setState(() {
                        agreed = value_!;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    width: 245,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(icolor.blue),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (!agreed) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "Bitte stimmen Sie den Datenschutzbestimmungen zu.")),
                            );
                            return;
                          }

                          setState(() => isLoading = true);

                          ServerHandler server = ServerHandler(
                              Request: '/initializeregistration',
                              sendData: {"email": _emailController.text});
                          String response =
                              await server.InitializeRegistration();
                          if (response == 'success') {
                            showEmailSharePopup(context);
                          } else {
                            print('error');
                          }
                        }
                      },
                      child: isLoading
                          ? CircularProgressIndicator(color: icolor.teal)
                          : Text("Registrieren",
                              style:
                                  TextStyle(color: icolor.gray, fontSize: 15)),
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  SizedBox(
                    height: 40,
                    width: 245,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(icolor.blue),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LogIn()),
                        );
                      },
                      child: Text(
                        "Einloggen",
                        style: TextStyle(color: icolor.gray, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 60,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildConditionRow(String text, bool fulfilled) {
    return Row(
      children: [
        Icon(
          fulfilled ? Icons.check_circle : Icons.cancel,
          color: fulfilled ? Colors.green : Colors.red,
          size: 18,
        ),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: fulfilled ? Colors.green : Colors.red,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('Fehler'),
                ],
              ),
              content: Text(message),
            ));
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool isDecimal = false,
    bool obscureText = false,
    bool showToggle = false,
    VoidCallback? onToggleObscure,
    ValueChanged<String>? onChanged, // neu
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: isNumber
          ? TextInputType.number
          : isDecimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.digitsOnly]
          : isDecimal
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
              : [],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: Icon(icon, color: icolor.blue),
        suffixIcon: showToggle
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: icolor.blue, width: 2.0),
        ),
      ),
      validator: label == "Passwort"
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte Passwort eingeben';
              }
              if (value.length < 8) {
                return 'Passwort muss mindestens 8 Zeichen lang sein';
              }
              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                return 'Passwort muss mindestens einen Großbuchstaben enthalten';
              }
              if (!RegExp(r'''[!@#\$&*~_+\-=\$\${}|\\:;"\'<>,.?/^]''')
                  .hasMatch(value)) {
                return 'Passwort muss mindestens ein Sonderzeichen enthalten';
              }
              return null; // No errors, return null
            }
          : (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Bitte $label eingeben';
              }
              if (label == "Passwort wiederholen") {
                if (value != _passwordInput) {
                  return "Passwörter stimmen nicht überein";
                }
              }
              return null; // No errors, return null
            },
      onChanged: onChanged, // hier übergeben
    );
  }
}
