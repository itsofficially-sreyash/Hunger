import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:food_delivery_app/Core/models/product_model.dart';
import 'package:food_delivery_app/Core/utils/constants.dart';
import 'package:food_delivery_app/widgets/product_items_display.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewAllProductScreen extends StatefulWidget {
  const ViewAllProductScreen({super.key});

  @override
  State<ViewAllProductScreen> createState() => _ViewAllProductScreenState();
}

class _ViewAllProductScreenState extends State<ViewAllProductScreen> {
  final supabase = Supabase.instance.client;
  List<FoodModel> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFoodProducts();
  }

  Future<void> fetchFoodProducts() async {
    try {
      final response = await supabase.from("food_product").select();
      final data = response as List;

      setState(() {
        products = data.map((json) => FoodModel.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      print("error fetching products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("All Products"),
        backgroundColor: Colors.blue[50],
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: isLoading
          ? LoadingAnimationWidget.inkDrop(color: red, size: 30)
          : GridView.builder(
            itemCount: products.length,
            padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.59,
                crossAxisSpacing: 8
              ),
              itemBuilder: (context, index) {
                return ProductItemsDisplay(foodModel: products[index]);
              },
            ),
    );
  }
}
