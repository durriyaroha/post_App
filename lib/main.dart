import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:post_app/Classes/user_model.dart';
import 'package:post_app/auth_sevices.dart';
import 'package:provider/provider.dart';
import 'SignInScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
       ChangeNotifierProvider<UserDetail>(create: (_) => UserDetail()),
        //ChangeNotifierProvider(create: (_) => AuthService()),

      ],
      child: MaterialApp(
        title: 'Authenticator App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        home: const SignInScreen(),
      ),
    );
  }
}
