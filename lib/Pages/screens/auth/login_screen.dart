import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/Pages/screens/Onboarding/onBoarding_screen.dart';
import 'package:food_delivery_app/Pages/screens/auth/login_screen.dart';
import 'package:food_delivery_app/Pages/screens/auth/signup_screen.dart';
import 'package:food_delivery_app/Pages/screens/home/profile_screen.dart';
import 'package:food_delivery_app/main.dart';
import 'package:food_delivery_app/service/auth_service.dart';
import 'package:food_delivery_app/widgets/custom_button.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  bool _obscureText = true;
  bool isLoading = false;

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return "Enter a valid email address (e.g., example@email.com)";
    }
  }

  String? _validatePassword(String? pass) {
    if (pass == null || pass.isEmpty) {
      return "Please enter your password";
    }
    if (pass.length < 6) {
      return "Password should be atlease 6 digits";
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate() ?? false) {
      try {
        setState(() {
          isLoading = true;
        });
        final result = await _authService.signIn(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        if (result == null) {
          setState(() {
            isLoading = false;
          });
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: "Success!",
              message: "Successfully signed in",
              contentType: ContentType.success,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => OnboardingScreen()),
          );
        } else {
          print(result);
          setState(() {
            isLoading = false;
          });
          final snackBar = SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            content: AwesomeSnackbarContent(
              title: "Failed!",
              message: "Signin failed: $result",
              contentType: ContentType.failure,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(
                  "assets/login.jpg",
                  width: double.infinity,
                  height: 500,
                  fit: BoxFit.cover,
                ),
                TextFormField(
                  controller: emailController,
                  validator: _validateEmail,
                  focusNode: _emailFocus,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscureText,
                  validator: _validatePassword,
                  focusNode: _passFocus,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: _obscureText
                          ? Icon(Icons.visibility)
                          : Icon(Icons.visibility_off),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: CustomButton(
                    onPressed: _handleSignIn,
                    child: isLoading
                        ? LoadingAnimationWidget.dotsTriangle(
                            color: Colors.white,
                            size: 30,
                          )
                        : Text(
                            "Sign In",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
                SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: Colors.black54),
                    children: [
                      TextSpan(
                        text: "Signup",
                        style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(),
                            ),
                          ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
