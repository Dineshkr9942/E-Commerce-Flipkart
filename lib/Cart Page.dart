import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Home Page.dart';
import 'Product Page.dart';

class cartPage extends StatefulWidget {
  const cartPage({super.key});

  @override
  State<cartPage> createState() => _cartPageState();
}

class _cartPageState extends State<cartPage> {
  List<Map<String, dynamic>> cartProducts = [];
  bool isLoading = true;

  Map<int, int> cartQty = {};

  @override
  void initState() {
    super.initState();
    initCart();
    clearCartNotification();
  }
  @override

  Future<void> clearCartNotification() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart_new');
  }

  Future<void> initCart() async {
    await loadCartQty();
    await loadCartItems();
  }

  void increaseQty(int id) async {
    setState(() {
      cartQty[id] = (cartQty[id] ?? 0) + 1;
    });
    await saveCart();
  }

  void decreaseQty(int id) async {
    if ((cartQty[id] ?? 1) > 1) {
      setState(() {
        cartQty[id] = cartQty[id]! - 1;
      });
      await saveCart();
    } else {
      confirmDelete(id.toString(), "this item");
    }
  }

  void confirmDelete(String id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove item"),
        content: Text("Remove $title from cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              removeFromCart(id);
            },
            child: const Text(
              "Remove",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartIds = prefs.getStringList('cart') ?? [];

    List<Map<String, dynamic>> temp = [];

    for (String id in cartIds) {
      final response = await http.get(
        Uri.parse('https://dummyjson.com/products/$id'),
      );

      if (response.statusCode == 200) {
        temp.add(jsonDecode(response.body));
      }
    }

    for (var item in temp) {
      cartQty[item['id']] = cartQty[item['id']] ?? 1;
    }

    setState(() {
      cartProducts = temp;
      isLoading = false;
    });
  }

  Future<void> removeFromCart(String id) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> cart = prefs.getStringList('cart') ?? [];
    List<String> cartNew = prefs.getStringList('cart_new') ?? [];

    final removedIndex = cart.indexOf(id);

    cart.remove(id);
    cartNew.remove(id);

    await prefs.setStringList('cart', cart);
    await prefs.setStringList('cart_new', cartNew);

    setState(() {
      cartProducts.removeWhere((item) => item['id'].toString() == id);
      cartQty.remove(int.parse(id));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Item removed from Cart"),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () async {
            cart.insert(removedIndex, id);
            await prefs.setStringList('cart', cart);
            await loadCartItems();
            setState(() {});
          },
        ),
      ),
    );
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cartQty', jsonEncode(cartQty));
  }

  Future<void> loadCartQty() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('cartQty');
    if (data != null) {
      cartQty = Map<int, int>.from(
        jsonDecode(data).map((k, v) => MapEntry(int.parse(k), v)),
      );
    }
  }

  double get cartTotal {
    double total = 0;
    for (var product in cartProducts) {
      final qty = cartQty[product['id']] ?? 1;
      total += product['price'] * qty;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade100,
        title: const Text("My Cart"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: const CircularProgressIndicator())
          : cartProducts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
// Only Cart is Empty
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.2),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 120,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your cart is empty",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Looks like you haven’t added anything yet",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const homePage()));
              },
              icon: const Icon(Icons.shopping_bag),
              label: const Text("Start Shopping"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            )
          ],
        ),
      )
// Cart have Items
          : ListView.builder(
        itemCount: cartProducts.length,
        itemBuilder: (context, index) {
          final product = cartProducts[index];
          final qty = cartQty[product['id']] ?? 1;
          final totalPrice = product['price'] * qty;
          return Dismissible(
              key: ValueKey(product['id']),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                confirmDelete(
                  product['id'].toString(),
                  product['title'],
                );
                return false;
              },
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => productPage(id: product['id']),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    height: 140,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
// Image and Quantity
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              product['thumbnail'],
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => decreaseQty(product['id']),
                                ),
                                Text(
                                  "${cartQty[product['id']] ?? 1}",
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => increaseQty(product['id']),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
// Product Details
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['title'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "₹ $totalPrice",
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: Colors.green),
                              ),
                            ],
                          ),
                        ),
// Delete
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => confirmDelete(
                            product['id'].toString(),
                            product['title'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
        },
      ),
      bottomNavigationBar: cartProducts.isEmpty
          ? null
          : Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black12,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Amount",
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  "₹ ${cartTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Order placed for ₹ ${cartTotal.toStringAsFixed(2)}",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text(
                "Checkout",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
