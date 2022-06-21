import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Palette {
  static const Color orange = Color(0xFFFAAD80);
  static const Color rose = Color(0xFFFF6767);
  static const Color red = Color(0xFFFF3D68);
  static const Color purple = Color(0xFFA73489);
  static const Color blue = Color(0xFF7C83FD);
  static const Color lightBlue = Color(0xFF96BAFF);
  static const Color skyBlue = Color(0xFF7DEDFF);
  static const Color aqua = Color(0xFF88FFF7);

  static const Color white = Color(0xFFFFFFFF);

  static const Color darkBackground = Color(0xFF202020);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkNavBar = Color(0xFF343434);

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          color: darkNavBar,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
          ),
        ),
        canvasColor: darkBackground,
        backgroundColor: darkBackground,
        cardColor: darkCard,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          showUnselectedLabels: false,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: darkNavBar,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: darkNavBar,
          foregroundColor: orange,
        ),
        accentColor: orange,
        focusColor: Color(0xFF315012),
        toggleableActiveColor: Color(0xFFA5E562),
      );

  static ThemeData get lightTheme => ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.white,
          elevation: 3,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          showUnselectedLabels: false,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: white,
          selectedItemColor: rose,
          unselectedItemColor: Colors.black87,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: white,
          foregroundColor: rose,
          elevation: 3,
          highlightElevation: 6,
        ),
        canvasColor: white,
        primaryColor: white,
        shadowColor: Colors.black,
        focusColor: Color(0xFFE6FFD6),
        toggleableActiveColor: Colors.lightGreen,
      );
}
