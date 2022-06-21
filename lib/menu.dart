import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tiple/products.dart';

import 'recipes.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class MenuItems {
  static var _items = <List<RecipeContainer>>[
    for (int i = 0; i < 7; i++) <RecipeContainer>[],
  ];

  static List<dynamic> get toJson {
    var json = [];
    for (int day = 0; day < 7; day++) {
      var dayMap = {};
      var dayItems = [];
      _items[day].forEach((element) {
        dayItems.add(element.toJson);
      });
      dayMap['day'] = day;
      dayMap['items'] = jsonEncode(dayItems);
      json.add(jsonEncode(dayMap));
    }
    return json;
  }

  static void add(Recipe recipe) {
    _items[0].add(RecipeContainer(recipe));
    recipe.ingredients
        .forEach((ingredient) => ProductLists.shopList.add(ingredient));
  }

  static void clear() {
    MenuItems._items.forEach((element) => element.clear());
    saveState();
  }

  static void fromJson(List<dynamic> json) {
    for (var dayData in json) {
      var decoded = jsonDecode(dayData);
      int day = decoded['day'];
      for (var item in jsonDecode(decoded['items'])) {
        _items[day].add(RecipeContainer(Recipe.fromJson(item)));
      }
    }
  }

  static void loadState() async {
    File localMenu = File(Directory.systemTemp.path + 'local_menu.json');
    fromJson(jsonDecode(localMenu.readAsStringSync()));
  }

  static void move(Key key, int day, int index) {
    int oldDay;
    int oldIndex;

    oldDay = _items.indexWhere((element) =>
        (oldIndex = element.indexWhere((element) => element.key == key)) != -1);

    Widget element = _items[oldDay].removeAt(oldIndex);
    if (index == null) {
      _items[day].insert(0, element);
      return;
    } else if (oldDay != day && index != _items[day].length) {
      index++;
    } else if (oldDay == day) {
      if(oldIndex > index) {
        index++;
      } else if(index > _items[day].length) {
        index = _items[day].length;
      }
    }
    _items[day].insert(index, element);
    saveState();
  }

  static void remove(Key key) {
    _items.forEach((day) => day.removeWhere((recipe) => recipe.key == key));
    saveState();
  }

  static void saveState() async {
    File localMenu = File(Directory.systemTemp.path + 'local_menu.json');
    localMenu.create();
    localMenu.writeAsString(jsonEncode(toJson));
  }
}

class MenuColumn extends StatefulWidget {
  final int day;

  final double width;

  MenuColumn(this.day, {this.width});

  @override
  MenuColumnState createState() => MenuColumnState();
}

class MenuColumnState extends State<MenuColumn> with TickerProviderStateMixin {
  Duration duration = Duration(milliseconds: 150);

  double width;

  get dayName {
    switch (widget.day) {
      case 0:
        return 'Monday';
      case 1:
        return 'Tuesday';
      case 2:
        return 'Wednesday';
      case 3:
        return 'Thursday';
      case 4:
        return 'Friday';
      case 5:
        return 'Saturday';
      case 6:
        return 'Sunday';
    }
    return 'Other';
  }

  get items => MenuItems._items[widget.day];

  Widget build(BuildContext context) {
    if (widget.width == null) {
      width = MediaQuery.of(context).size.width;
    } else {
      width = widget.width;
    }

    return Column(
      children: [
        if (items.length > 0)
          Expanded(
            child: ListView(
              children: [
                DragTarget<Key>(
                  builder: (context, candidates, rejected) => Column(
                    children: [
                      Container(
                        width: width - 40,
                        child: Text(
                          dayName,
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      AnimatedSize(
                        vsync: this,
                        curve: Curves.easeOutQuint,
                        duration: duration,
                        child: Container(
                          height: (candidates.length > 0) ? 20 : 0,
                          color: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                  onAccept: (Key key) => setState(() => reorder(key, null)),
                ),
                for (int index = 0; index < items.length; index++)
                  Container(
                    width: width,
                    child: Listener(
                      onPointerMove: (PointerMoveEvent event) {
                        if (event.position.dx < 40) {
                          _MenuState.scrollController.animateTo(
                            _MenuState.scrollController.offset - 120,
                            duration: Duration(milliseconds: 100),
                            curve: Curves.linear,
                          );
                        } else if (event.position.dx > MediaQuery.of(context).size.width - 40) {
                          _MenuState.scrollController.animateTo(
                              _MenuState.scrollController.offset + 120,
                              duration: Duration(milliseconds: 100),
                              curve: Curves.linear,
                          );
                        }
                      },
                      child: LongPressDraggable<Key>(
                      data: items[index].key,
                      child: Column(children: [
                        Container(
                          width: width,
                          child: items[index],
                        ),
                        AnimatedSize(
                          vsync: this,
                          curve: Curves.easeOutQuint,
                          duration: duration,
                          child: DragTarget<Key>(
                            builder: (context, candidates, rejected) =>
                                Container(
                              height: (candidates.length > 0) ? 50 : 20,
                              color: Colors.transparent,
                            ),
                            onAccept: (Key key) =>
                                setState(() => reorder(key, index)),
                          ),
                        ),
                      ]),
                      feedback: Container(
                        width: width,
                        child: items[index],
                      ),
                      childWhenDragging: Container(),
                      onDragCompleted: () => setState(() {}),
                    ),
                    ),
                  ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: DragTarget<Key>(
                    builder: (context, candidates, rejected) => Container(
                      height: MediaQuery.of(context).size.height,
                      color: Colors.transparent,
                    ),
                    onAccept: (Key key) {
                      setState(() => reorder(key, items.length));
                    },
                  ),
                ),
              ],
            ),
          ),
        if (items.length == 0)
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: DragTarget<Key>(
              builder: (context, candidates, rejected) => Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.transparent,
                child: Container(
                  width: width - 40,
                  child: Text(
                    dayName,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              ),
              onAccept: (Key key) {
                setState(() => reorder(key, items.length));
              },
            ),
          ),
      ],
    );
  }

  reorder(Key key, int index) => MenuItems.move(key, widget.day, index);
}

class RecipeContainer extends StatelessWidget {
  final Recipe recipe;

  final Key key = UniqueKey();

  RecipeContainer(this.recipe);

  RecipeContainer.fromJson(dynamic json) : recipe = Recipe.fromJson(json);

  get toJson => recipe.toJson;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.only(top: 10, bottom: 8, left: 10, right: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2))
        ],
      ),
      child: Text(
        recipe.name,
        textScaleFactor: 1.4,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }
}

class _MenuState extends State<Menu> with TickerProviderStateMixin {
  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;

  double _screenWidth;

  get width {
    if (_scaleFactor > 3) {
      _scaleFactor = 3;
    } else if (_scaleFactor < 1) {
      _scaleFactor = 1;
    }
    return _screenWidth * 7 / _scaleFactor;
  }

  static ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: (MenuItems._items.isNotEmpty)
          ? GestureDetector(
              onScaleStart: (details) {
                _baseScaleFactor = _scaleFactor;
              },
              onScaleUpdate: (details) {
                setState(() {
                  _scaleFactor = _baseScaleFactor / details.scale;
                });
              },
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                child: Container(
                    width: width,
                    child: Row(
                      children: [
                        for (int day = 0; day < 7; day++)
                          Container(
                                width: width / 7,
                                child: MenuColumn(
                                  day,
                                  width: width / 7,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
            )
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
    );
  }
}
