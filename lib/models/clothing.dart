import 'package:intl/intl.dart';

class Clothing {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String? description;
  final DateTime? paymentDeadline;
  final double? depositPaid;
  final bool isInInventory;

  Clothing({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.description,
    this.paymentDeadline,
    this.depositPaid,
    this.isInInventory = false,
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
}
