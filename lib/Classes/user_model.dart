import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserDetail extends ChangeNotifier {
  String? userId;
  String? name;
  String? email;
  String? picture;

  UserDetail({this.userId, this.name, this.email, this.picture});

  // Method to set user details from a DataSnapshot
  void setUserDetail(DataSnapshot snapshot) {
    userId = snapshot.child("UserId").value.toString();
    name = snapshot.child("Fullname").value.toString();
    email = snapshot.child("Email").value.toString();
    picture = snapshot.child("Picture").value.toString();
    notifyListeners();
  }

  // Method to clear user details (useful when signing out)
  void clearUserDetail() {
    userId = null;
    name = null;
    email = null;
    picture = null;
    notifyListeners();
  }

  // Convenience method to check if user is logged in
  bool isLoggedIn() {
    return userId != null && email != null;
  }
}
