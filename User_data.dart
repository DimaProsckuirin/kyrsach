class UserData {
  final String phoneNumber;
  static int? cartId;

  UserData({
    required this.phoneNumber,
    int? cartId,
  }) {
    UserData.cartId = cartId;
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      phoneNumber: json['phone_number'],
      cartId: json['cart_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'cart_id': cartId,
    };
  }
}
