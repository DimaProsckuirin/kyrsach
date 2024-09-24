import 'user_data.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cart.dart';
import 'edition.dart';

class MenuItem {
  final String title;
  final String description;
  final double price;
  final String image;
  final String type;
  final List<String>? options;

  MenuItem({
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    required this.type,
    this.options,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      image: json['image'],
      type: json['type'],
      options: json['options'] != null ? List<String>.from(json['options']) : null,
    );
  }
}

Future<List<MenuItem>> fetchMenuItems() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/menu/'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
    return jsonResponse.map((data) => MenuItem.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load menu items');
  }
}

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final ValueNotifier<int> cartItemCountNotifier = ValueNotifier<int>(0); // ValueNotifier для корзины
  final ScrollController _scrollController = ScrollController();

  final Map<String, GlobalKey> _keys = {
    'Пиццы': GlobalKey(),
    'Напитки': GlobalKey(),
    'Закуски': GlobalKey(),
    'Десерты': GlobalKey(),
    'Соусы': GlobalKey(),
    'Другое': GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _updateCartItemCount();
  }

  Future<int> fetchCartItemCount() async {
    try {
      final cartId = UserData.cartId;
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/cart/$cartId/count/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load cart item count');
      }
    } catch (e) {
      print('Error fetching cart item count: $e');
      return 0;
    }
  }

  Future<void> _navigateToItemDetail(String title, String description, double price, String image, List<String>? options, String type) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetail(
          title: title,
          description: description,
          price: price,
          image: image,
          options: options ?? [],
          itemType: type,
        ),
      ),
    );

    _updateCartItemCount();
  }

  Future<void> _navigateToCart() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Cart(),
      ),
    );

    _updateCartItemCount();
  }

  Future<void> _updateCartItemCount() async {
    final count = await fetchCartItemCount();

    if (cartItemCountNotifier.value != count) {
      cartItemCountNotifier.value = count;
    }
  }

  void _scrollToType(String type) {
    final key = _keys[type];
    if (key != null) {
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(context, duration: Duration(seconds: 1), curve: Curves.easeInOut);
      }
    }
  }

  @override
  void dispose() {
    cartItemCountNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final fontSize = (16 * height / 800).round().toDouble();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 0.0,
      ),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            top: 10,
            child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMenuButton('Пиццы', fontSize),
                    _buildMenuButton('Напитки', fontSize),
                    _buildMenuButton('Закуски', fontSize),
                    _buildMenuButton('Десерты', fontSize),
                    _buildMenuButton('Соусы', fontSize),
                    _buildMenuButton('Другое', fontSize),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: 60,
            child: FutureBuilder<List<MenuItem>>(
              future: fetchMenuItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ошибка загрузки данных'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Нет данных для отображения'));
                }

                final menuItems = snapshot.data!;

                return SingleChildScrollView(
                  controller: _scrollController,
                  child: Center(
                    child: Container(
                      width: width - 10,
                      child: Column(
                        children: _buildMenuItems(menuItems, height),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: cartItemCountNotifier,
            builder: (context, cartItemCount, child) {
              if (cartItemCount > 0) {
                return Positioned(
                  bottom: 16,
                  left: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      _navigateToCart();
                    },
                    backgroundColor: const Color(0xFF2C2C2C),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(Icons.shopping_cart, color: Colors.white),
                        Positioned(
                          right: -8,
                          top: -8,
                          child: Center(
                            child: Text(
                              '$cartItemCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Container(); // Если в корзине нет предметов, ничего не показываем
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String text, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11.0),
      child: GestureDetector(
        onTap: () => {
          _scrollToType(text),
          _updateCartItemCount(), // Обновляем количество предметов в корзине при нажатии на кнопку
        },
        child: Container(
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: ShapeDecoration(
            color: const Color(0xFF2C2C2C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: const Color(0xFFF5F5F5),
              fontSize: fontSize,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(List<MenuItem> items, double height) {
    Map<String, List<MenuItem>> groupedItems = {};
    for (var item in items) {
      if (!groupedItems.containsKey(item.type)) {
        groupedItems[item.type] = [];
      }
      groupedItems[item.type]!.add(item);
    }

    List<Widget> itemWidgets = [];
    groupedItems.forEach((type, items) {
      itemWidgets.add(
        Container(
          key: _keys[type],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: items.map((item) {
                  return _buildMenuItem(
                    context,
                    item.title,
                    item.description,
                    item.price,
                    item.image,
                    item.options,
                    height / 4,
                    item.type,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    });

    return itemWidgets;
  }

  Widget _buildMenuItem(BuildContext context, String title, String description, double price, String image, List<String>? options, double height, String type) {
    return GestureDetector(
      onTap: () {
        _navigateToItemDetail(title, description, price, image, options ?? [], type);
        _updateCartItemCount();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
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
                    width: 0.8 * height,
                    height: 0.8 * height,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(image),
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
                          title,
                          style: TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          description,
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 82,
                  height: 34,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Color(0xFF79747E)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '${price.toStringAsFixed(0)}р',
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
            ],
          ),
        ),
      ),
    );
  }
}
