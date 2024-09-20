import 'package:clinic_users/features/auth/data/auth_service.dart';
import 'package:clinic_users/features/auth/pages/signup_page.dart';
import 'package:clinic_users/features/auth/pages/status_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isObscured = true;

  // register method
  void login() async {
    // show loading
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    await AuthService.login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim())
        .then((value) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return const StatusPage();
      }));
      // displayMessageToUser(value, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(left: 30, right: 30),
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 200),
                // Image.asset('assets/login.png'),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(fontFamily: 'Montserrat'),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(192, 192, 192, 1),
                        width: 3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.05),
                TextFormField(
                  controller: _passwordController,
                  obscureText: isObscured,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(fontFamily: 'Montserrat'),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isObscured = !isObscured;
                        });
                      },
                      icon: Align(
                        widthFactor: 1.0,
                        heightFactor: 1.0,
                        child: isObscured
                            ? Icon(Icons.remove_red_eye)
                            : Icon(Icons.visibility_off),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromRGBO(192, 192, 192, 1), width: 3),
                    ),
                  ),
                ),
                const SizedBox(height: 16.05),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontFamily: 'Montserrat'),
                      )),
                ]),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      login();
                    }
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(
                        const Size(354.0, 52.0)),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 47),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(
                      'assets/Vector 1.png',
                      width: 108,
                    ),
                    const Text(
                      "Or Continue With",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromRGBO(192, 192, 192, 1),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    Image.asset(
                      'assets/Vector 1.png',
                      width: 108,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
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

                          //font style montserrat rakhna aaina
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.04),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(width: 3, color: Colors.blue),
                    minimumSize: const Size(354, 59.95),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      const Icon(FontAwesomeIcons.facebook),
                      const SizedBox(width: 101),
                      const Text(
                        "Facebook",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 33.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Dont have an acount?',
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SignupPage(),
                        ));
                      },
                      child: const Text(
                        'Signup',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
