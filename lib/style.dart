import 'package:flutter/material.dart';

// * FONTSIZES
const LargeTextSize = 24.0;
const MediumTextSize = 18.0;
const SmallTextSize = 14.0;

// * Generic COLORS

// * LIGHT THEME

const LightPrimaryColor = Color(0xffde6b48);

final appLightTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  disabledColor: Colors.grey,
  colorScheme: ColorScheme(
    primary: LightPrimaryColor, 
    primaryVariant: Color(0xffac4020), 
    secondary: Color(0xff7dbbc3), 
    secondaryVariant: Color(0xff40838c), 
    surface: Colors.white, 
    background: Colors.white, 
    error: Color(0xffb00020), 
    onPrimary: Colors.white, 
    onSecondary: Colors.black, 
    onSurface: Colors.black, 
    onBackground: Colors.black, 
    onError: Colors.white, 
    brightness: Brightness.light
  ),
    appBarTheme: AppBarTheme(
    color: LightPrimaryColor,
  ),
  primaryTextTheme: TextTheme(
    headline6: TextStyle(fontSize: 20,),//Appbar
  ),
);

// * DARK THEME

const DarkPrimaryColor = Color(0xff525252);
const DarkSurfaceColor = Color(0xff383838);

final appDarkTheme = ThemeData(
  scaffoldBackgroundColor: DarkSurfaceColor,
  disabledColor: Colors.grey,
  colorScheme: ColorScheme(
    primary: DarkPrimaryColor, 
    primaryVariant: Color(0xffac4020), 
    secondary: Color(0xff7dbbc3), 
    secondaryVariant: Color(0xff40838c), 
    surface: DarkSurfaceColor, 
    background: Colors.white, 
    error: Color(0xffb00020), 
    onPrimary: Colors.white, 
    onSecondary: Colors.black, 
    onSurface: Colors.black, 
    onBackground: Colors.black, 
    onError: Colors.white, 
    brightness: Brightness.dark
  ),
    appBarTheme: AppBarTheme(
    color: LightPrimaryColor,
  ),
);
