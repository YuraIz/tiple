import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbar_manager/flutter_statusbar_manager.dart';

import 'fridge.dart';
import 'menu.dart';
import 'recipes.dart';
import 'shop_list.dart';

void main() {
  RecipesList.addFromJson();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarManager.setColor(Colors.transparent);
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.white,
          elevation: 3,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          showUnselectedLabels: false,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.black87,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red,
          elevation: 3,
          highlightElevation: 6,
        ),
        canvasColor: Colors.white,
        primaryColor: Colors.white,
        shadowColor: Colors.black,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const List<String> _names = <String>[
    'Recipes',
    'Week menu',
    'Fridge',
    'Shop list',
  ];

  static List<Widget> _homePages = <Widget>[
    RecipesPage(),
    Menu(),
    Fridge(),
    ShopList(),
  ];

  ///Index of selected item
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(_names.elementAt(_currentIndex) + ' page'),
        ),
        body: Center(
          child: _homePages.elementAt(_currentIndex),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            items: [
              BottomNavigationBarItem(
                icon: Icon(FluentIcons.book_24_regular),
                activeIcon: Icon(FluentIcons.book_24_filled),
                label: 'Recipes',
              ),
              BottomNavigationBarItem(
                icon: Icon(FluentIcons.food_24_regular),
                activeIcon: Icon(FluentIcons.food_24_filled),
                label: 'Menu',
              ),
              BottomNavigationBarItem(
                icon: Icon(FluentIcons.xbox_console_24_regular),
                activeIcon: Icon(FluentIcons.xbox_console_24_filled),
                label: 'Fridge',
              ),
              BottomNavigationBarItem(
                icon: Icon(FluentIcons.receipt_24_regular),
                activeIcon: Icon(FluentIcons.receipt_24_filled),
                label: 'Shop list',
              )
            ],
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        ),
      );
}
