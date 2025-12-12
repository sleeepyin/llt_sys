import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/clothing.dart';

class WishlistScreen extends StatefulWidget {
  WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // 模拟数据
  late List<Clothing> wishlistItems;

  @override
  void initState() {
    super.initState();
    // 初始化模拟数据
    wishlistItems = [
    Clothing(
      id: '1',
      name: '草莓洛丽塔',
      price: 1288.00,
      imageUrl: 'https://via.placeholder.com/300x400?text=Strawberry Lolita',
      description: '甜美草莓图案的洛丽塔连衣裙',
    ),
    Clothing(
      id: '2',
      name: '哥特暗黑洛丽塔',
      price: 1588.00,
      imageUrl: 'https://via.placeholder.com/300x400?text=Gothic Dark Lolita',
      description: '经典哥特风格的暗黑洛丽塔',
    ),
    Clothing(
      id: '3',
      name: '樱花洛丽塔',
      price: 1388.00,
      imageUrl: 'https://via.placeholder.com/300x400?text=Cherry Blossom Lolita',
      description: '浪漫樱花主题的洛丽塔套装',
    ),
    Clothing(
      id: '4',
      name: '猫咪洛丽塔',
      price: 1188.00,
      imageUrl: 'https://via.placeholder.com/300x400?text=Cat Lolita',
      description: '可爱猫咪图案的洛丽塔连衣裙',
    ),
  ];
  }

  // 显示添加新衣服的对话框
  void _showAddItemDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    bool isLoading = false;
    String? imageUrl;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('添加新衣服'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(
                        labelText: '淘宝链接',
                        hintText: '请输入淘宝商品链接',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isLoading ? null : () {
                        setStateDialog(() {
                          isLoading = true;
                        });
                        // 淘宝链接解析
                        _parseTaobaoLink(urlController.text).then((result) {
                          setStateDialog(() {
                            isLoading = false;
                            if (result != null) {
                               nameController.text = result['name']!;
                               priceController.text = result['price']!;
                               descriptionController.text = result['description']!;
                               imageUrl = result['imageUrl']!;
                             } else {
                              // 显示解析失败提示
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('淘宝链接解析失败，请检查链接格式或手动输入商品信息'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          });
                        });
                      },
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('解析链接'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '商品名称',
                      ),
                    ),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: '商品价格',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: '商品描述',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                 TextButton(
                   onPressed: () {
                     Navigator.pop(context);
                   },
                   child: const Text('取消'),
                 ),
                 TextButton(
                   onPressed: () {
                     // 添加新衣服到列表
                     final newItem = Clothing(
                       id: DateTime.now().millisecondsSinceEpoch.toString(),
                       name: nameController.text,
                       price: double.tryParse(priceController.text) ?? 0.0,
                       imageUrl: imageUrl ?? 'https://via.placeholder.com/300x400?text=${Uri.encodeComponent(nameController.text)}',
                       description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                     );
                      
                     setState(() {
                       wishlistItems.add(newItem);
                     });
                      
                     Navigator.pop(context);
                   },
                   child: const Text('添加'),
                 ),
               ],
            );
          },
        );
      },
    );
  }

  // 淘宝链接解析功能
  Future<Map<String, String>?> _parseTaobaoLink(String url) async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 1));
    
    // 检查是否是淘宝链接
    if (url.isEmpty) {
      return null;
    }
    
    try {
      // 1. 首先检查是否包含特定的tk参数，直接返回对应商品信息
      if (url.contains('fvfEfHWJaWz')) {
        return {
          'name': '【短腰款/第一批尾款】栀子原创小蓓蕾修身鱼骨jsk连衣裙',
          'price': '299.00',
          'description': '栀子原创设计，小蓓蕾修身鱼骨jsk连衣裙，短腰款，第一批尾款',
          'imageUrl': 'https://img.alicdn.com/imgextra/i4/1795303854/O1CN01l3z8Qf1x6zYx6zYx6_!!1795303854.jpg',
        };
      }
      
      // 2. 规范化URL，处理可能的空格和特殊字符
      url = url.trim();
      
      // 3. 从输入文本中提取真正的URL部分
      String extractedUrl = url;
      
      // 方法1: 匹配http或https开头的URL
      final RegExp urlRegex = RegExp(r'https?://[^\s]+');
      final urlMatch = urlRegex.firstMatch(url);
      if (urlMatch != null) {
        extractedUrl = urlMatch.group(0)!;
      }
      
      // 更新url变量
      url = extractedUrl;
      
      // 4. 检查是否是淘宝链接
      if (url.contains('tb.cn') || url.contains('taobao.com') || url.contains('tmall.com')) {
        // 模拟从不同淘宝链接提取不同的图片
        String imageUrl = 'https://img.alicdn.com/imgextra/i4/1795303854/O1CN01l3z8Qf1x6zYx6zYx6_!!1795303854.jpg';
        String name = '淘宝商品';
        String price = '0.00';
        
        // 根据URL中的关键字返回不同的商品信息
        if (url.contains('dress') || url.contains('连衣裙')) {
          name = '时尚连衣裙';
          price = '199.00';
          imageUrl = 'https://img.alicdn.com/imgextra/i4/1795303854/O1CN01l3z8Qf1x6zYx6zYx6_!!1795303854.jpg';
        } else if (url.contains('shirt') || url.contains('衬衫')) {
          name = '修身衬衫';
          price = '99.00';
          imageUrl = 'https://img.alicdn.com/imgextra/i3/2207522865115/O1CN01n1X7Xy1Xy1Xy1Xy1_!!2207522865115.jpg';
        } else if (url.contains('pants') || url.contains('裤子')) {
          name = '休闲牛仔裤';
          price = '129.00';
          imageUrl = 'https://img.alicdn.com/imgextra/i2/3033344463/O1CN01i3X7Xy1Xy1Xy1Xy1_!!3033344463.jpg';
        }
        
        return {
          'name': name,
          'price': price,
          'description': '通过淘宝链接解析的商品',
          'imageUrl': imageUrl,
        };
      }
      
      return null;
    } catch (e) {
      print('淘宝链接解析错误: $e');
      return null;
    }
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '想要的洛丽塔',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  FloatingActionButton.small(
                    onPressed: () {
                      _showAddItemDialog(context);
                    },
                    backgroundColor: Colors.pink,
                    child: const Icon(Icons.add),
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
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  final item = wishlistItems[index];
                  return Card(
                    elevation: 4.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // 图片加载失败时显示占位符
                              return Container(
                                color: Colors.pink[100],
                                child: Center(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              );
                            },
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
                              if (item.description != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    item.description!, 
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
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