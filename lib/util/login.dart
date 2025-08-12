import 'package:dashboard_ui/const/immocolors.dart';
import 'package:dashboard_ui/screens/main_screen.dart';
import 'package:dashboard_ui/server/apiconnect.dart';
import 'package:dashboard_ui/util/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _pwdController = TextEditingController();

  bool _isPwdObscured = true;
  bool isLoading = false;
  void initializeEmail() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("Email");

    setState(() {
      _emailController.text = email!;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeEmail();
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
              'Einloggen',
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
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 40),
            const Text(
              'Loggen Sie sich ein',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 23,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),

            // Wrap fields in Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                      setState(() {
                        _isPwdObscured = !_isPwdObscured;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Column(
              children: [
                Container(
                  height: 40,
                  width: 200,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(icolor.blue),
                    ),
                    onPressed: () async {
                      // Check if form is valid before proceeding
                      if (_formKey.currentState!.validate()) {
                        setState(() => isLoading = true);

                        ServerHandler server = ServerHandler(
                            Request: '/login',
                            sendData: {
                              'email': _emailController.text,
                              'password': _pwdController.text
                            });
                        String response = await server.LoginUser();

                        if (response != 'error' && response != 'no_user') {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString("token", response);
                          prefs.setString("Email", _emailController.text);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainScreen()),
                          );
                        } else if (response == 'no_user') {
                          setState(() => isLoading = false);
                          _showErrorDialog("Nicht gefunden",
                              "Entweder Email Adresse oder Password ist falsch");
                        } else {
                          setState(() => isLoading = false);
                          _showErrorDialog(
                              "Fehler", "Es ist ein Fehler aufgetreten");
                        }
                      }
                    },
                    child: isLoading
                        ? CircularProgressIndicator(color: icolor.teal)
                        : Text(
                            "Einloggen",
                            style: TextStyle(color: icolor.gray, fontSize: 15),
                          ),
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Container(
                  height: 40,
                  width: 200,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(icolor.blue),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Register()),
                      );
                    },
                    child: Text(
                      "Registrieren",
                      style: TextStyle(color: icolor.gray, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    bool showToggle = false,
    VoidCallback? onToggleObscure,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
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
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Bitte $label eingeben';
        }
        return null;
      },
    );
  }
}
