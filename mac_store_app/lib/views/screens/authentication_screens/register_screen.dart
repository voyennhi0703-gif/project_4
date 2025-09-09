import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app/global_variables.dart';
import 'package:mac_store_app/views/screens/authentication_screens/login_screens.dart';
import 'package:mac_store_app/controller/auth_controller.dart'; // ví dụ
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();

}
  class _RegisterScreenState extends State<RegisterScreen>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController authController = AuthController();
  late String email;
  late String fullName;
  late String password;
  bool isLoading = false;
  registerUser() async {
    setState((){
      isLoading = true;
    });
    await authController.signUpUsers(
        context: context,      
        email: email, 
        fullName: fullName, 
        password: password,
        uri: uri, 
        ).whenComplete((){
          setState((){
            isLoading = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Create Your Account",
                    style: GoogleFonts.getFont(
                      'Lato',
                      color: Color.fromARGB(255, 5, 19, 8),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                      fontSize: 23,
                    ),
                  ),
                  Text(
                    'To Explore the world exclusives',
                    style: GoogleFonts.getFont(
                      'Lato',
                      color: Color.fromARGB(255, 5, 19, 8),
                      fontSize: 14,
                      letterSpacing: 0.2,
                    ),
                  ),

                  Image.asset(
                    'assets/images/Illustration.png',
                    width: 200,
                    height: 200,
                  ),

                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Email',
                      style: GoogleFonts.getFont(
                        'Nunito Sans',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  TextFormField(
                    onChanged:(value) {
                      email = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "enter your email";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),

                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      labelText: 'enter your email',
                      labelStyle: GoogleFonts.getFont(
                        "Nunito Sans",
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),

                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/icons/email.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Full Name',
                      style: GoogleFonts.getFont(
                        'Nunito Sans',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  TextFormField(
                    onChanged:(value) {
                      fullName = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "enter your full name";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),

                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      labelText: 'enter your full name',
                      labelStyle: GoogleFonts.getFont(
                        "Nunito Sans",
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),

                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/icons/user.jpeg',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  TextFormField(
                    onChanged:(value) {
                      password = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "enter your password";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),

                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      labelText: 'enter your password',
                      labelStyle: GoogleFonts.getFont(
                        "Nunito Sans",
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/icons/password.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      suffixIcon: Icon(Icons.visibility),
                    ),
                  ),

                  SizedBox(height: 20),
                  InkWell(
                    onTap: ()async {
                      if (_formKey.currentState!.validate()) {
                        registerUser();
                      }
                    },
                    child: Container(
                      width: 319,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 87, 10, 210),
                            Color.fromARGB(204, 88, 29, 215),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 278,
                            top: 19,
                            child: Opacity(
                              opacity: 0.5,
                              child: Container(
                                width: 60,
                                height: 60,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 12,
                                    color: Color(0xFF103DE5),
                                  ),

                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 260,
                            top: 29,
                            child: Opacity(
                              opacity: 0.5,
                              child: Container(
                                width: 10,
                                height: 10,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  border: Border.all(width: 3),
                                  color: Color.fromARGB(255, 33, 65, 229),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 311,
                            child: Opacity(
                              opacity: 0.3,
                              child: Container(
                                width: 5,
                                height: 5,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 281,
                            top: -10,
                            child: Opacity(
                              opacity: 0.3,
                              child: Container(
                                width: 20,
                                height: 20,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),

                          Center(
                            child: isLoading? const CircularProgressIndicator(color: Colors.white,): Text(
                              'Sign up',
                              style: GoogleFonts.getFont(
                                'Lato',
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an Account?',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return LoginScreen();
                              },
                            ),
                          );
                        },
                        child: Text(
                          'Sign in',
                          style: GoogleFonts.roboto(
                            color: Color.fromARGB(255, 29, 68, 207),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
