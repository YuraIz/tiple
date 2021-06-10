import 'dart:convert';
import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tiple/products.dart';

import 'recipes.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class MenuItem {
  ///Some of MenuItems can be week day
  bool isRecipe;

  ///Recipe data
  Recipe recipe = Recipe('no name', [], 'no text');

  ///Name of week day
  String dayName = 'no name';

  ///Constructor for recipe MenuItem
  MenuItem(this.recipe) {
    ingredients.forEach((ingredient) => ProductLists.shopList.add(ingredient));
    isRecipe = true;
  }

  ///Constructor for week day MenuItem
  MenuItem.day(this.dayName) {
    isRecipe = false;
  }

  ///Getter for recipe ingredients
  List<ProductData> get ingredients => recipe.ingredients;

  ///Getter for MenuItem name
  String get name => (isRecipe) ? recipe.name : dayName;

  ///Remove all ingredients from shopList
  void clearProductLists() => ingredients
      .forEach((ingredient) => ProductLists.shopList.remove(ingredient));

  ///Convert to json
  Map<String, dynamic> get toJson {
    Map<String, dynamic> json = Map<String, dynamic>();
    json['isRecipe'] = isRecipe;
    json['recipe'] = recipe.toJson;
    json['dayName'] = dayName;
    return json;
  }

  ///Construct from json
  MenuItem.fromJson(Map<String, dynamic> json) {
    isRecipe = json['isRecipe'];
    recipe = Recipe.fromJson(json['recipe']);
    dayName = json['dayName'];
  }
}

class MenuRecipes {
  ///List of MenuItems
  static var _items = <MenuItem>[
    MenuItem.day('Monday'),
    MenuItem.day('Tuesday'),
    MenuItem.day('Wednesday'),
    MenuItem.day('Thursday'),
    MenuItem.day('Friday'),
    MenuItem.day('Saturday'),
    MenuItem.day('Sunday'),
    MenuItem.day('Other'),
  ];

  static bool contains(Object element) => _items.contains(element);

  static int get length => _items.length;

  static void add(MenuItem item) {
    _items.add(item);
    saveState();
  }

  static void remove(MenuItem item) {
    _items.remove(item);
    saveState();
  }

  ///Method for item reorder
  static void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final MenuItem item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);
    saveState();
  }

  ///Convert to json
  static List<dynamic> get toJson{
    List<dynamic> json = [];
    _items.forEach((element) => json.add(element.toJson));
    return json;
  }

  ///Construct from json
  static void fromJson(List<dynamic> json) {
    _items.clear();
    for(var data in json) {
      _items.add(MenuItem.fromJson(data));
    }
  }

  ///Save state to app data
  static void saveState() async {
    File localMenu = File(Directory.systemTemp.path + 'local_menu.json');
    localMenu.create();
    localMenu.writeAsString(jsonEncode(toJson));
  }

  ///Load state from app data
  static void loadState() async {
    File localMenu = File(Directory.systemTemp.path + 'local_menu.json');
    fromJson(jsonDecode(localMenu.readAsStringSync()));
  }
}

class _MenuState extends State<Menu> {
  static String _lastTitle = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (MenuRecipes.length > 8)
          ? Theme(
              data: ThemeData(
                shadowColor: Colors.transparent,
                canvasColor: Colors.transparent,
              ),
              child: ReorderableListView(
                //buildDefaultDragHandles: false,
                padding: EdgeInsets.all(10),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    MenuRecipes.reorder(oldIndex, newIndex);
                  });
                },
                children: [
                  for (var item in MenuRecipes._items)
                    (item.isRecipe)
                        ? Dismissible(
                            key: UniqueKey(),
                            direction: DismissDirection.horizontal,
                            onDismissed: (_) => setState(() {
                              item.clearProductLists();
                              MenuRecipes.remove(item);
                            }),
                            child: GestureDetector(
                              onTap: () => setState(
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Scaffold(
                                      appBar: AppBar(
                                        title: Text(item.name),
                                      ),
                                      body: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: [
                                                  for (var ingredient
                                                      in item.ingredients)
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      10),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                  color: Colors
                                                                      .black26,
                                                                  blurRadius: 5,
                                                                  offset:
                                                                      Offset(
                                                                          0, 2))
                                                            ],
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                ingredient.name,
                                                                textScaleFactor:
                                                                    1.5,
                                                              ),
                                                              if (ingredient
                                                                          .count !=
                                                                      1 ||
                                                                  ingredient
                                                                          .unit !=
                                                                      'none')
                                                                Text(
                                                                  ((ingredient.count ==
                                                                              1)
                                                                          ? ''
                                                                          : ingredient
                                                                              .count
                                                                              .toString()) +
                                                                      ((ingredient.unit ==
                                                                              'none')
                                                                          ? ''
                                                                          : ' ' +
                                                                              (ingredient.unit)),
                                                                  textScaleFactor:
                                                                      1.2,
                                                                ),
                                                            ],
                                                          )),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              child: Text(
                                                item.recipe.recipeText,
                                                textScaleFactor: 1.3,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              child: Container(
                                color: Colors.transparent,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  padding: EdgeInsets.only(
                                      top: 10, bottom: 8, left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5,
                                          offset: Offset(0, 2))
                                    ],
                                  ),
                                  child: Text(
                                    item.name,
                                    textScaleFactor: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : GestureDetector(
                            key: UniqueKey(),
                            onLongPress: () => 0,
                            child: Text(
                              item.dayName,
                              textScaleFactor: 1.2,
                            ),
                          )
                ],
              ))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: NetworkImage(
                        'https://img.icons8.com/fluent/244/000000/kawaii-broccoli.png'),
                  ),
                  Text(
                    'Your menu is empty',
                    textScaleFactor: 1.5,
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(FluentIcons.add_24_filled),
        onPressed: () => setState(
          () => {
            showDialog<void>(
              barrierDismissible: true,
              useSafeArea: false,
              barrierColor: Colors.black12,
              context: context,
              builder: (_) => SimpleDialog(
                contentPadding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                elevation: 0,
                children: [
                  Container(
                    width: 1000,
                    //height: 60,
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          autofocus: true,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                            fontSize: 25,
                            height: 1,
                          ),
                          onChanged: (value) => setState(() => {
                                _lastTitle = value,
                              }),
                          onEditingComplete: () => {
                            setState(() {
                              if (RecipesList.data.any(
                                  (element) => element.name == _lastTitle)) {
                                MenuRecipes.add(MenuItem(RecipesList.data
                                    .elementAt(RecipesList.data.indexWhere(
                                        (element) =>
                                            element.name == _lastTitle))));
                              } else {
                                MenuRecipes.add(
                                  MenuItem(
                                    Recipe(_lastTitle, [],
                                        'There is no such recipe in database, add ingredients to shop list by yourself'),
                                  ),
                                );
                              }
                              _lastTitle = '';
                            }),
                            Navigator.pop(context, true),
                          },
                          keyboardType: TextInputType.text,
                          enableSuggestions: true,
                          decoration: InputDecoration(),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var name in RecipesList.names)
                                Padding(
                                    padding: EdgeInsets.all(10),
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        _lastTitle = '';
                                        MenuRecipes.add(MenuItem(
                                            RecipesList.data.elementAt(
                                                RecipesList.data.indexWhere(
                                                    (element) =>
                                                        element.name ==
                                                        name))));
                                        Navigator.pop(context, true);
                                      }),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 5,
                                                offset: Offset(0, 2))
                                          ],
                                        ),
                                        child: Text(
                                          name,
                                          textScaleFactor: 1.2,
                                        ),
                                      ),
                                    )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          },
        ),
      ),
    );
  }
}
