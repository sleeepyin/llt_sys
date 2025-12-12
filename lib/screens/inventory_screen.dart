import 'package:flutter/material.dart';
import '../models/clothing.dart';

class InventoryScreen extends StatelessWidget {
  InventoryScreen({Key? key}) : super(key: key);

  // 模拟数据 - 已购买的衣服（库存）
  final List<Clothing> inventoryItems = [
    Clothing(
      id: '8',
      name: '薄荷洛丽塔',
      price: 1388.00,
      imageUrl: 'https://via.placeholder.com/300x400?text=Mint Lolita',
      description: '清新薄荷绿的洛丽塔连衣裙',
      isInInventory: true,
    ),
    Clothing(
      id: '9',
      name: '蕾丝洛丽塔',
      price: 1588.00,
      imageUrl: 'https://via.placeholder.com/300x400?text=Lace Lolita',
      description: '精致蕾丝装饰的洛丽塔套装',
      isInInventory: true,
    ),
    Clothing(
      id: '10',
      name: '小雏菊洛丽塔',
      price: 1288.00,
      imageUrl: 'https://via.placeholder.com/300x400?text=Daisy Lolita',
      description: '可爱小雏菊图案的洛丽塔连衣裙',
      isInInventory: true,
    ),
    Clothing(
      id: '11',
      name: '珍珠洛丽塔',
      price: 1488.00,
      imageUrl: 'https://via.placeholder.com/300x400?text=Pearl Lolita',
      description: '优雅珍珠装饰的洛丽塔连衣裙',
      isInInventory: true,
    ),
    Clothing(
      id: '12',
      name: '格子洛丽塔',
      price: 1188.00,
      imageUrl: 'https://via.placeholder.com/300x400?text=Plaid Lolita',
      description: '经典格子图案的洛丽塔套装',
      isInInventory: true,
    ),
  ];

  // 计算总库存价值
  double get totalInventoryValue {
    return inventoryItems.fold(0.0, (sum, item) => sum + item.price);
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
                    '我的洛丽塔库存',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      '总价值: ¥${totalInventoryValue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '共 ${inventoryItems.length} 件洛丽塔',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.7,
                ),
                itemCount: inventoryItems.length,
                itemBuilder: (context, index) {
                  final item = inventoryItems[index];
                  return Card(
                    elevation: 4.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            // 使用颜色和文本作为图片占位符，避免网络请求
                            color: Colors.green[100],
                            child: Center(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                item.formattedPrice,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.pink,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                item.description!, 
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
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
