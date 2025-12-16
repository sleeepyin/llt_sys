import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../models/clothing.dart';
import '../main.dart';

class WishlistScreen extends StatefulWidget {
  final AppState appState;
  
  WishlistScreen({Key? key, required this.appState}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // 选中的卡片
  List<Clothing> selectedItems = [];
  
  // 排序相关状态
  bool isPriceSortedAsc = true; // 默认按价格升序排序
  // 筛选相关状态
  String? selectedShop; // 当前选中的店铺，null表示显示所有店铺
  
  // 检查是否选中
  bool isSelected(Clothing item) => selectedItems.contains(item);
  
  // 获取所有唯一的店铺名称
  List<String> _getUniqueShops() {
    Set<String> shopSet = <String>{};
    for (var item in widget.appState.wishlistItems) {
      if (item.shopName != null && item.shopName!.isNotEmpty) {
        shopSet.add(item.shopName!);
      }
    }
    return shopSet.toList()..sort();
  }
  
  // 获取筛选并按店铺分组、按价格排序后的商品列表
  Map<String, List<Clothing>> _getGroupedItems() {
    List<Clothing> filteredItems = List.from(widget.appState.wishlistItems);
    
    // 应用店铺筛选
    if (selectedShop != null) {
      filteredItems = filteredItems.where((item) => item.shopName == selectedShop).toList();
    }
    
    // 按店铺分组
    Map<String, List<Clothing>> grouped = {};
    for (var item in filteredItems) {
      String shopName = item.shopName ?? '未分类';
      if (!grouped.containsKey(shopName)) {
        grouped[shopName] = [];
      }
      grouped[shopName]!.add(item);
    }
    
    // 对每个店铺的商品按价格排序
    grouped.forEach((shopName, items) {
      items.sort((a, b) => isPriceSortedAsc ? a.price.compareTo(b.price) : b.price.compareTo(a.price));
    });
    
    return grouped;
  }
  
  // 获取所有店铺名称列表（用于排序）
  List<String> _getShopNames() {
    Map<String, List<Clothing>> groupedItems = _getGroupedItems();
    List<String> shopNames = groupedItems.keys.toList();
    shopNames.sort(); // 按店铺名称排序
    return shopNames;
  }
  
  // 切换选中状态
  void toggleSelection(Clothing item) {
    setState(() {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems.add(item);
      }
    });
  }
  
  // 清空选中状态
  void clearSelection() {
    setState(() {
      selectedItems.clear();
    });
  }
  
  // 显示放大的卡片
  void showEnlargedCard(Clothing item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 400,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 图片展示区域
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey[200],
                      ),
                      child: item.imageUrl != null
                          ? Image.file(
                              File(item.imageUrl!),
                              fit: BoxFit.contain,
                            )
                          : _buildImagePlaceholder(),
                    ),
                    const SizedBox(height: 20.0),
                    // 商品信息
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '¥${item.price}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.size != null && item.size!.isNotEmpty) ...[
                      const SizedBox(height: 4.0),
                      Text(
                        '尺码: ${item.size}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                    if (item.shopName != null && item.shopName!.isNotEmpty) ...[
                      const SizedBox(height: 4.0),
                      Text(
                        '店铺: ${item.shopName}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                    if (item.description != null && item.description!.isNotEmpty) ...[
                      const SizedBox(height: 12.0),
                      Text(
                        item.description!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                    const SizedBox(height: 20.0),
                    // 操作按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showEditItemDialog(item);
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text('编辑商品信息', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showDepositDialog(item);
                            },
                            icon: const Icon(Icons.payment, color: Colors.white),
                            label: const Text('补', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // 移至已拥有列表
                              widget.appState.moveToInventoryFromWishlist(item);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已移至已拥有列表', style: TextStyle(color: Colors.black))),
                              );
                            },
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text('有', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // 删除商品
                              widget.appState.removeFromWishlist(item);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已删除商品', style: TextStyle(color: Colors.black))),
                              );
                            },
                            icon: const Icon(Icons.delete, color: Colors.white),
                            label: const Text('删', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  // 显示编辑商品信息对话框
  void _showEditItemDialog(Clothing item) {
    TextEditingController nameController = TextEditingController(text: item.name);
    TextEditingController priceController = TextEditingController(text: item.price.toString());
    TextEditingController descriptionController = TextEditingController(text: item.description ?? '');
    TextEditingController sizeController = TextEditingController(text: item.size ?? '');
    TextEditingController shopController = TextEditingController(text: item.shopName ?? '');
    String? selectedImagePath = item.imageUrl;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 400,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '编辑商品信息',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '商品名称',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: '价格',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: '描述',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      maxLines: 3,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: sizeController,
                      decoration: const InputDecoration(
                        labelText: '尺码',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: shopController,
                      decoration: const InputDecoration(
                        labelText: '店铺名称',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton.icon(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: false,
                        );
                        
                        if (result != null) {
                          PlatformFile file = result.files.first;
                          setState(() {
                            selectedImagePath = file.path;
                          });
                        }
                      },
                      icon: const Icon(Icons.upload_file, color: Colors.white),
                      label: Text(
                        selectedImagePath != null ? '更换图片' : '上传本地图片',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                      ),
                    ),
                    if (selectedImagePath != null) ...[
                      const SizedBox(height: 8.0),
                      Text(
                        selectedImagePath!.split('/').last,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('取消', style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // 验证输入
                              if (nameController.text.isEmpty || priceController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('请填写商品名称和价格', style: TextStyle(color: Colors.black))),
                                );
                                return;
                              }
                              
                              double price = double.tryParse(priceController.text) ?? 0.0;
                              if (price <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('请输入有效的价格', style: TextStyle(color: Colors.black))),
                                );
                                return;
                              }
                              
                              // 更新商品信息
                              Clothing updatedItem = Clothing(
                                id: item.id,
                                name: nameController.text,
                                price: price,
                                size: sizeController.text.isNotEmpty ? sizeController.text : null,
                                description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                                imageUrl: selectedImagePath,
                                shopName: shopController.text.isNotEmpty ? shopController.text : null,
                              );
                              
                              // 更新愿望清单
                              widget.appState.updateWishlistItem(
                                updatedItem.id,
                                {
                                  'name': updatedItem.name,
                                  'price': updatedItem.price,
                                  'size': updatedItem.size,
                                  'description': updatedItem.description,
                                  'imageUrl': updatedItem.imageUrl,
                                  'shopName': updatedItem.shopName,
                                },
                              );
                              
                              // 关闭对话框
                              Navigator.pop(context);
                              
                              // 显示成功提示
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('商品信息已更新', style: TextStyle(color: Colors.black))),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                            ),
                            child: const Text('保存', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  // 构建图片占位符
  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: const Center(
        child: Icon(
          Icons.image,
          size: 100,
          color: Colors.grey,
        ),
      ),
    );
  }
  
  // 显示添加新商品对话框
  void _showAddItemDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController sizeController = TextEditingController();
    TextEditingController shopController = TextEditingController();
    String? selectedImagePath;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 400,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '添加新商品',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '商品名称',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: '价格',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: '描述',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      maxLines: 3,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: sizeController,
                      decoration: const InputDecoration(
                        labelText: '尺码',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: shopController,
                      decoration: const InputDecoration(
                        labelText: '店铺名称',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton.icon(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: false,
                        );
                        
                        if (result != null) {
                          PlatformFile file = result.files.first;
                          setState(() {
                            selectedImagePath = file.path;
                          });
                        }
                      },
                      icon: const Icon(Icons.upload_file, color: Colors.white),
                      label: Text(
                        selectedImagePath != null ? '更换图片' : '上传本地图片',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                      ),
                    ),
                    if (selectedImagePath != null) ...[
                      const SizedBox(height: 8.0),
                      Text(
                        selectedImagePath!.split('/').last,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('取消', style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // 验证输入
                              if (nameController.text.isEmpty || priceController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('请填写商品名称和价格', style: TextStyle(color: Colors.black))),
                                );
                                return;
                              }
                              
                              double price = double.tryParse(priceController.text) ?? 0.0;
                              if (price <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('请输入有效的价格', style: TextStyle(color: Colors.black))),
                                );
                                return;
                              }
                              
                              // 创建新商品
                              Clothing newItem = Clothing(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: nameController.text,
                                price: price,
                                size: sizeController.text.isNotEmpty ? sizeController.text : null,
                                description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                                imageUrl: selectedImagePath,
                                shopName: shopController.text.isNotEmpty ? shopController.text : null,
                              );
                              
                              // 添加到愿望清单
                              widget.appState.addToWishlist(newItem);
                              
                              // 关闭对话框
                              Navigator.pop(context);
                              
                              // 显示成功提示
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('商品已添加到愿望清单', style: TextStyle(color: Colors.black))),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                            ),
                            child: const Text('添加', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  // 显示定金信息输入对话框
  void _showDepositDialog(Clothing item) {
    TextEditingController depositController = TextEditingController();
    DateTime? paymentDeadline;
    bool reminderEnabled = false;
    String? reminderType = 'notification';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 400,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '支付定金',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      '商品名称: ${item.name}',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: depositController,
                      decoration: InputDecoration(
                        labelText: '定金金额',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 15)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            paymentDeadline = selectedDate;
                          });
                        }
                      },
                      child: Text(
                        paymentDeadline != null
                            ? '付款截止日期: ${paymentDeadline!.toLocal().toString().split(' ')[0]}'
                            : '选择付款截止日期',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SwitchListTile(
                      title: const Text('启用提醒'),
                      value: reminderEnabled,
                      onChanged: (value) {
                        setState(() {
                          reminderEnabled = value;
                        });
                      },
                    ),
                    if (reminderEnabled) ...[
                      const SizedBox(height: 16.0),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: '提醒类型',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                        value: reminderType,
                        items: const [
                          DropdownMenuItem(
                            value: 'notification',
                            child: Text('消息提醒', style: TextStyle(color: Colors.black)),
                          ),
                          DropdownMenuItem(
                            value: 'alarm',
                            child: Text('闹钟提醒', style: TextStyle(color: Colors.black)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            reminderType = value;
                          });
                        },
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('取消', style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // 验证输入
                              double depositPaid = double.tryParse(depositController.text) ?? 0.0;
                              if (depositPaid <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('请输入有效的定金金额', style: TextStyle(color: Colors.black))),
                                );
                                return;
                              }
                              
                              // 关闭对话框
                              Navigator.pop(context); // 关闭定金信息对话框
                              Navigator.pop(context); // 关闭放大卡片对话框
                              
                              // 移至待付款列表
                              widget.appState.moveToPendingFromWishlist(
                                item,
                                depositPaid,
                                paymentDeadline ?? DateTime.now().add(const Duration(days: 15)),
                                reminderEnabled,
                                reminderType,
                              );
                              
                              // 显示成功提示
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已移至待付款列表', style: TextStyle(color: Colors.black))),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            child: const Text('确定', style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  // 显示批量操作对话框
  void showActionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 400,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '选择操作 (${selectedItems.length} 件商品)',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 移至待付款列表（批量操作，使用默认值）
                        for (var item in selectedItems) {
                          // 批量操作使用默认值：0定金，15天后截止，禁用提醒
                          widget.appState.moveToPendingFromWishlist(
                            item,
                            0.0, // 定金金额
                            DateTime.now().add(const Duration(days: 15)), // 付款截止日期
                            false, // 不启用提醒
                            null, // 无提醒类型
                          );
                        }
                        Navigator.pop(context);
                        clearSelection();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('已将${selectedItems.length}件商品移至待付款列表')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('移至待付款列表'),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 移至已拥有列表
                        for (var item in selectedItems) {
                          widget.appState.moveToInventoryFromWishlist(item);
                        }
                        Navigator.pop(context);
                        clearSelection();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('已将${selectedItems.length}件商品移至已拥有列表')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('移至已拥有列表'),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 删除选中商品
                        for (var item in selectedItems) {
                          widget.appState.removeFromWishlist(item);
                        }
                        Navigator.pop(context);
                        clearSelection();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('已删除${selectedItems.length}件商品')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('删除选中商品', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('取消'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和操作按钮
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '咪的心愿单',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16.0),
                    Row(
                      children: [
                        // 按价格排序按钮
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              isPriceSortedAsc = !isPriceSortedAsc;
                            });
                          },
                          icon: Icon(
                            isPriceSortedAsc ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 16,
                          ),
                          label: const Text('价格排序'),
                        ),
                        // 按店铺筛选下拉菜单
                        DropdownButton<String?>(
                          value: selectedShop,
                          hint: const Text('店铺筛选'),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedShop = newValue;
                            });
                          },
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('全部店铺'),
                            ),
                            ..._getUniqueShops().map<DropdownMenuItem<String?>>((String shop) {
                              return DropdownMenuItem<String?>(
                                value: shop,
                                child: Text(shop),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // 选中状态提示栏
            if (selectedItems.isNotEmpty) ...[
              Container(
                color: Colors.pink[100],
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('已选择 ${selectedItems.length} 件商品'),
                    Row(
                      children: [
                        TextButton(
                          onPressed: clearSelection,
                          child: const Text('取消选择'),
                        ),
                        ElevatedButton(
                          onPressed: showActionDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                          ),
                          child: const Text('批量操作', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            // 商品列表
            Expanded(
              child: ListView.builder(
                itemCount: _getShopNames().length,
                itemBuilder: (context, index) {
                  String shopName = _getShopNames()[index];
                  List<Clothing> shopItems = _getGroupedItems()[shopName]!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          shopName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: shopItems.length,
                        itemBuilder: (context, itemIndex) {
                          Clothing item = shopItems[itemIndex];
                          bool selected = isSelected(item);
                          
                          return GestureDetector(
                            onTap: () {
                              showEnlargedCard(item);
                            },
                            onLongPress: () {
                              toggleSelection(item);
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(
                                  color: selected ? Colors.pink : Colors.transparent,
                                  width: 3.0,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 商品图片
                                        item.imageUrl != null
                                            ? Container(
                                                height: 150,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: FileImage(File(item.imageUrl!)),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              )
                                            : _buildImagePlaceholder(),
                                        const SizedBox(height: 8.0),
                                        // 商品名称
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        // 商品价格
                                        Text(
                                          '¥${item.price}',
                                          style: const TextStyle(
                                            color: Colors.pink,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        // 商品尺码
                                        if (item.size != null) ...[
                                          Text(
                                            item.size!,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (selected) ...[
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          color: Colors.pink,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // 底部中间新增服装按钮
      floatingActionButton: ElevatedButton.icon(
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          '新增服装',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}