import 'package:animations/animations.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:tiple/products.dart';

import 'fridge.dart';
import 'menu.dart';
import 'palette.dart';
import 'recipes.dart';
import 'shop_list.dart';

void main() {
  RecipesList.addFromJson();
  ProductLists.loadState();
  MenuItems.loadState();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Palette.lightTheme,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  static const List<String> _names = <String>[
    'Recipes',
    'Week menu',
    'Fridge',
    'Shop list',
  ];

  static List<Widget> pages = <Widget>[
    RecipesPage(),
    Menu(),
    Fridge(),
    ShopList(),
  ];

  ///Get action button for AppBar
  Widget get action {
    var actions = [
      Container(),
      //Menu action
      DragTarget<Key>(
        builder: (context, candidates, rejected) {
          return IconButton(
            onPressed: () => setState(() {
              MenuItems.clear();
              pages[1] = Menu();
            }),
            icon: Icon(
              FluentIcons.delete_dismiss_24_regular,
            ),
          );
        },
        onAccept: (key) => setState(() {
          MenuItems.remove(key);
          pages[1] = Menu();
        }),
      ),
      //Fridge action
      IconButton(
        onPressed: () => setState(() {
          ProductLists.fridge.clear();
          pages[2] = Fridge();
        }),
        icon: Icon(
          FluentIcons.delete_dismiss_24_regular,
        ),
      ),
      //ShopList action
      IconButton(
        onPressed: () => setState(() {
          ProductLists.shopList.clear();
          pages[3] = ShopList();
        }),
        icon: Icon(
          FluentIcons.delete_dismiss_24_regular,
        ),
      ),
    ];
    return actions[pageIndex];
  }

  ///Index of selected item
  int pageIndex = 0;

  Text get title {
    return Text(_names[pageIndex] + ' page');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backwardsCompatibility: false,
          title: title,
          titleTextStyle: Theme.of(context).textTheme.headline5,
          actionsIconTheme: Theme.of(context).iconTheme,
          actions: <Widget>[action],
        ),
        body: PageTransitionSwitcher(
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
              FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          ),
          child: pages[pageIndex],
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
            currentIndex: pageIndex,
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
            onTap: (index) => setState(() => pageIndex = index),
          ),
        ),
      );
}
