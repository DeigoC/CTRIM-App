import 'package:flutter/material.dart';

// * FONTSIZES
const LargeTextSize = 24.0;
const MediumTextSize = 18.0;
const SmallTextSize = 14.0;

// * Generic COLORS

// * LIGHT THEME

const LightPrimaryColor = Color(0xffdb9423);
const LightSecondaryColor = Color(0xff236adb);
const LightDisabledColor = Colors.grey;
const LightSurfaceColor = Colors.white;

final appLightTheme = ThemeData(
  scaffoldBackgroundColor: LightSurfaceColor,
  bottomAppBarColor: LightPrimaryColor,
  disabledColor: LightDisabledColor,
  toggleableActiveColor: LightPrimaryColor,
  
  toggleButtonsTheme: ToggleButtonsThemeData(
    selectedColor: LightPrimaryColor,
  ),
  
  chipTheme: ChipThemeData(
  backgroundColor: Color(0xffaf761c),
  brightness: Brightness.light,
  disabledColor: LightDisabledColor,
  selectedColor: LightSecondaryColor,
  secondaryLabelStyle: TextStyle(color: Colors.white),
  labelStyle: TextStyle(color: Colors.white),
  shape: StadiumBorder(),
  labelPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
  padding: EdgeInsets.all(4),
  secondarySelectedColor: LightSecondaryColor,
  ),

  brightness: Brightness.light,

  buttonTheme: ButtonThemeData(
    disabledColor: LightDisabledColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0)
    ),
    buttonColor: LightSecondaryColor,
    textTheme: ButtonTextTheme.primary
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: LightSecondaryColor
  ),

  colorScheme: ColorScheme(
    primary: LightPrimaryColor,
    primaryVariant: Color(0xffac4020), 
    secondary: LightSecondaryColor, 
    secondaryVariant: LightSecondaryColor,
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
  
);

// * DARK THEME

const DarkPrimaryColor = Color(0xff525252);
const DarkSurfaceColor = Color(0xff383838);

const normalDarkTextTheme = TextStyle(color: Colors.white);

final appDarkTheme = ThemeData(
  scaffoldBackgroundColor: DarkSurfaceColor,
  bottomAppBarColor: DarkPrimaryColor,
  disabledColor: Colors.grey,

  colorScheme: ColorScheme(
    primary: DarkPrimaryColor, 
    primaryVariant: Color(0xffac4020), 
    secondary: LightSecondaryColor, 
    secondaryVariant: LightSecondaryColor, 
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

  brightness: Brightness.dark,

  appBarTheme: AppBarTheme(color: DarkPrimaryColor,brightness: Brightness.dark),
  textTheme: TextTheme(
    subtitle1: normalDarkTextTheme,
    subtitle2: normalDarkTextTheme,
    bodyText1: normalDarkTextTheme,
    bodyText2: normalDarkTextTheme,
    headline1:  normalDarkTextTheme,
    headline2:  normalDarkTextTheme,
    headline3:  normalDarkTextTheme,
    headline4:  normalDarkTextTheme,
    headline5:  normalDarkTextTheme,
    headline6:  normalDarkTextTheme,
  ),

  
  
);
