import 'package:flutter/material.dart';
import '../models/clothing.dart';

class PendingPaymentScreen extends StatelessWidget {
  PendingPaymentScreen({Key? key}) : super(key: key);

  // 模拟数据 - 已付定金但未补尾款的衣服
  final List<Clothing> pendingItems = [
    Clothing(
      id: '5',
      name: '玫瑰洛丽塔',
      price: 1488.00,
      imageUrl: 'https://via.placeholder.com/300x400?text=Rose Lolita',
      description: '优雅玫瑰主题的洛丽塔连衣裙',
      paymentDeadline: DateTime.now().add(const Duration(days: 15)),
      depositPaid: 300.00,
    ),
    Clothing(
      id: '6',
      name: '星星洛丽塔',
      price: 1388.00,
      imageUrl: 'https://via.placeholder.com/300x400?text=Star Lolita',
      description: '星空图案的洛丽塔套装',
      paymentDeadline: DateTime.now().add(const Duration(days: 7)),
      depositPaid: 280.00,
    ),
    Clothing(
      id: '7',
      name: '蝴蝶结洛丽塔',
      price: 1288.00,
      imageUrl: 'https://via.placeholder.com/300x400?text=Bow Lolita',
      description: '甜美蝴蝶结装饰的洛丽塔连衣裙',
      paymentDeadline: DateTime.now().add(const Duration(days: 30)),
      depositPaid: 250.00,
    ),
  ];

  // 计算总尾款金额
  double get totalRemainingPayment {
    return pendingItems.fold(0.0, (sum, item) => sum + item.remainingPayment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '待付尾款',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.pink[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      '总尾款金额: ¥${totalRemainingPayment.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: pendingItems.length,
                itemBuilder: (context, index) {
                  final item = pendingItems[index];
                  final remainingDays = item.remainingDays;
                  return Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 160,
                            child: Container(
                              // 使用颜色和文本作为图片占位符，避免网络请求
                              color: Colors.purple[100],
                              child: Center(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(item.description!),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Text('总价: ${item.formattedPrice}'),
                                      const SizedBox(width: 16.0),
                                      Text('定金: ${item.formattedDepositPaid}'),
                                    ],
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    '尾款: ${item.formattedRemainingPayment}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Text(
                                        '截止日期: ${item.formattedDeadline}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                          vertical: 2.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: remainingDays != null && remainingDays <= 7
                                              ? Colors.red[100]
                                              : Colors.green[100],
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                        child: Text(
                                          remainingDays != null
                                              ? '剩余 ${remainingDays} 天'
                                              : '无截止日期',
                                          style: TextStyle(
                                            color: remainingDays != null && remainingDays <= 7
                                                ? Colors.red
                                                : Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
