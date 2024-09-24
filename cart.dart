import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'delivery.dart';
import 'menu.dart';
import 'user_data.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<String> titles = [];
  List<String> descriptions = [];
  List<double> prices = [];
  List<String> images = [];
  List<String> options = [];
  List<String> additives = [];
  List<int> quantity = [];
  List<String> itemIds = []; 

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  Future<void> _loadCartData() async {
    try {
      final cartId = UserData.cartId;

      if (cartId == null) {
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.15:8000/api/cart/$cartId/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          titles = List<String>.from(data['titles']);
          descriptions = List<String>.from(data['descriptions']);
          prices = List<double>.from(data['prices']);
          images = List<String>.from(data['images']);
          quantity = List<int>.from(data['quantity']);
          options = List<String>.from(data['options']);
          additives = List<String>.from(data['additives']);
          itemIds = List<String>.generate(titles.length, (index) => UniqueKey().toString());
        });
      }
      else {
        print('Failed to load cart data: ${response.body}');
      }
    }
    catch (e) {
      print('Error: $e');
    }
  }
  
  Future<void> _updateItemQuantity(int index, int newQuantity) async {
    try {
      final cartId = UserData.cartId;

      if (cartId == null) {
        return;
      }

      await http.put(
        Uri.parse('http://192.168.1.15:8000/api/cart/$cartId/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'quantity': quantity,
        }),
      );
    } 
    catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _removeItem(int index) async {
    try {
      final cartId = UserData.cartId;

      if (cartId == null) {
        print('Cart ID is null');
        return;
      }

      final response = await http.delete(
        Uri.parse('http://192.168.1.15:8000/api/cart/$cartId/$index/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          titles.removeAt(index);
          descriptions.removeAt(index);
          prices.removeAt(index);
          images.removeAt(index);
          quantity.removeAt(index);
          itemIds.removeAt(index);
          if (titles.isEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Menu()),
            );
          }
        });
      } else {
        print('Failed to remove item: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  int getTotalPrice() {
    int totalPrice = 0;

    for (int i = 0; i < prices.length; i++) {
      totalPrice += (prices[i].toInt() * quantity[i]);
    }

    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final double buttonWidth = 0.033 * height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text('Корзина', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: titles.isEmpty && descriptions.isEmpty && prices.isEmpty && images.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 0; i < titles.length; i++) ...[
                    Dismissible(
                      key: Key(itemIds[i]), 
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        await _removeItem(i);
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1, color: Color(0xFFD9D9D9)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 0.1125 * height,
                                    height: 0.1125 * height,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(images[i]),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          titles[i],
                                          style: TextStyle(
                                            color: Color(0xFF1E1E1E),
                                            fontSize: 20,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        if (descriptions != ' ') ...[
                                          SizedBox(height: 10),
                                          Text(
                                            descriptions[i],
                                            style: TextStyle(
                                              color: Color(0xFF757575),
                                              fontSize: 14,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400,
                                              height: 1.5,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                        if (options[i] != ' ' || additives[i] != ' ') SizedBox(height: 10),
                                        if (options[i] != ' ') ...[
                                          Text(
                                            options[i],
                                            style: TextStyle(
                                              color: Color(0xFF757575),
                                              fontSize: 14,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400,
                                              height: 1.5,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                        if (additives[i] != ' ') ...[
                                          Text(
                                            additives[i],
                                            style: TextStyle(
                                              color: Color(0xFF757575),
                                              fontSize: 14,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400,
                                              height: 1.5,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Container(
                                      width: 0.1 * height,
                                      height: 34,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(width: 1, color: Color(0xFFD9D9D9)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${prices[i].toInt() * quantity[i]}р',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFF1D1B20),
                                            fontSize: 16,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox.shrink(),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      width: 0.1 * height,
                                      height: 30,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: buttonWidth,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(0xFF2C2C2C),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.zero,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  quantity[i]--;
                                                  _updateItemQuantity(i, quantity[i]);
                                                  if (quantity[i] == 0) {
                                                    _removeItem(i);
                                                  }
                                                });
                                              },
                                              child: Text(
                                                '-',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: buttonWidth,
                                            alignment: Alignment.center,
                                            child: Text(
                                              quantity[i].toString(),
                                              style: TextStyle(
                                                color: Color(0xFF1D1B20),
                                                fontSize: 16,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.10,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: buttonWidth,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: quantity[i] < 50 ? Color(0xFF2C2C2C) : Color(0xFFD9D9D9),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.zero,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  if (quantity[i] < 50) {
                                                    quantity[i]++;
                                                    _updateItemQuantity(i, quantity[i]);
                                                  }
                                                });
                                              },
                                              child: Text(
                                                '+',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.white,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C2C2C),
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Delivery()),
                );
              },
              child: Text(
                'Далее ${getTotalPrice()}р',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
