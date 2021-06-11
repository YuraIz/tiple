import 'dart:convert';
import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class Product extends StatefulWidget {
  final Iterable<ProductData> data;
  final bool inShopList;

  Product({this.data, this.inShopList: true});

  @override
  _ProductState createState() => _ProductState();
}

class ProductData {
  ///Map of ratio for current volume unit
  static var ratio = {
    'milliliter': 1,
    'pinch': 0.3080576,
    'liter': 1000,
    'teaspoon': 4.92892159375,
    'tablespoon': 14.78676478125,
    'cup': 236.588237,
    'pint': 473.176473,
    'quart': 946.352946,
    'gallon': 3785.411784,
  };

  ///Product check state
  bool checkState = false;

  ///Product name
  String name;

  ///Count of units
  double count;

  ///Unit like a cup or teaspoon
  String unit;

  ///Other printing if true
  bool forRecipe;

  ///Standard constructor
  ProductData({
    this.name = 'Product',
    this.count = 1,
    this.unit = 'none',
    this.forRecipe = false,
  });

  ///Count converter
  double countTo({String to = 'milliliter'}) {
    if (to == unit) {
      return count;
    }
    if (!ratio.containsKey(to)) {
      return 0;
    }
    return count / ratio[to].toDouble() * ratio[unit].toDouble();
  }

  ///Convert to json
  Map<String, dynamic> get toJson {
    Map<String, dynamic> json = Map<String, dynamic>();
    json['checkState'] = checkState;
    json['name'] = name;
    json['count'] = count;
    json['unit'] = unit;
    json['forRecipe'] = forRecipe;
    return json;
  }

  ///Construct from json
  ProductData.fromJson(Map<String, dynamic> json) {
    checkState = json['checkState'];
    name = json['name'];
    count = json['count'];
    unit = json['unit'];
    forRecipe = json['forRecipe'];
  }
}

class ProductCreationData {
  static String productName = 'product';
  static double productCount = 1;
  static String productUnit = 'none';

  static void clear() {
    productName = 'product';
    productCount = 1;
    productUnit = 'none';
  }
}

class ProductLists {
  ///List for shop list page
  static List<ProductData> shopList = <ProductData>[];

  ///List for fridge page
  static List<ProductData> fridge = <ProductData>[];

  ///Converter for product stack
  static double convertCount(Iterable<ProductData> data,
      {String to = 'milliliter'}) {
    double count = 0;
    for (var item in data) {
      count += item.countTo(to: to);
    }
    return count;
  }

  ///Moving and sorting
  static void fromFridgeToShop(int start, int end) {
    shopList.addAll(fridge.getRange(start, end));
    fridge.removeRange(start, end);
    shopList.sort((a, b) => a.name.compareTo(b.name));
  }

  ///Moving and sorting
  static void fromShopToFridge(int start, int end) {
    fridge.addAll(shopList.getRange(start, end));
    shopList.removeRange(start, end);
    fridge.sort((a, b) => a.name.compareTo(b.name));
  }

  ///Sort all products
  static void sort() {
    shopList.sort((a, b) => a.name.compareTo(b.name));
    fridge.sort((a, b) => a.name.compareTo(b.name));
    saveState();
  }

  ///Convert to json
  static Map<String, dynamic> get toJson {
    Map<String, dynamic> json = Map<String, dynamic>();
    List<Map> shopListJson = [];
    shopList.forEach((element) => shopListJson.add(element.toJson));
    List<Map> fridgeJson = [];
    fridge.forEach((element) => fridgeJson.add(element.toJson));
    json['shopList'] = shopListJson;
    json['fridge'] = fridgeJson;
    return json;
  }

  ///Construct from json
  static void fromJson(Map<String, dynamic> json) {
    shopList.clear();
    fridge.clear();
    for (var data in json['shopList']) {
      shopList.add(ProductData.fromJson(data));
    }
    for (var data in json['fridge']) {
      fridge.add(ProductData.fromJson(data));
    }
  }

  ///Save state to app data
  static void saveState() async {
    File localLists = File(Directory.systemTemp.path + 'local_lists.json');
    localLists.create();
    localLists.writeAsString(jsonEncode(toJson));
  }

  ///Load state from app data
  static void loadState() async {
    File localLists = File(Directory.systemTemp.path + 'local_lists.json');
    fromJson(jsonDecode(localLists.readAsStringSync()));
  }
}

class _ProductState extends State<Product> {
  //Shadows
  int _currentShadow = 0;
  List<BoxShadow> _shadows = <BoxShadow>[
    BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
  ];

  Column get countText {
    double count;
    String unit;

    if (widget.data
            .every((element) => ProductData.ratio.containsKey(element.unit)) ||
        widget.data
            .every((element) => element.unit == widget.data.first.unit)) {
      unit = widget.data.first.unit;
    }

    if (widget.data
        .every((element) => ProductData.ratio.containsKey(element.unit))) {
      if (widget.data.length == 1) {
        count = widget.data.first.count;
      } else {
        widget.data.forEach((element) => (ProductData.ratio[element.unit] > ProductData.ratio[unit])?unit = element.unit: unit);
        count =
            ProductLists.convertCount(widget.data, to: unit);
      }
    } else if (widget.data
        .every((element) => element.unit == widget.data.first.unit)) {
      count = 0;
      widget.data.forEach((element) => count += element.count);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (count != null && count != 1) Text(count.toStringAsFixed(1)),
        if (unit != null && unit != 'none') Text(unit),
        if (count == null && unit == null) Text('hold 4 info'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (tapDownDetails) => setState(() => _currentShadow = 1),
      onTapCancel: () => setState(() => _currentShadow = 0),
      onTap: () => (widget.inShopList == true)
          ? setState(() {
              bool checkState = !widget.data.first.checkState;
              widget.data.forEach((element) => element.checkState = checkState);
              _currentShadow = 0;
            })
          : 0,
      onLongPress: () => setState(
        () => {
          Vibration.vibrate(duration: 15),
          _currentShadow = 0,
          showDialog<void>(
            barrierColor: Colors.black12,
            context: context,
            builder: (context) => SimpleDialog(
              contentPadding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              elevation: 0,
              children: [
                Container(
                  width: 1000,
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: TextField(
                      autofocus: true,
                      onEditingComplete: () => Navigator.pop(context, true),
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        fontSize: 25,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                if (widget.data.length > 1)
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var productData in widget.data)
                            Dismissible(
                              direction: DismissDirection.down,
                              key: UniqueKey(),
                              onDismissed: (direction) => setState(() => (widget
                                      .inShopList)
                                  ? ProductLists.shopList.remove(productData)
                                  : ProductLists.fridge.remove(productData)),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5,
                                          offset: Offset(0, 2))
                                    ],
                                  ),
                                  child: Text(
                                    productData.count.toString() +
                                        ((productData.unit != 'none')
                                            ? ' ' +
                                                productData.unit.toLowerCase()
                                            : ''),
                                    textScaleFactor: 1.2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        },
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            color: (widget.data.first.forRecipe == true)
                ? Color.fromARGB(255, 235, 255, 222)
                : Colors.white,
            boxShadow: [_shadows[_currentShadow]],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.inShopList == true)
                Padding(
                  padding: EdgeInsets.all(12),
                  child: (widget.data.first.checkState)
                      ? Icon(
                          FluentIcons.checkmark_circle_24_filled,
                          color: Colors.lightGreen,
                        )
                      : Icon(
                          FluentIcons.checkmark_circle_24_regular,
                          color: Colors.black87,
                        ),
                ),
              Container(
                width: MediaQuery.of(context).size.width *
                    ((widget.inShopList) ? 0.8 : 0.92),
                padding: EdgeInsets.only(
                    top: 10,
                    bottom: 8,
                    left: (widget.inShopList == false) ? 12 : 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        widget.data.first.name,
                        textScaleFactor: 1.5,
                        style: (widget.data.first.forRecipe == true)
                            ? TextStyle(color: Colors.black)
                            : TextStyle(color: Colors.black87),
                      ),
                    ),
                    countText,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
