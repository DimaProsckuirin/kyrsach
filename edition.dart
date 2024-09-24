import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_data.dart';

class ItemDetail extends StatefulWidget {
  final String title;
  final String description;
  final double price;
  final String image;
  final List<String> options;
  final String itemType;

  ItemDetail({
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    required this.options,
    required this.itemType,
  });

  @override
  _ItemDetailState createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  String selectedSize = 'Средняя';
  String selectedSizeForDrinks = '0,5';
  String selectedCrust = 'Традиционное';
  List<String> selectedAdditives = [];
  List<String> selectedOptions = [];
  double basePrice = 0.0;

  final Map<String, double> sizePrices = {
    'Маленькая': 0.0,
    'Средняя': 200.0,
    'Большая': 350.0,
    '0,33': -30.0,
    '0,5': 0.0,
  };

  final sizeMapping = {
    'Маленькая': 'Маленькая 25 см',
    'Средняя': 'Средняя 30 см',
    'Большая': 'Большая 35 см',
    '0,33': '330мл',
    '0,5': '500мл',
  };

  final Map<String, double> additivePrices = {
    'Сыр чеддер': 50,
    'Халапеньо': 50,
    'Цыплёнок': 50,
    'Ананасы': 50,
    'Бекон': 50,
    'Шампиньоны': 50,
  };

  final crustMapping = {
    'Тонкое': 'тонкое тесто',
    'Традиционное': 'традиционное тесто',
  };

  String formating(List<String>? list) {
    if (list == null || list.isEmpty) {
      return '';
    }
    return list.map((item) => item.toLowerCase()).join(', ');
  }

  @override
  void initState() {
    super.initState();
    basePrice = widget.price;
    if (widget.itemType == 'Пицца') {
      selectedSize = 'Средняя';
      
    } else if (widget.itemType == 'Напиток') {
      selectedSize = '0,5';
    }
  }

  double getTotalPrice() {
    double totalPrice = basePrice;
    if (widget.itemType == 'Пиццы') {
      totalPrice += sizePrices[selectedSize] ?? 0.0;

      for (String additive in selectedAdditives) {
        totalPrice += additivePrices[additive] ?? 0.0;
      }
    }
    else {
      totalPrice += sizePrices[selectedSizeForDrinks] ?? 0.0;
    }

    return totalPrice;
  }

  Future<void> _addToCart() async {
    final cartId = UserData.cartId;
    String description = ' ';
    if (cartId == null) {
      print('Cart ID is null');
      return;
    }

    if (widget.itemType == 'Пиццы') {
      description = '${sizeMapping[selectedSize]}, ${crustMapping[selectedCrust]}';
    } else if (widget.itemType == 'Напитки') {
      description = '${sizeMapping[selectedSizeForDrinks]}';
    }

    final response = await http.post(
      Uri.parse('http://192.168.1.15:8000/api/add-to-cart/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'cart_id': cartId,
        'title': widget.title,
        'description': description,
        'price': getTotalPrice(),
        'image': widget.image,
        'additives': selectedAdditives.isNotEmpty ? '+ ${formating(selectedAdditives)}' : ' ',
        'options': selectedOptions.isNotEmpty ? '- ${formating(selectedOptions)}' : ' ',
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, {'itemAdded': true});
    } else {
      print('Failed to add item to cart: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.network(
                        widget.image,
                        height: 300,
                        width: 300,
                      ),
                    ),
                    if (widget.itemType == 'Пиццы') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildOptionButton(
                            context,
                            'Маленькая',
                            selectedSize == 'Маленькая',
                            () {
                              setState(() {
                                selectedSize = 'Маленькая';
                              });
                            },
                          ),
                          SizedBox(width: 15),
                          _buildOptionButton(
                            context,
                            'Средняя',
                            selectedSize == 'Средняя',
                            () {
                              setState(() {
                                selectedSize = 'Средняя';
                              });
                            },
                          ),
                          SizedBox(width: 15),
                          _buildOptionButton(
                            context,
                            'Большая',
                            selectedSize == 'Большая',
                            () {
                              setState(() {
                                selectedSize = 'Большая';
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildOptionButton(
                            context,
                            'Традиционное',
                            selectedCrust == 'Традиционное',
                            () {
                              setState(() {
                                selectedCrust = 'Традиционное';
                              });
                            },
                          ),
                          SizedBox(width: 15),
                          _buildOptionButton(
                            context,
                            'Тонкое',
                            selectedCrust == 'Тонкое',
                            () {
                              setState(() {
                                selectedCrust = 'Тонкое';
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text('Убрать ингредиенты', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8.0,
                        children: widget.options.map((option) {
                          return _buildChip(
                            context,
                            option,
                            selectedOptions.contains(option),
                            false,
                            () {
                              setState(() {
                                if (selectedOptions.contains(option)) {
                                  selectedOptions.remove(option);
                                } else {
                                  selectedOptions.add(option);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24),
                      Text('Добавить ингредиенты', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8.0,
                        children: additivePrices.keys.map((additive) {
                          return _buildChip(
                            context,
                            additive,
                            selectedAdditives.contains(additive),
                            true,
                            () {
                              setState(() {
                                if (selectedAdditives.contains(additive)) {
                                  selectedAdditives.remove(additive);
                                } else {
                                  selectedAdditives.add(additive);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ] else if (widget.itemType == 'Напитки') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildOptionButton(
                            context,
                            '0,33',
                            selectedSizeForDrinks == '0,33',
                            () {
                              setState(() {
                                selectedSizeForDrinks = '0,33';
                              });
                            },
                          ),
                          SizedBox(width: 15),
                          _buildOptionButton(
                            context,
                            '0,5',
                            selectedSizeForDrinks == '0,5',
                            () {
                              setState(() {
                                selectedSizeForDrinks = '0,5';
                              });
                            },
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        widget.description
                      )
                    ]
                  ],
                ),
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
              onPressed: _addToCart,
              child: Text(
                'В корзину за ${getTotalPrice().toStringAsFixed(0)}р',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, String text, bool isSelected, VoidCallback onPressed) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text('$text', style: const TextStyle(fontFamily: 'Inter')),
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF2C2C2C) : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          side: BorderSide(color: Colors.black),
          minimumSize: Size(0, 30),
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, bool isSelected, bool delOrAdd, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF2C2C2C) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        minimumSize: Size(10, 30),
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          delOrAdd
              ? Text('$label ${additivePrices[label]?.toInt()}р', style: const TextStyle(fontFamily: 'Inter'))
              : Text('$label'),
          const SizedBox(width: 10.0),
          Icon(delOrAdd ? Icons.check : Icons.close),
        ],
      ),
    );
  }
}
