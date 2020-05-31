import 'package:ctrim_app_v1/screens/HomePage.dart';
import 'package:flutter/material.dart';

const HomeRoute ='/';
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: _routes(),
    );
  }

  RouteFactory _routes(){
    return (settings){
      final Map<String, dynamic> arguments = settings.arguments;

      Widget screen;

      switch (settings.name){
        case HomeRoute: screen = HomePage();
      }
      return MaterialPageRoute(builder: (context) => screen);
    };
  }
}