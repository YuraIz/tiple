import 'dart:convert';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tiple/menu.dart';
import 'package:tiple/products.dart';

var recipesUri = Uri.parse(
    'https://raw.githubusercontent.com/YuraIz/testJsonRecipes/main/recipes.json');

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

  Map<String, dynamic> get toJson {
    Map<String, dynamic> json = Map<String, dynamic>();
    json['name'] = name;
    List<dynamic> jsonIngredients = [];
    ingredients.forEach((element) => jsonIngredients.add(element.toJson));
    json['ingredients'] = jsonIngredients;
    json['recipeText'] = recipeText;
    return json;
  }

  Widget page(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(FluentIcons.arrow_left_24_regular),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            name,
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  for (var ingredient in ingredients)
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ingredient.name,
                            textScaleFactor: 1.5,
                          ),
                          if (ingredient.count != 1 ||
                              ingredient.unit != 'none')
                            Text(
                              ((ingredient.count == 1)
                                      ? ''
                                      : ingredient.count.toString()) +
                                  ((ingredient.unit == 'none')
                                      ? ''
                                      : ' ' + (ingredient.unit)),
                              textScaleFactor: 1.2,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding:
                    EdgeInsets.only(top: 10, bottom: 70, left: 10, right: 10),
                child: Text(
                  '    ' + recipeText,
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
            )
          ],
        ),
        bottomNavigationBar: Stack(
          children: [
            TabBar(
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.transparent,
              labelColor: Colors.transparent,
              tabs: [
                Tab(icon: Icon(FluentIcons.text_bullet_list_ltr_24_regular)),
                Tab(icon: Icon(FluentIcons.text_first_line_24_regular)),
              ],
            ),
            TabBar(
              unselectedLabelColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              labelColor: Theme.of(context).accentColor,
              tabs: [
                Tab(icon: Icon(FluentIcons.text_bullet_list_ltr_24_filled)),
                Tab(icon: Icon(FluentIcons.text_first_line_24_filled)),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(FluentIcons.food_24_filled),
          onPressed: () => MenuItems.add(this),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
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

  ///Get recipes from github or local data
  static void addFromJson() async {
    File localRecipes = File(Directory.systemTemp.path + 'local_recipes.json');
    dynamic json;

    if (localRecipes.existsSync()) {
      json = jsonDecode(localRecipes.readAsStringSync());
    } else {
      http.Response response = await http.get(recipesUri);
      json = jsonDecode(response.body);
      localRecipes.create();
      localRecipes.writeAsString(response.body);
    }

    localRecipes.lastModified().then((value) {
      if (DateTime.now().difference(value).inDays > 10) {
        http
            .get(recipesUri)
            .then((response) => localRecipes.writeAsString(response.body));
      }
    });

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
                    padding: EdgeInsets.symmetric(vertical: 10),
                    children: [
                      for (var recipe in RecipesList.data)
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 5,
                                    offset: Offset(0, 2))
                              ],
                            ),
                            child: OpenContainer(
                              closedColor: Theme.of(context).cardColor,
                              closedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              openBuilder: (_, __) => recipe.page(context),
                              closedBuilder: (_, __) => Container(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 8, left: 10, right: 10),
                                child: Text(
                                  recipe.name,
                                  textScaleFactor: 1.4,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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
