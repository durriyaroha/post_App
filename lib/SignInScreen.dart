import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:post_app/Classes/user_model.dart';
import 'package:post_app/auth_sevices.dart';
import 'package:post_app/SignUpScreen.dart';
import 'package:post_app/home_screen.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('User');

  void _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        await _databaseRef.child(user.uid).once().then((value) {
          Provider.of<UserDetail>(context, listen: false)
              .setUserDetail(value.snapshot);
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _showErrorSnackbar('Sign-in failed. Please try again.');
      }
    } catch (e) {
      _showErrorSnackbar('Sign-in failed: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Image.asset(
              'asset/logo.png', // Ensure this is your logo
              height: 250,
            ),
            const SizedBox(height: 10),
            const Text(
              'Welcome Back!',
              style: TextStyle(
                color: Color(0xFF9E1B1E),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Sign in to continue',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField(_emailController, 'Email or Username', Icons.person),
            const SizedBox(height: 20),
            _buildPasswordTextField(_passwordController, 'Password', _isPasswordVisible, (val) {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            }),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9E1B1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 5,
                ),
                onPressed: _isLoading ? null : _signIn,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.black54),
                    ),
                    TextSpan(
                      text: "Sign up",
                      style: TextStyle(
                          color: Color(0xFF9E1B1E), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF9E1B1E).withOpacity(0.1),
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9E1B1E)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF9E1B1E)),
        contentPadding: const EdgeInsets.all(16.0),
      ),
      style: const TextStyle(color: Color(0xFF9E1B1E)),
    );
  }

  Widget _buildPasswordTextField(TextEditingController controller, String hintText, bool isVisible, Function onTap) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF9E1B1E).withOpacity(0.1),
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9E1B1E)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF9E1B1E)),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF9E1B1E),
          ),
          onPressed: () => onTap(isVisible),
        ),
        contentPadding: const EdgeInsets.all(16.0),
      ),
      obscureText: !isVisible,
      style: const TextStyle(color: Color(0xFF9E1B1E)),
    );
  }
}
