import 'dart:convert';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';

import 'Buy Page.dart';
import 'Cart Page.dart';
import 'Category Page.dart';

class productPage extends StatefulWidget {
  final int id;
  productPage({super.key, required this.id,});

  @override
  State<productPage> createState() => _productPageState();
}
class _productPageState extends State<productPage>
    with SingleTickerProviderStateMixin {

  List images = [
    "https://tse4.mm.bing.net/th/id/OIP.BONKZIa_2WNHDExYJn1jSQHaHY?w=4026&h=4017&rs=1&pid=ImgDetMain&o=7&rm=3",
    "https://static.thcdn.com/images/small/original/productimg/0/960/960/00/10875300-1385053973-571198.jpg",
    "https://s13emagst.akamaized.net/products/48592/48591193/images/res_467c241e448b89e2882bb298bcdac506.jpg",
    "https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/40-nc-alum-starlight-sport-band-starlight?wid=2000&hei=2000&fmt=jpeg&qlt=95&.v=1694042114606",
    "https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/MTJV3?wid=1200&hei=630&fmt=jpeg&qlt=95&.v=1694014871985",
    "https://tse3.mm.bing.net/th/id/OIP.3HwgJKbtPg_XalK5g7lg3gHaHa?rs=1&pid=ImgDetMain&o=7&rm=3"
  ];

  Map<String,dynamic> products={};
  List reviews = [];
  bool isNavigatingToCart = false;
  bool isWishlisted = false;
  bool addedToCart = false;
  int newCartCount = 0;
  int cartCount = 0;
  int currentIndex = 0;
  final ValueNotifier<int> wishlistCountNotifier = ValueNotifier<int>(0);
  late AnimationController _heartController;
  late Animation<double> _heartScale;
  late var f1 = getProducts();

  Future<void> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlist = prefs.getStringList('wishlist') ?? [];
    setState(() {
      isWishlisted = wishlist.contains(products['id'].toString());
    });
  }

  Future<void> toggleWishlist() async {
    if (products.isEmpty || products['id'] == null) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> wishlist = prefs.getStringList('wishlist') ?? [];

    final String id = products['id'].toString();

    if (wishlist.contains(id)) {
      wishlist.remove(id);
      isWishlisted = false;
    } else {
      wishlist.add(id);
      isWishlisted = true;
      _heartController.forward(from: 0);
    }

    await prefs.setStringList('wishlist', wishlist);
    setState(() {});
  }

  Future<void> addToCart(BuildContext context, int productId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];
    List<String> cartNew = prefs.getStringList('cart_new') ?? [];

    if (cart.contains(productId.toString())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: const Text("Item already added to cart"),
          backgroundColor: Colors.black,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    cart.add(productId.toString());
    cartNew.add(productId.toString());

    await prefs.setStringList('cart', cart);
    await prefs.setStringList('cart_new', cartNew);

    setState(() {
      addedToCart = true;
      cartCount = cart.length;
      newCartCount = cartNew.length;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: const Text("Item added to cart"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<int> getCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('cart')?.length ?? 0;
  }

  Future<Map<String, dynamic>> getProducts() async {
    try {
      var response = await http.get(
          Uri.parse("https://dummyjson.com/products/${widget.id}")
      );

      if (response.statusCode == 200) {
        products = jsonDecode(response.body);
        reviews = products['reviews'] ?? [];
        await loadWishlist();
        return products;
      }
      else
      {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> loadCartState() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];
    List<String> cartNew = prefs.getStringList('cart_new') ?? [];

    setState(() {
      addedToCart = cart.contains(widget.id.toString());
      cartCount = cart.length;
      newCartCount = cartNew.length;
    });
  }

  @override
  void initState() {
    super.initState();
    f1 = getProducts();
    loadCartState();

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _heartScale = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(
        parent: _heartController,
        curve: Curves.easeOutBack,
      ),
    );

  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade100,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        },
          icon: const Icon(Icons.arrow_back),),
        title: SizedBox(height: 40,width: 320,
          child: TextFormField(
            decoration: InputDecoration(
              filled:  true,
              labelText: "Search Products",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20)
              ),
            ),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                splashRadius: 22,
                onPressed: isNavigatingToCart
                    ? null
                    : () async {
                  isNavigatingToCart = true;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('cart_new');
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const cartPage()),
                  );
                  if (!mounted) return;
                  await loadCartState();
                  isNavigatingToCart = false;
                },
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
              if (newCartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      newCartCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(future: f1, builder: (context,snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }
        else if(snapshot.hasError){
          return Text("Error : ${snapshot.error}");
        }
        else if(snapshot.hasData){
          final List productImages = products['images'] ?? [];
          double price = (products["price"] ?? 0).toDouble();
          double discountPercent =
          (products["discountPercentage"] ?? 0).toDouble();

          double originalPrice =
          discountPercent > 0 ? price / (1 - discountPercent / 100) : price;

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 400,
                  child: Stack(
                    children: [
                      CarouselSlider.builder(
                        itemCount: productImages.length,
                        options: CarouselOptions(
                          height: 400,
                          viewportFraction: 1,
                          onPageChanged: (index, reason) {
                            setState(() => currentIndex = index);
                          },
                        ),
                        itemBuilder: (context, index, realIndex) {
                          return Image.network(
                            productImages[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        },
                      ),
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Column(
                          children: [
                            ScaleTransition(
                              scale: _heartScale,
                              child: IconButton(
                                onPressed: toggleWishlist,
                                icon: Icon(
                                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                                  color: isWishlisted ? Colors.red : Colors.black,
                                  size: 30,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.share_outlined),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: DotsIndicator(
                    dotsCount: productImages.length,
                    position: currentIndex.toDouble(),
                  )
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const SizedBox(width: 10,),
                    Text(products['title'],style: const TextStyle(
                        fontSize: 20,fontWeight: FontWeight.bold
                    ),),
                  ],
                ),
                const SizedBox(height: 3,),
                Row(
                  children: [
                    const SizedBox(width: 10,),
                    Text("Brand : ( ${products["brand"] ?? "No Mention"} )",style: TextStyle(
                        fontSize: 15,fontWeight: FontWeight.bold,color: Colors.red.shade300
                    ),),
                  ],
                ),
                const SizedBox(height: 5,),
                Row(
                  children: [
                    const SizedBox(width: 10,),
                    Text("Category : ( ${products["category"] ?? "No Category"} )",style: const TextStyle(
                        fontSize: 15,fontWeight: FontWeight.bold
                    ),),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const SizedBox(width: 10,),
                    Expanded(child: Text(products['description']))
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const SizedBox(width: 10,),
                    Container(
                      height: 50,
                      width: 70,
                      decoration: BoxDecoration(
                          image: DecorationImage(image: NetworkImage("https://tse1.mm.bing.net/th/id/OIP.2gahiWSZ4a_tSv-WI-yjmgHaE7?w=2000&h=1333&rs=1&pid=ImgDetMain&o=7&rm=3"))
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Text("Unbeatable deal",style: TextStyle(
                        color: Colors.yellow.shade900,fontSize: 20
                    ),)
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_downward, size: 30, color: Colors.green),
                    Text("$discountPercent %",
                        style: const TextStyle(
                            fontSize: 25,
                            color: Colors.green,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Text("₹ ${originalPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 25)),
                    const SizedBox(width: 10),
                    Text("₹ $price",
                        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20,),
                const Divider(),
// Star Rating
                Row(
                  children: [
                    const SizedBox(width: 10,),
                    Column(
                      children: [
                        const Text("--- Overall Star Rating ---",
                          style: TextStyle(fontSize: 17,color: Colors.deepOrange),),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            RatingBarIndicator(
                                itemCount: 5,
                                rating: (products['rating'] ?? 0).toDouble(),
                                itemSize: 27,
                                itemBuilder: (context,int index)=>Icon(Icons.star,color: Colors.green,)
                            ),
                            const SizedBox(width: 5,),
                            Text("( ${products["rating"].toString()} rating)",
                              style: const TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 10,),
                  ],
                ),
                const SizedBox(height: 10,),
                const Divider(),
// Product Details
                Row(
                  children: [
                    const SizedBox(width: 10,),
                    const Text("Product Details :",
                      style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.deepOrange),),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(children: [
                  const SizedBox(width: 10,),
                  const Text("Warranty Period : ",
                    style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                  Text(products["warrantyInformation"]?.toString() ?? "No warranty info",
                    style: const TextStyle(fontSize: 17),)
                ],),
                const SizedBox(height: 10,),
                Row(children: [
                  const SizedBox(width: 10,),
                  const Text("Shipping : ",
                    style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                  Text(products["shippingInformation"]?.toString() ?? "No shipping info",
                    style: const TextStyle(fontSize: 17),)
                ],),
                const SizedBox(height: 10,),
                Row(children: [
                  const SizedBox(width: 10,),
                  const Text("Availability : ",
                    style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                  Text(products["availabilityStatus"]?.toString() ?? "No availability info",
                    style: const TextStyle(fontSize: 17),)
                ],),
                const SizedBox(height: 10,),
                Row(children: [
                  const SizedBox(width: 10,),
                  const Text("Return Policy : ",
                    style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                  Text(products["returnPolicy"]?.toString() ?? "No return info",
                    style: const TextStyle(fontSize: 17),)
                ],),
                const SizedBox(height: 10,),
                Row(children: [
                  const SizedBox(width: 10,),
                  const Text("Minimum Order Quantity : ",
                    style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                  Text(products["minimumOrderQuantity"]?.toString() ?? "No quantity info",
                    style: const TextStyle(fontSize: 17),)
                ],),
                const SizedBox(height: 10,),
                Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: const Center(child: Text("More Details >",
                    style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold),)),
                ),
                const SizedBox(height: 10,),
                const Divider(),
// Customer Reviews
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const SizedBox(width: 10,),
                    const Text("Customer Reviews :",
                      style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.deepOrange),),
                  ],
                ),
                reviews.isEmpty
                    ? const Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    "No reviews available",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
                    : ListView.builder(
                  itemCount: reviews.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final r = reviews[index];
                    return ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(child: const Icon(Icons.person)),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r['reviewerName'] ?? "User",
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(r['reviewerEmail'] ?? "",
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          RatingBarIndicator(
                            rating: (r['rating'] ?? 4).toDouble(),
                            itemCount: 5,
                            itemSize: 20,
                            itemBuilder: (_, __) =>
                            const Icon(Icons.star, color: Colors.green),
                          ),
                          const SizedBox(height: 5),
                          Text(r['comment'] ?? "Good product"),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10,),
                Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: const Center(child: const Text("Show More >",
                    style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold),)),
                ),
                const SizedBox(height: 10,),
                const Divider(),
// Explore More Items
                Row(
                  children: [
                    const SizedBox(width: 10,),
                    const Text("Explore More Items :",
                      style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.deepOrange),),
                  ],
                ),
                const SizedBox(height: 10,),
                SizedBox(height: 560,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.1/0.1,
                      mainAxisSpacing: 0.1,
                      crossAxisSpacing: 0.1,
                    ),
                    itemCount: images.length,
                    itemBuilder: (BuildContext context, int index)
                    {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>const categoryPage()));
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            child: Image.network(images[index],fit: BoxFit.cover,),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10,),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const categoryPage()));
                  },
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: const Center(child: const Text("View Categories >",
                      style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Colors.white),)),
                  ),
                )
              ],
            ),
          );
        }
        else{
          return const Text("No data found");
        }
      }),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 70,
          width: double.infinity,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: products.isEmpty
                        ? null
                        : () {
                      addToCart(context, products['id']);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add_shopping_cart_outlined),
                  ),
                  if (addedToCart)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => buyPage(
                        id: products['id'],
                        isEmi: true,
                      ),
                    ),
                  );
                },
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(140, 40),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      )
                  ),
                  child: const Text("Buy with EMI")
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => buyPage(
                        id: products['id'],
                        isEmi: false,
                      ),
                    ),
                  );
                },
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(140, 40),
                      backgroundColor: Colors.yellow,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      )
                  ),
                  child: const Text("Buy Now")
              ),
            ],
          ),
        ),
      ),
    );
  }
}
