import 'package:clinic_users/features/auth/data/auth_service.dart';
import 'package:clinic_users/features/auth/pages/login_page.dart';
import 'package:clinic_users/features/auth/pages/status_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final AuthService _authService = AuthService();

  Future<void> _register() async {
    await _authService.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _fullNameController.text.trim(),
      _addressController.text.trim(),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (constext) {
          return StatusPage();
        },
      ),
    );
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
          padding: const EdgeInsets.only(left: 30, right: 30),
          children: [
            Column(children: [
              // Padding(
              //   padding: const EdgeInsets.only(left: 32, top: 135),
              //   child: Image.asset(
              //     'assets/signup.png',
              //   ),
              // ),
              const SizedBox(height: 64),
              TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                    hintText: "Full Name",
                    hintStyle: TextStyle(fontFamily: "Montserrat"),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(192, 192, 192, 1),
                          width: 3,
                        ))),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                    hintText: "Email",
                    hintStyle: TextStyle(fontFamily: "Montserrat"),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(192, 192, 192, 1),
                          width: 3,
                        ))),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                    hintText: "Address",
                    hintStyle: TextStyle(fontFamily: "Montserrat"),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(192, 192, 192, 1),
                          width: 3,
                        ))),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(fontFamily: "Montserrat"),
                    suffixIcon: Icon(
                      FontAwesomeIcons.eye,
                      size: 16,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(192, 192, 192, 1),
                          width: 3,
                        ))),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                    hintText: "Confirm Password",
                    hintStyle: TextStyle(fontFamily: "Montserrat"),
                    suffixIcon: Icon(
                      FontAwesomeIcons.eyeSlash,
                      color: Colors.black45,
                      size: 16,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(192, 192, 192, 1),
                          width: 3,
                        ))),
              ),
              const SizedBox(height: 41),
              ElevatedButton(
                onPressed: _register,
                style: ButtonStyle(
                  minimumSize:
                      MaterialStateProperty.all<Size>(const Size(354.0, 52.0)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(color: Colors.white, fontFamily: "Mendftar"),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/Vector 1.png', width: 108),
                  const Text(
                    "Or Continue With",
                    style: TextStyle(
                        fontSize: 15,
                        color: Color.fromRGBO(192, 192, 192, 1),
                        fontFamily: 'Roboto'),
                  ),
                  Image.asset('assets/Vector 1.png', width: 108),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    side: const BorderSide(width: 3, color: Colors.red),
                    minimumSize: const Size(354, 59.95),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                child: const Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Icon(FontAwesomeIcons.google, color: Colors.red),
                    SizedBox(width: 101),
                    Text(
                      "Google",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    side: const BorderSide(width: 3, color: Colors.blue),
                    minimumSize: const Size(354, 59.95),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                child: const Row(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Icon(
                      FontAwesomeIcons.facebook,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 101),
                    Text(
                      "Facebook",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 15,

                        //font style montserrat rakhna aaina
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 49),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already registered?'),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LoginPage()));
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.blue),
                      ))
                ],
              )
            ]),
          ]),
    );
  }
}
