import 'dart:ffi' hide Size;

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/Core/Provider/cart_provider.dart';
import 'package:food_delivery_app/Core/models/product_model.dart';
import 'package:food_delivery_app/Core/utils/constants.dart';
import 'package:readmore/readmore.dart';

class FoodDetailsScreen extends ConsumerStatefulWidget {
  final FoodModel product;
  const FoodDetailsScreen({super.key, required this.product});

  @override
  ConsumerState<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends ConsumerState<FoodDetailsScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: appBarParts(context),
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Container(
            width: size.width,
            height: size.height,
            color: imageBackground,
            child: Image.asset(
              "assets/food-delivery/food pattern.png",
              repeat: ImageRepeat.repeatY,
              color: imageBackground2,
            ),
          ),
          Container(
            width: size.width,
            height: size.height * 0.75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
          ),
          Container(
            width: size.width,
            height: size.height,
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 90),
                  Center(
                    child: Hero(
                      tag: widget.product.imageDetail,
                      child: Image.network(
                        widget.product.imageDetail,
                        height: 320,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: Container(
                      width: 120,
                      height: 45,
                      decoration: BoxDecoration(
                        color: red,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() {
                                quantity = quantity > 1 ? quantity - 1 : 1;
                              }),
                              child: Icon(Icons.remove, color: Colors.white),
                            ),
                            SizedBox(width: 15),
                            Text(
                              quantity.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(width: 15),
                            GestureDetector(
                              onTap: () => setState(() {
                                quantity++;
                              }),
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.product.specialItems,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: "\$",
                              style: TextStyle(color: red, fontSize: 14),
                            ),
                            TextSpan(
                              text: "${widget.product.price}",
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      foodInfo(
                        "assets/food-delivery/icon/star.png",
                        widget.product.rate.toString(),
                      ),
                      foodInfo(
                        "assets/food-delivery/icon/fire.png",
                        "${widget.product.kcal.toString()} Kcal",
                      ),
                      foodInfo(
                        "assets/food-delivery/icon/time.png",
                        "${widget.product.time.toString()} Min",
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  ReadMoreText(
                    desc,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      height: 1.5,
                      color: Colors.black,
                    ),
                    trimLength: 110,
                    trimCollapsedText: "Read More",
                    trimExpandedText: "Read Less",
                    colorClickableText: red,
                    moreStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: red,
                    ),
                    lessStyle: TextStyle(
                      color: red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        elevation: 0,
        backgroundColor: Colors.transparent,
        label: MaterialButton(
          onPressed: () async {
            await ref
                .read(cartProvider)
                .addCart(widget.product.name, widget.product.toMap(), quantity);
            final snackBar = SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            content: AwesomeSnackbarContent(
              title: "Success",
              message: "Item added sucessfully",
              contentType: ContentType.success,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          height: 65,
          color: red,
          minWidth: 350,
          child: Text(
            "Add to Cart",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  Row foodInfo(image, value) {
    return Row(
      children: [
        Image.asset(image, width: 25),
        SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ],
    );
  }

  AppBar appBarParts(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leadingWidth: 80,
      forceMaterialTransparency: true,
      actions: [
        SizedBox(width: 27),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: 40,
            width: 40,
            padding: EdgeInsets.all(7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 18,
            ),
          ),
        ),
        Spacer(),
        Container(
          height: 40,
          width: 40,
          padding: EdgeInsets.all(7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Icon(Icons.more_horiz_rounded, size: 18, color: Colors.black),
        ),
        SizedBox(width: 27),
      ],
    );
  }
}
