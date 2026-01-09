import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Cart Page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Product Page.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {

  Map<String,dynamic> bodydata = {};
  var list = [];
  late Future<Map<String, dynamic>> f1 = getData();
  int wishlistCount = 0;
  final ValueNotifier<int> wishlistCountNotifier =
  ValueNotifier<int>(0);

  Future<Map<String,dynamic>> getData() async{
    try{
      var response = await http.get(Uri.parse("https://dummyjson.com/products"));
      print(response);
      if(response.statusCode==200){
        setState(() {
          bodydata = jsonDecode(response.body);
          list = bodydata["products"];
        });
        print(list);
        return bodydata;
      }
      else{
        throw Exception("Failed to load data");
      }
    }
    catch(e){
      throw Exception(e);
    }
  }

  Future<void> loadWishlistCount() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlist = prefs.getStringList('wishlist') ?? [];
    wishlistCountNotifier.value = wishlist.length;
  }

  Future<void> syncWishlistCount() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlist = prefs.getStringList('wishlist') ?? [];
    wishlistCountNotifier.value = wishlist.length;
  }

  @override
  void initState() {
    super.initState();
    loadWishlistCount();
    syncWishlistCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade100,
        title: SizedBox(height: 40,width: 320,
          child: TextFormField(
            decoration: InputDecoration(
                filled:  true,
                labelText: "Search Products",
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.camera_alt_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)
                )
            ),
          ),
        ),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: wishlistCountNotifier,
            builder: (context, count, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WishlistPage(),
                        ),
                      );
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(future: f1, builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return CircularProgressIndicator();
        }
        else if(snapshot.hasError){
          return Text("Error : ${snapshot.error}");
        }
        else if(snapshot.hasData){
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context,int index){
                      final double price = list[index]["price"].toDouble();
                      final double discountPercent =
                      list[index]["discountPercentage"].toDouble();

                      final double originalPrice =
                          price / (1 - (discountPercent / 100));
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => productPage(id : list[index]['id'])));
                        },
                        child: Card(
                          color: Colors.grey.shade50,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 200,
                                    width: 150,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        image: DecorationImage(image: NetworkImage(list[index]['thumbnail']))
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10,),
                                        Text(list[index]["title"],style: TextStyle(
                                            fontWeight: FontWeight.bold,fontSize: 15
                                        ),),
                                        SizedBox(height: 5,),
                                        Row(
                                          children: [
                                            RatingBarIndicator(
                                                itemCount: 5,
                                                rating: list[index]['rating'],
                                                itemSize: 20,
                                                itemBuilder: (context,int index)=>Icon(Icons.star,color: Colors.green,)
                                            ),
                                            SizedBox(width: 10,),
                                            Text("(${list[index]["rating"].toString()})"),
                                          ],
                                        ),
                                        SizedBox(height: 5,),
                                        Row(
                                          children: [
                                            Icon(Icons.arrow_downward,size: 20,color: Colors.green,),
                                            Text("${list[index]["discountPercentage"].toString()} %",style: TextStyle(
                                                fontSize: 16,color: Colors.green,fontWeight: FontWeight.bold
                                            ),),
                                            SizedBox(width: 10,),
                                            Text(
                                              "₹ ${originalPrice.toStringAsFixed(0)}",
                                              style: TextStyle(
                                                decoration: TextDecoration.lineThrough,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            SizedBox(width: 10,),
                                            Text("₹ ${list[index]["price"].toString()}",style: TextStyle(
                                                fontSize: 16,fontWeight: FontWeight.bold
                                            ),),
                                          ],
                                        ),
                                        SizedBox(height: 5,),
                                        Row(
                                          children: [
                                            Container(
                                              height: 30,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(image: NetworkImage("https://tse1.mm.bing.net/th/id/OIP.2gahiWSZ4a_tSv-WI-yjmgHaE7?w=2000&h=1333&rs=1&pid=ImgDetMain&o=7&rm=3"))
                                              ),
                                            ),
                                            Text("Unbeatable deal",style: TextStyle(
                                                color: Colors.yellow.shade900
                                            ),)
                                          ],
                                        ),
                                        SizedBox(height: 5,),
                                        Text("Brand : ${list[index]['brand'].toString()}",style: TextStyle(
                                            fontWeight: FontWeight.bold,color: Colors.grey.shade600
                                        ),),
                                        SizedBox(height: 5,),
                                        Text("Only left : ${list[index]["stock"]}".toString(),style: TextStyle(
                                            color: Colors.grey
                                        ),),
                                        SizedBox(height: 10,),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              )
            ],
          );
        }
        else{
          return Text("No data found");
        }
      }),
    );
  }
}

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> wishlistProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWishlistProducts();
  }

  Future<void> loadWishlistProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistIds = prefs.getStringList('wishlist') ?? [];

    if (wishlistIds.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    List<Map<String, dynamic>> temp = [];

    for (String id in wishlistIds) {
      final response = await http.get(
        Uri.parse("https://dummyjson.com/products/$id"),
      );

      if (response.statusCode == 200) {
        temp.add(jsonDecode(response.body));
      }
    }

    setState(() {
      wishlistProducts = temp;
      isLoading = false;
    });
  }

  Future<void> removeFromWishlist(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> wishlist = prefs.getStringList('wishlist') ?? [];

    wishlist.remove(id);
    await prefs.setStringList('wishlist', wishlist);

    wishlistProducts.removeWhere((p) => p['id'].toString() == id);

    setState(() {});
  }

  Future<void> moveToCart(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> cart = prefs.getStringList('cart') ?? [];
    List<String> wishlist = prefs.getStringList('wishlist') ?? [];

    final String id = product['id'].toString();

    // avoid duplicate
    if (!cart.contains(id)) {
      cart.add(id);
      await prefs.setStringList('cart', cart);
    }

    wishlist.remove(id);
    await prefs.setStringList('wishlist', wishlist);

    setState(() {
      wishlistProducts.removeWhere((p) => p['id'].toString() == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Item Moved to Cart"),
        backgroundColor: Colors.black,
        action: SnackBarAction(
          label: "Go to Cart",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => cartPage()),
            );
          },
        ),
      ),
    );
  }

  Future<void> confirmRemoveFromWishlist(
      BuildContext context, String id, String title) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Remove item"),
        content: Text("Remove \"$title\" from wishlist?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final prefs = await SharedPreferences.getInstance();
              List<String> wishlist = prefs.getStringList('wishlist') ?? [];

              // store removed product for undo
              final removedProduct =
              wishlistProducts.firstWhere((p) => p['id'].toString() == id);

              wishlist.remove(id);
              await prefs.setStringList('wishlist', wishlist);

              setState(() {
                wishlistProducts.removeWhere(
                      (p) => p['id'].toString() == id,
                );
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Item removed from wishlist"),
                  action: SnackBarAction(
                    label: "UNDO",
                    textColor: Colors.yellow,
                    onPressed: () async {
                      wishlist.add(id);
                      await prefs.setStringList('wishlist', wishlist);

                      setState(() {
                        wishlistProducts.insert(0, removedProduct);
                      });
                    },
                  ),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: Text(
              "Remove",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Wishlist"),
        backgroundColor: Colors.blue.shade100,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : wishlistProducts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.2),
              duration: Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Icon(
                Icons.favorite_border,
                color: Colors.red,
                size: 100,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Your wishlist is empty",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Tap ❤️ to save your favorite items",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16),
            itemCount: wishlistProducts.length,
            itemBuilder: (context, index) {
              final product = wishlistProducts[index];
              return InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => productPage(id: product['id']),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center, // center vertically
                      children: [
                        Image.network(
                          product['thumbnail'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center, // center text vertically
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['title'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "₹ ${product['price']}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min, // only take needed space
                          children: [
                            IconButton(
                              icon: Icon(Icons.add_shopping_cart_rounded, color: Colors.green),
                              onPressed: () => moveToCart(product),
                            ),
                            IconButton(
                              icon: Icon(Icons.favorite, color: Colors.red),
                              onPressed: () => confirmRemoveFromWishlist(
                                  context,
                                  product['id'].toString(),
                                  product['title'].toString()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
      ),
    );
  }
}