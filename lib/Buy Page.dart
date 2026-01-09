import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Home Page.dart';
import 'Product Page.dart';

class buyPage extends StatefulWidget {
  final int? id;
  final List<Map<String, dynamic>>? cartItems;
  final Map<int, int>? cartQty;
  final bool isEmi;

  buyPage({
    super.key,
    this.id,
    this.cartItems,
    this.cartQty,
    required this.isEmi,
  });

  @override
  State<buyPage> createState() => _buyPageState();
}

class _buyPageState extends State<buyPage> {

  Map<String,dynamic> products={};
  late Future<Map<String, dynamic>> f1;
  int selectedPayment = -1;

  List paymentMethods = [
    {"title": "Credit / Debit Card"},
    {"title": "UPI"},
    {"title": "Net Banking"},
    {"title": "Cash on Delivery"},
  ];

  @override
  void initState() {
    super.initState();
    f1 = getProducts();
  }

  Future<Map<String,dynamic>> getProducts() async{
    print("Id is :${widget.id}");
    try{
      var response = await http.get(Uri.parse("https://dummyjson.com/products/${widget.id}"));
      var bodyData = jsonDecode(response.body);
      print(response.statusCode);
      if(response.statusCode==200){
        products = bodyData;
        print(products);
        return products;
      }
      else{
        throw Exception("Failed to load data");
      }
    }
    catch(e){
      throw Exception(e);
    }
  }

  Future<void> saveOrder(Map<String, dynamic> product, String paymentMethod) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> storedOrders = prefs.getStringList('orders') ?? [];

    String orderId = "FK${Random().nextInt(99999999).toString().padLeft(8, '0')}";

    List<Map<String, dynamic>> items = [
      {
        "id": product['id'],
        "title": product['title'],
        "thumbnail": product['thumbnail'],
        "price": product['price'],
        "quantity": 1,
      }
    ];

    Map<String, dynamic> order = {
      "orderId": orderId,
      "totalAmount": product['price'],
      "paymentMethod": paymentMethod,
      "isEmi": widget.isEmi,
      "orderDate": DateTime.now().toIso8601String(),
      "deliveryDate": DateTime.now().add(Duration(days: 7)).toIso8601String(),
      "items": items,
      "status": "Placed",
    };

    storedOrders.add(jsonEncode(order));

    await prefs.setStringList('orders', storedOrders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade100,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back)),
        title: Text("Order Summary"),
      ),
      body: FutureBuilder(future: f1, builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }
        else if(snapshot.hasError){
          return Text("Error : ${snapshot.error}");
        }
        else if(snapshot.hasData){
          final double price = products["price"].toDouble();
          final double discountPercent = products["discountPercentage"].toDouble();

          final double originalPrice =
              price / (1 - (discountPercent / 100));

          final double discountAmount = originalPrice - price;

          double finalPayable;
          String payLabel;

          if (widget.isEmi) {
            finalPayable = price / 6;
            payLabel = "Monthly EMI";
          } else {
            finalPayable = price;
            payLabel = "Total Payable";
          }

          return SingleChildScrollView(
            child: Column(
              children: [SizedBox(height: 10,),
// Address
                Row(
                  children: [SizedBox(width: 10,),
                    Text("Delivered to : ",style: TextStyle(
                        fontSize: 17,fontWeight: FontWeight.bold
                    ),)
                  ],
                ),
                SizedBox(height: 10,),
                Container(
                  height: 40,
                  width: 300,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 5,),
                      Text("Add an Address",style: TextStyle(
                          fontSize: 16
                      ),)
                    ],
                  ),
                ),
                SizedBox(height: 5,),
                Container(
                  height: 40,
                  width: 300,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.select_all),
                      SizedBox(width: 5,),
                      Text("Select an Address",style: TextStyle(
                          fontSize: 16
                      ),)
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Divider(),
                SizedBox(height: 10,),
// Product
                Row(
                  children: [SizedBox(width: 10,),
                    Text("Your Selected Product : ",style: TextStyle(
                        fontSize: 17,fontWeight: FontWeight.bold
                    ),)
                  ],
                ),
                SizedBox(height: 10,),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => productPage(id: products['id']),
                      ),
                    );
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
                                  image: DecorationImage(image: NetworkImage(products['thumbnail']))
                              ),
                            ),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10,),
                                  Text(products["title"],style: TextStyle(
                                      fontWeight: FontWeight.bold,fontSize: 15
                                  ),),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      RatingBarIndicator(
                                          itemCount: 5,
                                          rating: products['rating'],
                                          itemSize: 20,
                                          itemBuilder: (context,int index)=>Icon(Icons.star,color: Colors.green,)
                                      ),
                                      SizedBox(width: 10,),
                                      Text("(${products["rating"].toString()})"),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      Icon(Icons.arrow_downward,size: 20,color: Colors.green,),
                                      Text("${products["discountPercentage"].toString()} %",style: TextStyle(
                                          fontSize: 16,color: Colors.green,fontWeight: FontWeight.bold
                                      ),),
                                      SizedBox(width: 10,),
                                      Text(
                                        "₹ ${originalPrice.toStringAsFixed(0)}",
                                        style: TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      Text("₹ ${products["price"].toString()}",style: TextStyle(
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
                                  Text("Brand : ${products['brand'].toString()}",style: TextStyle(
                                      fontWeight: FontWeight.bold,color: Colors.grey.shade600
                                  ),),
                                  SizedBox(height: 5,),
                                  Text("Only left : ${products["stock"]}".toString(),style: TextStyle(
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
                ),
                SizedBox(height: 10,),
// Add more
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>homePage()));
                  },
                  child: Container(
                    height: 40,
                    width: 300,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 5,),
                        Text("Add more Items",style: TextStyle(
                            fontSize: 16
                        ),)
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Divider(),
                SizedBox(height: 10,),
// Price
                Row(
                  children: [SizedBox(width: 10,),
                    Text("Price Details : ",style: TextStyle(
                        fontSize: 17,fontWeight: FontWeight.bold
                    ),)
                  ],
                ),
                SizedBox(height: 10,),
                Card(
                  color: Colors.grey.shade200,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    child: Column(
                      children: [
                        Row(
                          children: [SizedBox(width: 10,),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text("Price (item):",style: TextStyle(fontSize: 16),),
                            ),
                            Spacer(),
                            Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text("₹ ${originalPrice.toStringAsFixed(0)}")
                            ),
                            SizedBox(width: 10,),
                          ],
                        ),
                        Row(
                          children: [SizedBox(width: 10,),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text("Discount Percentage :",style: TextStyle(fontSize: 16),),
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text("${products["discountPercentage"].toString()} %",style: TextStyle(
                                fontSize: 16,
                              ),),
                            ),
                            SizedBox(width: 3,),
                          ],
                        ),
                        Row(
                          children: [SizedBox(width: 10,),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text("Discount Price :",style: TextStyle(fontSize: 16),),
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                "₹ ${discountAmount.toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(width: 10,),
                          ],
                        ),
                        Row(
                          children: [SizedBox(width: 10,),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text("Total :",style: TextStyle(fontSize: 18),),
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                "₹ ${products["price"]} /-",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 10,),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10,),
// Coupons
                Row(
                  children: [SizedBox(width: 10,),
                    Text("Apply Coupons : ",style: TextStyle(
                        fontSize: 17,fontWeight: FontWeight.bold
                    ),)
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: [SizedBox(width: 70,),
                    SizedBox(
                        height: 40,width: 150,
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: "Enter Code",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)
                              )
                          ),
                        )
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                          onPressed: (){}, child: Text("Apply",style: TextStyle(color: Colors.black),)),
                    )
                  ],
                ),
                SizedBox(height: 10,),
                Container(
                  height: 40,
                  width: 300,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 5,),
                      Text("Apply Coupon for Discount",style: TextStyle(
                          fontSize: 16
                      ),)
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  height: 40,
                  width: 300,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.remove),
                      SizedBox(width: 5,),
                      Text("Remove Coupon",style: TextStyle(
                          fontSize: 16
                      ),)
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
// Payment Methods
                Row(
                  children: [
                    SizedBox(width: 10),
                    Text(
                      "Payment Methods :",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
// Payment Options
                Column(
                  children: [
                    ...[
                      {"icon": Icons.credit_card, "title": "Credit / Debit Card", "color": Colors.blue},
                      {"icon": Icons.payment, "title": "UPI", "color": Colors.green},
                      {"icon": Icons.account_balance, "title": "Net Banking", "color": Colors.orange},
                      {"icon": Icons.money, "title": "Cash on Delivery", "color": Colors.purple},
                    ].asMap().entries.map<Widget>((entry) {
                      int index = entry.key;
                      Map<String, dynamic> item = entry.value; // cast to Map<String, dynamic>
                      bool isSelected = selectedPayment == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPayment = index;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.yellow.shade600 : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? Colors.orange : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(item["icon"] as IconData, color: item["color"] as Color),
                              SizedBox(width: 10),
                              Text(
                                item["title"] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              Spacer(),
                              if (isSelected) Icon(Icons.check_circle, color: Colors.green),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        }
        else{
          return Text("No data found");
        }
      }),
      bottomNavigationBar: FutureBuilder(
        future: f1,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return SizedBox(
              height: 60,
              child: Center(child: Text("Error")),
            );
          } else if (snapshot.hasData) {
            final double price = snapshot.data!["price"].toDouble();
            double finalPayable;
            if (widget.isEmi) {
              finalPayable = price / 6; // EMI
            } else {
              finalPayable = price; // Full payment
            }
            return BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(double.infinity, 45),
                    backgroundColor: Colors.yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () async {
                    if (selectedPayment == -1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a payment method"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      await saveOrder(products, paymentMethods[selectedPayment]["title"]);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderSuccessPage(
                            paymentIndex: selectedPayment,
                            paymentMethod: paymentMethods[selectedPayment]["title"],
                            orderId: "FK${Random().nextInt(99999999).toString().padLeft(8, '0')}",
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    widget.isEmi
                        ? "Pay EMI  ₹ ${finalPayable.toStringAsFixed(0)} / month"
                        : "Pay  ₹ ${finalPayable.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}

// Order Success Page

class OrderSuccessPage extends StatefulWidget {
  final int paymentIndex;
  final String paymentMethod;
  final String orderId;

  const OrderSuccessPage({
    super.key,
    required this.paymentIndex,
    required this.paymentMethod,
    required this.orderId,
  });

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> {

  late ConfettiController _confettiController;
  late String orderId;

  final List<Map<String, dynamic>> paymentUI = [
    {"icon": Icons.credit_card, "color": Colors.blue},
    {"icon": Icons.payment, "color": Colors.green},
    {"icon": Icons.account_balance, "color": Colors.orange},
    {"icon": Icons.money, "color": Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: Duration(seconds: 3));
    _confettiController.play();

    orderId = generateOrderId();
  }

  String generateOrderId() {
    final random = Random();
    return "FK${random.nextInt(99999999).toString().padLeft(8, '0')}";
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            gravity: 0.3,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Colors.green,
                ),
                SizedBox(height: 20),
                Text(
                  "Order Placed Successfully!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15),
// Order ID
                Text(
                  "Order ID: $orderId",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
// Payment Method
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      paymentUI[widget.paymentIndex]["icon"],
                      color: paymentUI[widget.paymentIndex]["color"],
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.paymentMethod,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                  onPressed: () {
                    Navigator.popUntil(
                        context, (route) => route.isFirst);
                  },
                  child: Text("Continue Shopping",style: TextStyle(color: Colors.black),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


