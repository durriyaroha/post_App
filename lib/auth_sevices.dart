import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // Sign up with email and password
  Future<User?> signUp(String fullname, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      // Save user details to the database
      await _databaseRef.child('User').child(user!.uid).set({
        'UserId': user.uid,
        'Picture': '',
        'Fullname': fullname,
        'Email': email,
        'Password': password,
      });

      return user;
    } on FirebaseAuthException catch (e) {
      print('Sign Up Error: ${e.message}');
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Sign In Error: ${e.message}');
      return null;
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign Out Error: ${e.toString()}');
    }
  }

  // Create a new post
  Future<void> createPost({
    required String userId,
    required String description,
    required String imageUrl,
    required String postType,
    required int status,
  }) async {
    try {
      final postId = _databaseRef.child('Posts').push().key; // Generate a new unique post ID
      final postRef = _databaseRef.child('Posts').child(postId!);

      await postRef.set({
        'PostId': postId,
        'UserId': userId,
        'Description': description,
        'Image': imageUrl,
        'PostType': postType,
        'Status': status,
        'CreatedAt': DateTime.now().toIso8601String(),
      });

      print('Post created successfully with Post ID: $postId');
    } catch (e) {
      print('Create Post Error: ${e.toString()}');
    }
  }
}




