import 'package:flutter/material.dart';
import 'package:flutter_app/Componnents/button.dart';
import 'package:flutter_app/Componnents/snakbar.dart';
import 'package:flutter_app/Componnents/textfild.dart';
import 'package:flutter_app/screens/homepage.dart';
import 'package:flutter_app/screens/login_page.dart';
import 'package:flutter_app/service/authentification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showSnackBar(context, "Please fill in all fields");
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text)) {
      showSnackBar(context, "Please enter a valid email address");
      return false;
    }

    if (passwordController.text.length < 6) {
      showSnackBar(context, "Password must be at least 6 characters long");
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showSnackBar(context, "Passwords do not match");
      return false;
    }

    return true;
  }

  Future<void> _saveUserDataToFirestore(String uid) async {
    await _firestore.collection("users").doc(uid).set({
      'name': nameController.text,
      'uid': uid,
      'email': emailController.text,
    });
  }

  void signupUser() async {
    if (!mounted) return;

    if (!_validateInputs()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String res = await AuthMethod().signupUser(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
      );

      if (res == "success") {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Vérifier si les données existent déjà dans Firestore
          DocumentSnapshot doc =
              await _firestore.collection("users").doc(user.uid).get();

          if (!doc.exists) {
            // Si les données n'existent pas, les sauvegarder manuellement
            await _saveUserDataToFirestore(user.uid);
          }

          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          showSnackBar(context, "Failed to get user data");
        }
      } else {
        showSnackBar(context, res);
      }
    } catch (e) {
      showSnackBar(context, "An error occurred: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.05),
                Icon(Icons.lock, size: size.height * 0.1),
                SizedBox(height: size.height * 0.03),
                Text(
                  "Create an Account",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                TextFieldInput(
                  icon: Icons.person,
                  textEditingController: nameController,
                  hintText: 'Enter your name',
                  textInputType: TextInputType.text,
                ),
                SizedBox(height: size.height * 0.02),
                TextFieldInput(
                  icon: Icons.email,
                  textEditingController: emailController,
                  hintText: 'Enter your email',
                  textInputType: TextInputType.emailAddress,
                ),
                SizedBox(height: size.height * 0.02),
                TextFieldInput(
                  icon: Icons.lock,
                  textEditingController: passwordController,
                  hintText: 'Enter your password',
                  textInputType: TextInputType.text,
                  isPass: true,
                ),
                SizedBox(height: size.height * 0.02),
                TextFieldInput(
                  icon: Icons.lock,
                  textEditingController: confirmPasswordController,
                  hintText: 'Confirm your password',
                  textInputType: TextInputType.text,
                  isPass: true,
                ),
                SizedBox(height: size.height * 0.03),
                MyButtons(
                  onTap: isLoading ? null : signupUser,
                  text: isLoading ? "Signing Up..." : "Sign Up",
                ),
                SizedBox(height: size.height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
