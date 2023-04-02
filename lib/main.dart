import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/pages/auth/login_page.dart';
import 'package:chat_app/pages/auth/register_page.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/search_page.dart';
import 'package:chat_app/shared/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() async {
  // we have to wait for firebase to inialize in our app
  WidgetsFlutterBinding.ensureInitialized();
  // to check the current platform
  if (kIsWeb) {
    // run initialization for web
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: Constants.apiKey,
            appId: Constants.appId,
            messagingSenderId: Constants.messagingSenderId,
            projectId: Constants.projectId));
  } else {
    // run initialization for android and ios
    await Firebase.initializeApp();
  }
  // this will make it for web apps only so w have to import foundation library

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLoggedInStatus();
  }

  getUserLoggedInStatus() async {
    await HelperFunction.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          _isSignedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: Constants().backgroundcolor,
          primaryColor: Constants().primarcolor,
          primaryColorDark: Constants().secondarycolor),
      debugShowCheckedModeBanner: false,
      home: _isSignedIn ? HomePage() : LoginPage(),
      routes: {
        'register': (context) => RegisterPage(),
        'login': (context) => LoginPage(),
        'home': (context) => HomePage(),
        'search': (context) => SearchPage(),
      },
    );
  }
}
