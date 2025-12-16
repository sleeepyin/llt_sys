import 'package:intl/intl.dart';

class Clothing {
  String id;
  String name;
  double price;
  String? imageUrl;
  String? description;
  String? size;
  String? shopName;
  DateTime? paymentDeadline;
  double? depositPaid;
  bool isInInventory;
  bool reminderEnabled;
  String? reminderType; // 'alarm' or 'notification'
  String? notes; // 备注信息

  Clothing({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.description,
    this.size,
    this.shopName,
    this.paymentDeadline,
    this.depositPaid,
    this.isInInventory = false,
    this.reminderEnabled = false,
    this.reminderType = 'notification',
    this.notes,
  });

  // 计算剩余需要支付的尾款金额
  double get remainingPayment {
    if (depositPaid == null) return price;
    return price - (depositPaid as double);
  }

  // 计算剩余补款天数
  int? get remainingDays {
    if (paymentDeadline == null) return null;
    final now = DateTime.now();
    final difference = paymentDeadline!.difference(now);
    return difference.inDays;
  }

  // 格式化价格显示
  String get formattedPrice {
    return NumberFormat.currency(symbol: '¥', decimalDigits: 2).format(price);
  }

  // 格式化尾款显示
  String get formattedRemainingPayment {
    return NumberFormat.currency(symbol: '¥', decimalDigits: 2).format(remainingPayment);
  }

  // 格式化定金显示
  String get formattedDepositPaid {
    if (depositPaid == null) return '¥0.00';
    return NumberFormat.currency(symbol: '¥', decimalDigits: 2).format(depositPaid as double);
  }

  // 格式化截止日期显示
  String? get formattedDeadline {
    if (paymentDeadline == null) return null;
    return DateFormat('yyyy-MM-dd').format(paymentDeadline!);
  }

  // 转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'size': size,
      'shopName': shopName,
      'paymentDeadline': paymentDeadline?.toIso8601String(),
      'depositPaid': depositPaid,
      'isInInventory': isInInventory,
      'reminderEnabled': reminderEnabled,
      'reminderType': reminderType,
      'notes': notes,
    };
  }

  // 从JSON格式创建Clothing对象
  factory Clothing.fromJson(Map<String, dynamic> json) {
    return Clothing(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      description: json['description'],
      size: json['size'],
      shopName: json['shopName'],
      paymentDeadline: json['paymentDeadline'] != null
          ? DateTime.parse(json['paymentDeadline'])
          : null,
      depositPaid: json['depositPaid']?.toDouble(),
      isInInventory: json['isInInventory'] ?? false,
      reminderEnabled: json['reminderEnabled'] ?? false,
      reminderType: json['reminderType'] ?? 'notification',
      notes: json['notes'],
    );
  }
}
