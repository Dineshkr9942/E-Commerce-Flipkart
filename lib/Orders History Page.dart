import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'Product Page.dart';

class ordersPage extends StatefulWidget {
  const ordersPage({super.key});

  @override
  State<ordersPage> createState() => _ordersPageState();
}

class _ordersPageState extends State<ordersPage> {
  List<OrderModel> orders = [];
  bool isLoading = true;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadOrders();
  }


  Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedOrders = prefs.getStringList("orders") ?? [];

    setState(() {
      orders = storedOrders
          .map((e) => OrderModel.fromJson(jsonDecode(e)))
          .toList()
          .reversed
          .toList();
      isLoading = false;
    });
  }

  Widget _buildOrderStatusChip(String status) {
    Color color;

    switch (status) {
      case "Shipped":
        color = Colors.orange;
        break;
      case "Delivered":
        color = Colors.green;
        break;
      default:
        color = Colors.blue;
    }

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
    );
  }

  Future<void> cancelOrder(OrderModel order) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> orders = prefs.getStringList('orders') ?? [];

    int index = orders.indexWhere((e) =>
    OrderModel.fromJson(jsonDecode(e)).orderId == order.orderId);

    if (index != -1) {
      OrderModel updated = order.copyWith(status: "Cancelled");
      orders[index] = jsonEncode(updated.toJson());
      await prefs.setStringList('orders', orders);
    }

    loadOrders();
  }

  void showCancelDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Cancel Order"),
        content: Text("Are you sure you want to cancel this order?"),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text("No",style: TextStyle(color: Colors.white),),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Yes, Cancel", style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pop(context);
              cancelOrder(order);
            },
          ),
        ],
      ),
    );
  }

  Future<void> reorder(OrderModel order) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];

    for (var item in order.items) {
      final id = item['id'].toString();
      if (!cart.contains(id)) {
        cart.add(id);
      }
    }

    await prefs.setStringList('cart', cart);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Items added to cart")),
    );
  }

  Widget orderStatusTracker(String status) {
    int currentStep = status == "Placed"
        ? 0
        : status == "Shipped"
        ? 1
        : status == "Delivered"
        ? 2
        : 0;

    return Stepper(
      currentStep: currentStep,
      physics: NeverScrollableScrollPhysics(),
      controlsBuilder: (_, __) => SizedBox.shrink(),
      steps: const [
        Step(title: Text("Placed"), content: SizedBox()),
        Step(title: Text("Shipped"), content: SizedBox()),
        Step(title: Text("Delivered"), content: SizedBox()),
      ],
    );
  }

  Widget _emptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 90, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No orders yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            "Your placed orders will appear here",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),
        backgroundColor: Colors.blue.shade100,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? _emptyOrders()
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ExpansionTile(
              title: Text(
                "Order ID: ${order.orderId}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "₹${order.totalAmount} • ${order.paymentMethod}",
                    style: TextStyle(color: Colors.green),
                  ),
                  SizedBox(height: 4),
                  Text(
                    order.isEmi ? "EMI Order" : "Full Payment",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: order.isEmi ? Colors.orange : Colors.blue,
                    ),
                  ),
                ],
              ),
              trailing: _buildOrderStatusChip(order.status),
              children: [
                orderStatusTracker(order.status),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ordered on: ${DateFormat('dd MMM yyyy, hh:mm a').format(order.orderDate)}",
                      ),
                      Text(
                        "Delivery by: ${DateFormat('dd MMM yyyy').format(order.deliveryDate)}",
                      ),
                      Divider(),
                      ...order.items.map((item) {
                        return InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => productPage(
                                  id: item['id'],
                                ),
                              ),
                            );
                            loadOrders();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Image.network(item['thumbnail'],width: 50),
                              title: Text(item['title'], ),
                              trailing: Text("₹${item['price']}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                            ),
                          ),
                        );
                      }).toList(),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (order.status == "Placed")
                          TextButton.icon(
                              style: TextButton.styleFrom(backgroundColor: Colors.red),
                              icon: Icon(Icons.cancel, color: Colors.white),
                              label: Text("Cancel",style: TextStyle(color: Colors.white),),
                              onPressed: () => showCancelDialog(order),
                            ),
                          TextButton.icon(
                            style: TextButton.styleFrom(backgroundColor: Colors.blue),
                            icon: Icon(Icons.refresh,color: Colors.white,),
                            label: Text("Reorder",style: TextStyle(color: Colors.white)),
                            onPressed: () => reorder(order),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class OrderModel {
  final String orderId;
  final double totalAmount;
  final String paymentMethod;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final List<dynamic> items;
  final bool isEmi;
  String status;

  OrderModel({
    required this.orderId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.orderDate,
    required this.deliveryDate,
    required this.items,
    required this.isEmi,
    this.status = "Placed",
  });

  OrderModel copyWith({
    String? orderId,
    double? totalAmount,
    String? paymentMethod,
    DateTime? orderDate,
    DateTime? deliveryDate,
    List<dynamic>? items,
    String? status,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      items: items ?? this.items,
      isEmi: isEmi ?? this.isEmi,
      status: status ?? this.status,
    );
  }


  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'],
      totalAmount: json['totalAmount'].toDouble(),
      paymentMethod: json['paymentMethod'],
      orderDate: DateTime.parse(json['orderDate']),
      deliveryDate: DateTime.parse(json['deliveryDate']),
      items: json['items'],
      isEmi: json['isEmi'] ?? false,
      status: json['status'] ?? "Placed",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate.toIso8601String(),
      'items': items,
      'isEmi': isEmi,
      'status': status,
    };
  }
}

