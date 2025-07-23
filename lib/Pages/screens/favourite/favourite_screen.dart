import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery_app/Core/Provider/favourite_provider.dart';
import 'package:food_delivery_app/Core/models/product_model.dart';
import 'package:food_delivery_app/Core/utils/constants.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class FavouriteScreen extends ConsumerStatefulWidget {
  const FavouriteScreen({super.key});

  @override
  ConsumerState<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends ConsumerState<FavouriteScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = supabase.auth.currentUser?.id;
    final provider = ref.watch(favouriteProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Favourites",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: userId == null
          ? Center(child: Text("Please login to view favourites"))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from("favourites")
                  .stream(primaryKey: ["id"])
                  .eq("user_id", userId!)
                  .map((data) => data.cast<Map<String, dynamic>>()),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: LoadingAnimationWidget.bouncingBall(
                      color: red,
                      size: 50,
                    ),
                  );
                }
                final favourites = snapshot.data!;
                if (favourites.isEmpty) {
                  return Center(child: Text("No favourites yet"));
                }
                return FutureBuilder(
                  future: _fetchFavouriteItems(favourites),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: LoadingAnimationWidget.newtonCradle(
                          color: red,
                          size: 50,
                        ),
                      );
                    }
                    final favouriteItems = snapshot.data!;
                    if (favouriteItems.isEmpty) {
                      return Center(child: Text("No favourite items yet"));
                    }
                    return ListView.builder(
                      itemCount: favouriteItems.length,
                      itemBuilder: (context, index) {
                        final FoodModel items = favouriteItems[index];
                        return Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 5,
                              ),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 110,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        image: DecorationImage(
                                          image: NetworkImage(items.imageCard),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(right: 20),
                                            child: Text(
                                              items.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 17,
                                              ),
                                            ),
                                          ),
                                          Text(items.category),
                                          Text(
                                            "\$${items.price}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.pink,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 50,
                              right: 35,
                              child: GestureDetector(
                                onTap: () {
                                  provider.toggleFavourite(items.name);
                                },
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 25,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  Future<List<FoodModel>> _fetchFavouriteItems(
    List<Map<String, dynamic>> favourites,
  ) async {
    List<String> productNames = favourites
        .map((fav) => fav["product_id"].toString())
        .toList();
    if (productNames.isEmpty) return [];
    try {
      final response = await supabase
          .from("food_product")
          .select()
          .inFilter("name", productNames);
      if (response.isEmpty) {
        return [];
      }
      return response.map((data) => FoodModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint("Error fetching favourite items: $e");
      return [];
    }
  }
}
