import 'package:dinor_app/auth/login_view.dart';
import 'package:dinor_app/screens/home_screen.dart';
import 'package:flutter/material.dart';

const String loginViewRoute = 'login_view';

Route<dynamic> generateRoute(RouteSettings settings){
  switch(settings.name){
    case loginViewRoute:
      return MaterialPageRoute(builder: (_) => const LoginView());

    default:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
  }
}