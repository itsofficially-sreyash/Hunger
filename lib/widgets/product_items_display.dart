import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/Core/Provider/favourite_provider.dart';
import 'package:food_delivery_app/Core/models/product_model.dart';
import 'package:food_delivery_app/Core/utils/constants.dart';
import 'package:food_delivery_app/Pages/screens/food_details_screen.dart';

class ProductItemsDisplay extends ConsumerWidget {
  final FoodModel foodModel;
  const ProductItemsDisplay({super.key, required this.foodModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(favouriteProvider);
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(seconds: 1),
            pageBuilder: (_, _, __) => FoodDetailsScreen(product: foodModel),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 35,
            child: Container(
              height: 180,
              width: size.width * 0.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    spreadRadius: 10,
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                ref.read(favouriteProvider).toggleFavourite(foodModel.name);
              },
              child: CircleAvatar(
                radius: 15,
                backgroundColor: provider.isFavourite(foodModel.name)
                    ? Colors.red[100]
                    : Colors.transparent,
                child: provider.isFavourite(foodModel.name)
                    ? Image.asset("assets/food-delivery/icon/fire.png")
                    : Icon(Icons.local_fire_department, color: red),
              ),
            ),
          ),
          Container(
            width: size.width * 0.5,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: foodModel.imageDetail,
                  child: Image.network(
                    foodModel.imageCard,
                    height: 140,
                    width: 150,
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    foodModel.name,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  foodModel.specialItems,
                  style: TextStyle(
                    height: 0.1,
                    letterSpacing: 0.5,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 30),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: "\$",
                        style: TextStyle(fontSize: 14, color: red),
                      ),
                      TextSpan(
                        text: "${foodModel.price}",
                        style: TextStyle(fontSize: 25, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
