import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';

import 'products.dart';

class ShopList extends StatefulWidget {
  @override
  _ShopListState createState() => _ShopListState();
}

class _ShopListState extends State<ShopList> {
  ///Returns count of product stacks
  int get count {
    int count = ProductLists.shopList.length;
    if (count > 1) {
      for (int index = 1; index < ProductLists.shopList.length; index++) {
        if (ProductLists.shopList[index - 1].name ==
            ProductLists.shopList[index].name) {
          count--;
        }
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    ProductLists.sort();
    return Scaffold(
      body: Center(
        child: (ProductLists.shopList.isNotEmpty)
            ? Scrollbar(
                radius: Radius.circular(2),
                thickness: 4,
                child: ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: count,
                    itemBuilder: (context, index) {
                      int start = this.start(index), end = this.end(index);
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.horizontal,
                        dismissThresholds: const {
                          DismissDirection.startToEnd: 0.3,
                        },
                        onDismissed: (direction) {
                          setState(
                            () {
                              if (direction == DismissDirection.startToEnd) {
                                ProductLists.shopList.removeRange(start, end);
                              } else {
                                ProductLists.shopList
                                    .getRange(start, end)
                                    .forEach((element) =>
                                        element.checkState = false);
                                ProductLists.fromShopToFridge(start, end);
                              }
                            },
                          );
                        },
                        background: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 10, top: 10),
                              //alignment: Alignment.centerLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FluentIcons.delete_24_filled,
                                    color: Colors.red,
                                  ),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                    textScaleFactor: 0.8,
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 10, top: 10),
                              //alignment: Alignment.centerLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FluentIcons.xbox_console_24_filled,
                                    color: Colors.blue,
                                  ),
                                  Text(
                                    'To fridge',
                                    style: TextStyle(color: Colors.blue),
                                    textScaleFactor: 0.8,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        child: Product(
                          data: ProductLists.shopList.getRange(start, end),
                          inShopList: true,
                        ),
                      );
                    }),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                      width: 300,
                      image: AssetImage("assets/images/shop_list.png")),
                  Text(
                    'Your shop list is empty',
                    textScaleFactor: 1.5,
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(FluentIcons.add_24_filled),
        onPressed: () => setState(
          () {
            String productName = 'product';
            double productCount = 1;
            String productUnit = 'none';

            Picker countPicker = new Picker(

              textStyle: Theme.of(context).textTheme.subtitle1,
              backgroundColor: Colors.transparent,
              containerColor: Colors.transparent,
              height: 70,
              delimiter: [
                PickerDelimiter(
                    child: Container(
                  padding: EdgeInsets.only(top: 30),
                  child: Text('.'),
                ))
              ],
              adapter: NumberPickerAdapter(data: [
                NumberPickerColumn(begin: 0, end: 100),
                NumberPickerColumn(begin: 0, end: 9),
              ]),
              onSelect: (Picker picker, int i, List value) => productCount =
                  picker.getSelectedValues().first.ceilToDouble() +
                      picker.getSelectedValues().last.ceilToDouble() / 10,
              hideHeader: true,
            );

            Picker unitPicker = new Picker(
              textStyle: Theme.of(context).textTheme.subtitle1,
              backgroundColor: Colors.transparent,
              containerColor: Colors.transparent,
              height: 70,
              adapter: PickerDataAdapter(pickerdata: [
                'none',
                'milliliter',
                'pinch',
                'liter',
                'teaspoon',
                'tablespoon',
                'cup',
                'pint',
                'quart',
                'gallon',
              ]),
              onSelect: (Picker picker, _, __) =>
                  productUnit = picker.getSelectedValues().first,
              hideHeader: true,
            );

            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Add product'),
                  content: Container(
                    height: MediaQuery.of(context).size.height * 0.165,
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(hintText: 'product name'),
                          autofocus: true,
                          onChanged: (name) => productName = name,
                          onSubmitted: (name) => productName = name,
                          style: TextStyle(
                            height: 1.5,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: 15),
                              width: 80,
                              child: Column(
                                children: [
                                  Text('count'),
                                  countPicker.makePicker(),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 15),
                              width: 120,
                              child: Column(
                                children: [
                                  Text('unit'),
                                  unitPicker.makePicker(),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        ProductLists.shopList.add(ProductData(
                            name: productName,
                            count: productCount,
                            unit: productUnit));
                        Navigator.pop(context, true);
                        productName = 'product';
                        productCount = 1;
                        productUnit = 'none';
                      }),
                      child: Text('ADD'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      floatingActionButtonLocation: (FloatingActionButtonLocation.endFloat),
    );
  }

  ///Returns item at the end of current product stack
  int end(int index) {
    int start = this.start(index), end = start + 1;
    while (end < ProductLists.shopList.length &&
        ProductLists.shopList[start].name == ProductLists.shopList[end].name) {
      end++;
    }
    return end;
  }

  ///Returns item at the start of current product stack
  int start(int index) {
    int start;
    for (start = 0;
        start < ProductLists.shopList.length - 1 && index > 0;
        start++) {
      if (ProductLists.shopList[start].name !=
          ProductLists.shopList[start + 1].name) {
        index--;
      }
    }
    return start;
  }
}
