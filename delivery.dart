import 'package:flutter/material.dart';
import 'menu.dart';

class Delivery extends StatefulWidget {
  @override
  _DeliveryState createState() => _DeliveryState();
}

class _DeliveryState extends State<Delivery> {
  static const String _deliveryTimeSoon = 'Как можно скорее';
  static const String _deliveryTimeScheduled = 'Ко времени';
  static const List<String> _paymentMethods = [
    'СБП',
    'SberPay',
    'Банковской картой',
    'Наличными',
  ];

  String _selectedDeliveryTime = _deliveryTimeSoon;
  String _selectedPaymentMethod = _paymentMethods.first;
  final TextEditingController _addressController = TextEditingController();

  void _onDeliveryTimeSelected(String time) {
    setState(() {
      _selectedDeliveryTime = time;
    });
  }

  void _onPaymentMethodSelected(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  void _onPayButtonPressed() {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пожалуйста, введите адрес доставки.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Спасибо за покупку!')),
      );
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Menu()),
      );
      print('Оплата произведена с адресом: ${_addressController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Доставка',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2C2C2C),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAddressSection(),
                    SizedBox(height: 20),
                    _buildDeliveryTimeSection(),
                    SizedBox(height: 20),
                    _buildPaymentMethodSection(),
                  ],
                ),
              ),
            ),
          ),
          _buildPayButton(),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFD9D9D9), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Куда доставить?',
            style: _sectionTitleTextStyle(),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              hintText: 'Введите адрес доставки:',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTimeSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFD9D9D9), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Когда доставить?',
            style: _sectionTitleTextStyle(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildDeliveryTimeOption(_deliveryTimeSoon)),
              const SizedBox(width: 16),
              Expanded(child: _buildDeliveryTimeOption(_deliveryTimeScheduled)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTimeOption(String time) {
    return GestureDetector(
      onTap: () => _onDeliveryTimeSelected(time),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: _selectedDeliveryTime == time ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: const Color(0xFFD9D9D9), width: 1.0),
        ),
        child: Center(
          child: Text(
            time,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _selectedDeliveryTime == time ? Colors.white : Colors.black,
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFD9D9D9), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Выберите способ оплаты',
            style: _sectionTitleTextStyle(),
          ),
          const SizedBox(height: 10),
          ..._paymentMethods.map((method) => _buildPaymentMethodOption(method)).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(String method) {
    return GestureDetector(
      onTap: () => _onPaymentMethodSelected(method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: _selectedPaymentMethod == method ? Colors.black : const Color(0xFFD9D9D9), width: 1.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                method,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (_selectedPaymentMethod == method)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.check, color: Colors.black),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Color(0xFFD9D9D9), width: 1.0),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C2C2C),
          minimumSize: Size(double.infinity, 50),
          elevation: 0,
        ),
        onPressed: _onPayButtonPressed,
        child: Text(
          'Оплатить ${getTotalPrice().toStringAsFixed(0)}р',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  TextStyle _sectionTitleTextStyle() {
    return TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
    );
  }

  double getTotalPrice() {
    // Возвращает цену для оплаты, пока заглушка
    return 123.45; // Примерная цена
  }
}
