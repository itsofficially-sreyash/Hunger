import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:food_delivery_app/Core/models/categories_model.dart';
import 'package:food_delivery_app/Core/models/product_model.dart';
import 'package:food_delivery_app/Core/utils/constants.dart';
import 'package:food_delivery_app/Pages/screens/view_all_screen.dart';
import 'package:food_delivery_app/service/auth_service.dart';
import 'package:food_delivery_app/widgets/product_items_display.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppHomeScreen extends StatefulWidget {
  const AppHomeScreen({super.key});

  @override
  State<AppHomeScreen> createState() => _AppHomeScreenState();
}

class _AppHomeScreenState extends State<AppHomeScreen> {
  final supabase = Supabase.instance.client;
  late Future<List<CategoryModel>> futureCategories = fetchCategories();
  late Future<List<FoodModel>> futureFoodProducts = Future.value([]);
  List<CategoryModel> categories = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    try {
      final categories = await fetchCategories();
      if (categories.isNotEmpty) {
        setState(() {
          this.categories = categories;
          selectedCategory = categories.first.name;
          //fetching food products
          futureFoodProducts = fetchFoodProducts(selectedCategory!);
        });
      }
    } catch (e) {
      print("Initialization error: $e");
    }
  }

  //to fetch product data from supabase
  Future<List<FoodModel>> fetchFoodProducts(String category) async {
    try {
      final response = await supabase
          .from("food_product")
          .select()
          .eq("category", category);

      return (response as List)
          .map((json) => FoodModel.fromJson(json))
          .toList();
    } catch (e) {
      print("Error fetching food products: $e");
      return [];
    }
  }

  //to fetch category data from supabase
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await supabase.from("category_items").select();

      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarParts(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                appBanner(),
                SizedBox(height: 25),
                Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          _buildCategoryList(),
          SizedBox(height: 30),
          viewAll(),
          SizedBox(height: 30),
          _buildProductSection(),
        ],
      ),
    );
  }

  Widget _buildProductSection() {
    return Expanded(
      child: FutureBuilder<List<FoodModel>>(
        future: futureFoodProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.discreteCircle(
                color: Colors.black,
                size: 30,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return Center(child: Text("No products found!"));
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsetsGeometry.only(
                  left: 25,
                  right: index == products.length - 1 ? 25 : 0,
                ),
                child: ProductItemsDisplay(foodModel: products[index]),
              );
            },
          );
        },
      ),
    );
  }

  Padding viewAll() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Popular Now",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ViewAllProductScreen()),
              );
            },
            child: Row(
              children: [
                Text("View All", style: TextStyle(color: orange)),
                SizedBox(width: 5),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: orange,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return FutureBuilder(
      future: futureCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.discreteCircle(
              color: Colors.yellow,
              size: 30,
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox.shrink();
        }
        return SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 15 : 0, right: 15),
                child: GestureDetector(
                  onTap: () => _handleCategoryTap(category.name),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: selectedCategory == category.name ? red : grey1,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: selectedCategory == category.name
                                ? Colors.white
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Image.network(
                            category.image,
                            width: 20,
                            height: 20,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.fastfood),
                          ),
                        ),
                        SizedBox(width: 15),
                        Text(
                          category.name,
                          style: TextStyle(
                            color: selectedCategory == category.name
                                ? Colors.white
                                : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _handleCategoryTap(String category) {
    if (selectedCategory == category) return;
    setState(() {
      selectedCategory = category;
      futureFoodProducts = fetchFoodProducts(category);
    });
  }

  Container appBanner() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: imageBackground,
      ),
      padding: EdgeInsets.only(top: 25, left: 25, right: 25),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: "The Fastest In Delivery ",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: "Food",
                        style: TextStyle(color: red),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: red,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                  child: Text(
                    "Order Now",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Image.asset("assets/food-delivery/courier.png"),
        ],
      ),
    );
  }

  AppBar appbarParts() {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      actions: [
        SizedBox(width: 25),
        Container(
          height: 45,
          width: 45,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: grey1,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset("assets/food-delivery/icon/dash.png"),
        ),
        Spacer(),
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 18, color: red),
            SizedBox(width: 5),
            Text(
              "Pune, Maharashtra",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 5),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: orange),
          ],
        ),
        Spacer(),
        Container(
          height: 45,
          width: 45,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: grey1,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset("assets/food-delivery/profile.png"),
        ),
        SizedBox(width: 25),
      ],
    );
  }
}
