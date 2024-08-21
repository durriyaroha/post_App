import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:post_app/auth_sevices.dart'; // Ensure this is the correct path

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  void _signUp() async {
    setState(() {
      _isLoading = true;
    });

   final String fullName = _fullNameController.text.trim();
    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty  || fullName.isEmpty|| email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showErrorSnackbar('Please fill in all fields.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      _showErrorSnackbar('Passwords do not match.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      User? user = await _authService.signUp(username, email, password);
      if (user != null && user.uid.isNotEmpty) {
        _showSuccessSnackbar('Sign up successful!');
        Navigator.pop(context); // Redirect to the sign-in screen
      } else {
        _showErrorSnackbar('Sign up failed.');
      }
    } catch (e) {
      _showErrorSnackbar('Sign up failed: $e');
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

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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
            const SizedBox(height: 20,),
            // Logo Section
            Image.asset(
              'asset/logo.png', // Ensure this is your uploaded logo
              height: 150, // Adjust size as needed
            ),
           // const SizedBox(height: 20),
            const Text(
              'Welcome!',
              style: TextStyle(
                color: Color(0xFF9E1B1E),  // Red color from the logo
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Sign up to continue',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField(_fullNameController, 'Full Name', Icons.person),
            const SizedBox(height: 20),
            _buildTextField(_usernameController, 'User Name', Icons.person_outline),
            const SizedBox(height: 20),
            _buildTextField(_emailController, 'Email', Icons.email),
            const SizedBox(height: 20),
            _buildPasswordTextField(_passwordController, 'Password', _isPasswordVisible, (val) {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            }),
            const SizedBox(height: 20),
            _buildPasswordTextField(_confirmPasswordController, 'Confirm Password', _isConfirmPasswordVisible, (val) {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            }),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9E1B1E),  // Red color from the logo
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 5, // Shadow effect
                ),
                onPressed: _isLoading ? null : _signUp,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back to the sign-in screen
              },
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: Colors.black54),
                    ),
                    TextSpan(
                      text: "Sign in",
                      style: TextStyle(color: Color(0xFF9E1B1E), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50), // Add space at the bottom
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
        fillColor: Color(0xFF9E1B1E).withOpacity(0.1),  // Red color background with opacity
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9E1B1E)),  // Red hint text color
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

  Widget _buildPasswordTextField(
      TextEditingController controller, String hintText, bool isVisible, Function onTap) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFF9E1B1E).withOpacity(0.1),
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
