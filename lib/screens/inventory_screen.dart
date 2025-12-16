import 'dart:io';
import 'package:flutter/material.dart';
import '../models/clothing.dart';
import '../main.dart';

class InventoryScreen extends StatefulWidget {
  final AppState appState;
  
  const InventoryScreen({Key? key, required this.appState}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // 选中的卡片
  List<Clothing> selectedItems = [];
  
  // 排序相关状态
  bool isPriceSortedAsc = true; // 默认按价格升序排序
  // 筛选相关状态
  String? selectedShop; // 当前选中的店铺，null表示显示所有店铺
  
  // 计算总库存价值
  double get totalInventoryValue {
    return widget.appState.inventoryItems.fold(0.0, (sum, item) => sum + item.price);
  }
  
  // 检查是否选中
  bool isSelected(Clothing item) => selectedItems.contains(item);
  
  // 切换选中状态
  void _toggleItemSelection(Clothing item) {
    setState(() {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems.add(item);
      }
    });
  }
  
  // 取消所有选择
  void _clearSelection() {
    setState(() {
      selectedItems.clear();
    });
  }
  
  // 打开放大查看对话框
  void _openZoomDialog(Clothing item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          width: MediaQuery.of(context).size.width * 0.8, // 减小对话框宽度
          height: MediaQuery.of(context).size.height * 0.7, // 减小对话框高度
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 商品图片
                Container(
                  height: 250, // 减小对话框高度
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: item.imageUrl != null
                      ? (item.imageUrl!.startsWith('http://') || item.imageUrl!.startsWith('https://'))
                          ? Image.network(
                              item.imageUrl!, // 显示商品图片
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            )
                          : Image.file(
                              File(item.imageUrl!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            )
                      : Center(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // 改为白色字体
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                ),
                // 商品信息
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // 保持黑色字体，因为背景是白色
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      if (item.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            item.description!,
                            style: const TextStyle(fontSize: 16, color: Colors.black), // 保持黑色字体，因为背景是白色
                          ),
                        ),
                      if (item.size != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '尺码: ${item.size}',
                            style: const TextStyle(fontSize: 16, color: Colors.black), // 保持黑色字体，因为背景是白色
                          ),
                        ),
                      const SizedBox(height: 24.0),
                      
                      // 操作按钮（改为两行）
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.appState.moveToPending(item);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(177, 255, 105, 180),
                                  foregroundColor: Colors.white, // 确保按钮文本为白色
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text('忘记没补尾款了喵🐱', style: TextStyle(color: Colors.white)), // 改为白色字体
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.appState.removeFromInventory(item);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white, // 确保按钮文本为白色
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text('我再也不想看到这件了喵🐱', style: TextStyle(color: Colors.white)), // 改为白色字体
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('关闭'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // 显示批量操作对话框
  void _showBatchActionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('批量操作 (${selectedItems.length} 件商品)'),
        content: const Text('请选择要执行的操作'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              for (var item in selectedItems) {
                widget.appState.moveToPending(item);
              }
              _clearSelection();
            },
            child: const Text('全部转移到待付'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              for (var item in selectedItems) {
                widget.appState.removeFromInventory(item);
              }
              _clearSelection();
            },
            child: const Text('全部删除'),
          ),
        ],
      ),
    );
  }

  // 获取所有唯一的店铺名称
  List<String> _getUniqueShops() {
    Set<String> shopSet = <String>{};
    for (var item in widget.appState.inventoryItems) {
      if (item.shopName != null && item.shopName!.isNotEmpty) {
        shopSet.add(item.shopName!);
      }
    }
    return shopSet.toList()..sort();
  }

  // 获取筛选并按店铺分组、按价格排序后的商品列表
  Map<String, List<Clothing>> _getGroupedItems() {
    List<Clothing> filteredItems = List.from(widget.appState.inventoryItems);
    
    // 应用店铺筛选
    if (selectedShop != null) {
      filteredItems = filteredItems.where((item) => item.shopName == selectedShop).toList();
    }
    
    // 按店铺分组
    Map<String, List<Clothing>> groupedItems = {};
    for (var item in filteredItems) {
      String shopName = item.shopName ?? '未知店铺';
      if (!groupedItems.containsKey(shopName)) {
        groupedItems[shopName] = [];
      }
      groupedItems[shopName]!.add(item);
    }
    
    // 对每个店铺内的商品按价格排序
    groupedItems.forEach((shopName, items) {
      items.sort((a, b) {
        if (isPriceSortedAsc) {
          return a.price.compareTo(b.price);
        } else {
          return b.price.compareTo(a.price);
        }
      });
    });
    
    return groupedItems;
  }
  
  // 获取所有店铺名称（用于分组显示）
  List<String> _getShopNames() {
    Map<String, List<Clothing>> groupedItems = _getGroupedItems();
    return groupedItems.keys.toList()..sort();
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '喵的小橱窗',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
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
                              // 添加显示所有店铺的选项
                              const DropdownMenuItem(
                                value: null,
                                child: Text('所有店铺'),
                              ),
                              // 动态生成店铺列表
                              ..._getUniqueShops().map<DropdownMenuItem<String?>>((String shop) {
                                return DropdownMenuItem<String?>(
                                  value: shop,
                                  child: Text(shop),
                                );
                              }).toList(),
                            ],
                          ),
                        ],
                      ),
                    ],
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
                    '共 ${widget.appState.inventoryItems.length} 件洛丽塔',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // 如果有选中的卡片，显示操作栏
            if (selectedItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.green[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('已选择 ${selectedItems.length} 件商品'),
                    Row(
                      children: [
                        TextButton(
                          onPressed: _clearSelection,
                          child: const Text('取消选择'),
                        ),
                        ElevatedButton(
                          onPressed: _showBatchActionDialog,
                          child: const Text('确定操作'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _getShopNames().length,
                itemBuilder: (context, shopIndex) {
                  String shopName = _getShopNames()[shopIndex];
                  List<Clothing> shopItems = _getGroupedItems()[shopName]!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 店铺名称标题
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          shopName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                      // 店铺商品网格
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
                          final item = shopItems[itemIndex];
                          final bool isSelectedItem = isSelected(item);
                          
                          return GestureDetector(
                            onTap: () {
                              if (selectedItems.isNotEmpty) {
                                // 如果已经在选择模式，点击切换选择状态
                                _toggleItemSelection(item);
                              } else {
                                // 否则放大查看卡片
                                _openZoomDialog(item);
                              }
                            },
                            onLongPress: () {
                              // 长按进入选择模式
                              _toggleItemSelection(item);
                            },
                            child: Card(
                              elevation: isSelectedItem ? 8.0 : 4.0,
                              color: isSelectedItem ? Colors.green[50] : null,
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          color: Colors.green[100],
                                          child: item.imageUrl != null
                                            ? (item.imageUrl!.startsWith('http://') || item.imageUrl!.startsWith('https://'))
                                                ? Image.network(
                                                    item.imageUrl!, // 显示商品图片
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Center(
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
                                                      );
                                                    },
                                                  )
                                                : Image.file(
                                                    File(item.imageUrl!),
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Center(
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
                                                      );
                                                    },
                                                  )
                                            : Center(
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
                                            if (item.description != null)
                                              Text(
                                                item.description!, 
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            if (item.size != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4.0),
                                                child: Text(
                                                  '尺码: ${item.size}', 
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // 选中标记
                                  if (isSelectedItem)
                                    Positioned(
                                      top: 8.0,
                                      right: 8.0,
                                      child: Container(
                                        width: 24.0,
                                        height: 24.0,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16.0,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),
                    ],
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
