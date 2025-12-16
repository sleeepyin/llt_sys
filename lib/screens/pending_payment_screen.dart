import 'package:flutter/material.dart';
import '../models/clothing.dart';
import '../main.dart';
import 'dart:io';

class PendingPaymentScreen extends StatefulWidget {
  final AppState appState;
  
  const PendingPaymentScreen({Key? key, required this.appState}) : super(key: key);

  @override
  State<PendingPaymentScreen> createState() => _PendingPaymentScreenState();
}

class _PendingPaymentScreenState extends State<PendingPaymentScreen> {
  List<Clothing> selectedItems = [];
  Clothing? selectedItemForZoom;
  
  // 排序相关状态
  bool isPriceSortedAsc = true; // 默认按价格升序排序
  // 筛选相关状态
  String? selectedShop; // 当前选中的店铺，null表示显示所有店铺
  
  // 计算总尾款金额
  double get totalRemainingPayment {
    return widget.appState.pendingItems.fold(0.0, (sum, item) => sum + item.remainingPayment);
  }
  
  // 切换卡片选择状态
  void _toggleItemSelection(Clothing item) {
    setState(() {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems.add(item);
      }
    });
  }
  
  // 获取所有唯一的店铺名称
  List<String> _getUniqueShops() {
    Set<String> shopSet = <String>{};
    for (var item in widget.appState.pendingItems) {
      if (item.shopName != null && item.shopName!.isNotEmpty) {
        shopSet.add(item.shopName!);
      }
    }
    return shopSet.toList()..sort();
  }

  // 获取筛选并按店铺分组、按价格排序后的商品列表
  Map<String, List<Clothing>> _getGroupedItems() {
    List<Clothing> filteredItems = List.from(widget.appState.pendingItems);
    
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

  // 打开放大查看对话框
  void _openZoomDialog(Clothing item) {
    setState(() {
      selectedItemForZoom = item;
    });
    
    final Future<bool?> dialogFuture = showDialog(
      context: context, 
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  height: 350,
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(item.description!),
                      const SizedBox(height: 12.0),
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
                          fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '截止日期: ${item.formattedDeadline}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              // 显示日期选择器
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: item.paymentDeadline ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                // 更新截止日期
                                widget.appState.updatePendingDeadline(item, picked);
                                // 关闭当前对话框并重新打开以显示更新后的日期
                                Navigator.pop(context);
                                _openZoomDialog(item);
                              }
                            },
                            child: const Text('编辑'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // 转移到库存界面
                              widget.appState.moveToInventory(item);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('已全款'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // 撤销到想要界面
                              widget.appState.moveToWishlist(item);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text('撤销到想要'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // 删除卡片
                              widget.appState.removeFromPending(item);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('删除'),
                          ),
                        ],
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
    
    dialogFuture.then((value) {
      setState(() {
        selectedItemForZoom = null;
      });
    });
  }

  // 显示提醒设置对话框
  void _showReminderSettingsDialog(Clothing item) {
    showDialog(
      context: context,
      builder: (context) {
        bool reminderEnabled = item.reminderEnabled;
        String reminderType = item.reminderType ?? 'notification';
        
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
                      '提醒设置',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20.0),
                    SwitchListTile(
                      title: const Text('启用提醒', style: TextStyle(color: Colors.black)),
                      value: reminderEnabled,
                      onChanged: (value) {
                        reminderEnabled = value;
                        Navigator.pop(context);
                        // 重新打开对话框以更新UI
                        _showReminderSettingsDialog(item);
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
                          reminderType = value!;
                          Navigator.pop(context);
                          // 重新打开对话框以更新UI
                          _showReminderSettingsDialog(item);
                        },
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        // 更新商品的提醒设置
                        widget.appState.updatePendingReminder(item, reminderEnabled, reminderType);
                        
                        Navigator.pop(context);
                        
                        // 显示成功提示
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('提醒设置已更新', style: TextStyle(color: Colors.black))),
                        );
                      },
                      child: const Text('保存设置', style: TextStyle(color: Colors.black)),
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

  // 显示编辑对话框
  void _showEditDialog(Clothing item) {
    TextEditingController depositController = TextEditingController(text: item.depositPaid?.toString() ?? '0');
    TextEditingController priceController = TextEditingController(text: item.price?.toString() ?? '0');
    TextEditingController notesController = TextEditingController(text: item.notes ?? '');
    DateTime? paymentDeadline = item.paymentDeadline;

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
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
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
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20.0),
                        TextField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            labelText: '全款价格',
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          controller: depositController,
                          decoration: const InputDecoration(
                            labelText: '已付定金',
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
                              initialDate: paymentDeadline ?? DateTime.now().add(const Duration(days: 15)),
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
                        TextField(
                          controller: notesController,
                          decoration: const InputDecoration(
                            labelText: '备注信息',
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          maxLines: 3,
                          style: const TextStyle(color: Colors.black),
                        ),
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
                                  double price = double.tryParse(priceController.text) ?? 0.0;
                                  double depositPaid = double.tryParse(depositController.text) ?? 0.0;
                                  if (price <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('请输入有效的全款价格', style: TextStyle(color: Colors.black))),
                                    );
                                    return;
                                  }
                                  if (depositPaid < 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('请输入有效的定金金额', style: TextStyle(color: Colors.black))),
                                    );
                                    return;
                                  }
                                  if (depositPaid > price) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('定金金额不能大于全款价格', style: TextStyle(color: Colors.black))),
                                    );
                                    return;
                                  }
                                  
                                  // 使用AppState的方法更新商品信息
                                  widget.appState.updatePendingItem(item, price, depositPaid, paymentDeadline, notes: notesController.text);
                                  
                                  // 关闭对话框
                                  Navigator.pop(context);
                                  
                                  // 显示更新成功提示
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('商品信息已更新'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: const Text('保存', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('撤销操作'),
                                  content: const Text('确定要将该商品撤回至愿望单吗？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // 关闭确认对话框
                                      },
                                      child: const Text('取消'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // 执行撤销操作
                                        widget.appState.moveToWishlist(item);
                                        Navigator.pop(context); // 关闭确认对话框
                                        Navigator.pop(context); // 关闭编辑对话框
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('已撤回至愿望单')),
                                        );
                                      },
                                      child: const Text('确定', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                            ),
                            child: const Text('忘记自己还没补尾款喵', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '待补尾款',
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
            // 选择操作栏
            if (selectedItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Text('已选择 ${selectedItems.length} 件商品'),
                    const SizedBox(width: 16.0),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedItems.clear();
                        });
                      },
                      child: const Text('取消选择'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // 批量转移到库存
                        for (var item in selectedItems) {
                          widget.appState.moveToInventory(item);
                        }
                        setState(() {
                          selectedItems.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('批量已全款'),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: () {
                        // 批量撤销到想要
                        for (var item in selectedItems) {
                          widget.appState.moveToWishlist(item);
                        }
                        setState(() {
                          selectedItems.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('批量撤销'),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: () {
                        // 批量删除
                        for (var item in selectedItems) {
                          widget.appState.removeFromPending(item);
                        }
                        setState(() {
                          selectedItems.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('批量删除'),
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
                      // 店铺商品列表 - 使用Column代替嵌套ListView
                      Column(
                        children: List.generate(
                          shopItems.length,
                          (itemIndex) {
                            final item = shopItems[itemIndex];
                            final remainingDays = item.remainingDays;
                            final isSelected = selectedItems.contains(item);
                            
                            return GestureDetector(
                              onTap: () {
                                if (selectedItems.isNotEmpty) {
                                  // 如果已经在选择模式，点击切换选择状态
                                  _toggleItemSelection(item);
                                } else {
                                  // 弹出编辑界面
                                  _showEditDialog(item);
                                }
                              },
                              onLongPress: () {
                                // 长按进入选择模式
                                _toggleItemSelection(item);
                              },
                              child: Card(
                                elevation: isSelected ? 10.0 : 6.0,
                                margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                color: isSelected ? Colors.yellow[50] : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Stack(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // 选择复选框
                                          if (selectedItems.isNotEmpty)
                                            Checkbox(
                                              value: isSelected,
                                              onChanged: (value) {
                                                _toggleItemSelection(item);
                                              },
                                            ),
                                          // 图片区域（放大尺寸）
                                          SizedBox(
                                            width: 140,
                                            child: Column(
                                              children: [
                                                SizedBox(height: 8.0), // 添加间距使图片往下移
                                                SizedBox(
                                                  width: 140,
                                                  height: 180,
                                                  child: (item.imageUrl != null && (item.imageUrl!.startsWith('http://') || item.imageUrl!.startsWith('https://')))
                                                      ? Image.network(
                                                          item.imageUrl!,
                                                          fit: BoxFit.cover,
                                                          width: double.infinity,
                                                          height: double.infinity,
                                                        )
                                                      : (item.imageUrl != null && File(item.imageUrl!).existsSync())
                                                          ? Image.file(
                                                              File(item.imageUrl!),
                                                              fit: BoxFit.cover,
                                                              width: double.infinity,
                                                              height: double.infinity,
                                                            )
                                                          : Container(
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
                                                const SizedBox(height: 8.0),
                                                // 剩余天数（移至图片下方）
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12.0,
                                                    vertical: 8.0,
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
                                                      fontSize: 16,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // 信息区域（调整布局）
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        item.name,
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4.0),
                                                      Text(
                                                        item.description!,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10.0),
                                                      // 使用Column代替Row来避免价格信息溢出
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            '总价: ${item.formattedPrice}',
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 2.0),
                                                          Text(
                                                            '定金: ${item.formattedDepositPaid}',
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4.0),
                                                          Text(
                                                            '尾款: ${item.formattedRemainingPayment}',
                                                            style: const TextStyle(
                                                              fontSize: 18,
                                                              color: Colors.red,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 10.0),
                                                      // 截止日期
                                                      Text(
                                                        '截止日期: ${item.formattedDeadline}',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.grey,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                  // 补齐尾款按钮（与剩余天数保持水平对齐）
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text('补齐尾款'),
                                                          content: const Text('确定要将该商品移至小橱窗吗？'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                              child: const Text('取消'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                widget.appState.moveToInventory(item);
                                                                Navigator.pop(context);
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  const SnackBar(content: Text('已移至小橱窗')),
                                                                );
                                                              },
                                                              child: const Text('确定', style: TextStyle(color: Colors.green)),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.pink,
                                                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                                      minimumSize: Size.zero,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      '补齐尾款！',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // 删除按钮
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.close, color: Colors.red),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('删除服装'),
                                                content: const Text('确定要删除这件服装吗？'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('取消'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      widget.appState.removeFromPending(item);
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('删除'),
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
                              ), // Card结束
                            ); // GestureDetector结束
                          }, // List.generate的children结束
                        ), // List.generate结束
                      ), // Column结束
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
