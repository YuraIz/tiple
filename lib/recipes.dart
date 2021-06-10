import 'dart:convert';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tiple/products.dart';

import 'menu.dart';

class Recipe {
  ///Recipe name
  String name;
  ///Recipe ingredients
  List<ProductData> ingredients;
  ///Recipe preparation
  String recipeText;

  Recipe(this.name, this.ingredients, this.recipeText);

  Recipe.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        recipeText = json['recipeText'].toString(),
        ingredients = <ProductData>[] {
    for (var ingredient in json['ingredients']) {
      ingredients.add(
        ProductData(
          name: ingredient['name'],
          count: double.parse(ingredient['count'].toString()),
          unit: ingredient['unit'],
          forRecipe: true,
        ),
      );
    }
  }
}

class RecipesList {
  ///List of recipes
  static List<Recipe> data = <Recipe>[];

  ///Returns names for each recipe
  static List<String> get names {
    List<String> names = [];
    data.forEach((element) => names.add(element.name));
    return names;
  }

  ///Get recipes from github
  static void addFromJson() async {
    http.Response response = await http.get(Uri.parse('https://git.io/JsSSu'));

    data.clear();
    var json = jsonDecode(response.body);
    for (int i = 0; i < json.length; i++) {
      data.add(Recipe.fromJson(json[i]));
      data[i].ingredients.sort((a, b) => a.name.compareTo(b.name));
    }
    data.sort((a, b) => a.name.compareTo(b.name));
  }
}

class RecipesPage extends StatefulWidget {
  @override
  _RecipesPageState createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  ///Index of selected recipe
  int _currentIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (RecipesList.data.isEmpty) {
      Future.delayed(Duration(milliseconds: 20), () => setState(() {}));
    }
    return Scaffold(
      body: (RecipesList.data.isNotEmpty)
          ? Theme(
              data: ThemeData(
                shadowColor: Colors.transparent,
                canvasColor: Colors.transparent,
              ),
              child: Stack(
                children: [
                  ListView(
                    padding: EdgeInsets.all(10),
                    children: [
                      for (var recipe in RecipesList.data)
                        GestureDetector(
                          key: UniqueKey(),
                          onTap: () => setState(() =>
                              _currentIndex = RecipesList.data.indexOf(recipe)),
                          child: Container(
                            //height: 50,
                            color: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            //color: Colors.transparent,
                            child: Container(
                              //height: 50,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: 10, top: 13),
                                    child: Text(
                                      recipe.name,
                                      textScaleFactor: 1.4,
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        for (var ingredient
                                            in recipe.ingredients)
                                          Container(
                                            padding: EdgeInsets.all(10),
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
                                                ingredient.name,
                                                textScaleFactor: 1.2,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_currentIndex != -1)
                    SlidingUpPanel(
                      margin: EdgeInsets.all(10),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      maxHeight: MediaQuery.of(context).size.height * 0.75,
                      panelBuilder: (ScrollController sc) =>
                          SingleChildScrollView(
                        controller: sc,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 12),
                                  alignment: AlignmentDirectional.topStart,
                                  child: Text(
                                    RecipesList.data[_currentIndex].name,
                                    textScaleFactor: 1.4,
                                  ),
                                ),
                                MaterialButton(
                                  highlightColor: Colors.transparent,
                                  minWidth: 64,
                                  height: 64,
                                  child: (MenuRecipes.items.contains(
                                          RecipesList.data[_currentIndex]))
                                      ? Icon(
                                          FluentIcons.add_circle_32_filled,
                                          size: 32,
                                          color: Colors.green,
                                        )
                                      : Icon(
                                          FluentIcons.add_circle_32_regular,
                                          size: 32,
                                          color: Colors.black87,
                                        ),
                                  onPressed: () => (setState(() => {
                                        MenuRecipes.items.add(
                                          MenuItem(
                                              RecipesList.data[_currentIndex]),
                                        ),
                                      })),
                                )
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              alignment: AlignmentDirectional.topStart,
                              child: Text(
                                RecipesList.data[_currentIndex].recipeText,
                                textScaleFactor: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            )
          : Center(
              child: Text(
                'Please wait',
                textScaleFactor: 1.5,
              ),
            ),
    );
  }
}
