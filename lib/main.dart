import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'screens/wishlist_screen.dart';
import 'screens/pending_payment_screen.dart';
import 'screens/inventory_screen.dart';
import 'models/clothing.dart';
import 'services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// 全局状态管理
class AppState extends ChangeNotifier {
  List<Clothing> wishlistItems = [];
  List<Clothing> pendingItems = [];
  List<Clothing> inventoryItems = [];
  final NotificationService notificationService = NotificationService();

  // 初始化通知服务
  Future<void> initializeNotificationService() async {
    await notificationService.initialize();
  }

  // 添加到想要列表
  void addToWishlist(Clothing item) {
    wishlistItems.add(item);
    notifyListeners();
    saveData();
  }

  // 从想要列表移除
  void removeFromWishlist(Clothing item) {
    wishlistItems.removeWhere((i) => i.id == item.id);
    notifyListeners();
    saveData();
  }

  // 更新想要列表中的商品信息
  void updateWishlistItem(String itemId, Map<String, dynamic> updates) {
    int index = wishlistItems.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      Clothing item = wishlistItems[index];
      
      // 更新商品属性
      if (updates.containsKey('name')) item.name = updates['name'];
      if (updates.containsKey('price')) item.price = updates['price'];
      if (updates.containsKey('size')) item.size = updates['size'];
      if (updates.containsKey('description')) item.description = updates['description'];
      if (updates.containsKey('imageUrl')) item.imageUrl = updates['imageUrl'];
      if (updates.containsKey('shopName')) item.shopName = updates['shopName'];
      if (updates.containsKey('notes')) item.notes = updates['notes'];
      
      wishlistItems[index] = item;
      notifyListeners();
      saveData();
    }
  }

  // 从想要转移到待付列表（已付定金）
  void moveToPendingFromWishlist(Clothing item, double depositPaid, DateTime? paymentDeadline, bool reminderEnabled, String? reminderType) {
    // 从想要列表移除
    removeFromWishlist(item);
    
    // 创建新的待付项目
    Clothing pendingItem = Clothing(
      id: item.id,
      name: item.name,
      price: item.price,
      imageUrl: item.imageUrl,
      description: item.description,
      size: item.size,
      shopName: item.shopName,
      paymentDeadline: paymentDeadline ?? DateTime.now().add(const Duration(days: 15)), // 默认15天内付尾款
      depositPaid: depositPaid,
      reminderEnabled: reminderEnabled,
      reminderType: reminderType,
    );
    
    pendingItems.add(pendingItem);
    
    // 如果启用了提醒，设置提醒
    if (reminderEnabled && paymentDeadline != null) {
      // 在截止日期前7天和前1天发送提醒
      final reminderDays = [7, 1];
      for (int days in reminderDays) {
        final reminderDate = paymentDeadline!.subtract(Duration(days: days));
        if (reminderDate.isAfter(DateTime.now())) {
          notificationService.scheduleNotification(pendingItem, reminderDate);
        }
    
    notifyListeners();
    saveData();
  }
    }
    
    notifyListeners();
    saveData();
  }

  // 从想要转移到库存列表（已全款）
  void moveToInventoryFromWishlist(Clothing item) {
    // 从想要列表移除
    removeFromWishlist(item);
    
    // 创建新的库存项目
    Clothing inventoryItem = Clothing(
      id: item.id,
      name: item.name,
      price: item.price,
      imageUrl: item.imageUrl,
      description: item.description,
      size: item.size,
      shopName: item.shopName, // 修复：传递店铺名称
      isInInventory: true,
      notes: item.notes, // 修复：传递备注信息
    );
    
    inventoryItems.add(inventoryItem);
    notifyListeners();
    saveData();
  }

  // 从待付移到库存
  void moveToInventory(Clothing item) {
    pendingItems.remove(item);
    // 创建新的库存项目，确保所有属性都被保留
    Clothing inventoryItem = Clothing(
      id: item.id,
      name: item.name,
      price: item.price,
      imageUrl: item.imageUrl, // 确保图片URL被传递
      description: item.description,
      size: item.size,
      shopName: item.shopName,
      isInInventory: true,
      notes: item.notes,
    );
    inventoryItems.add(inventoryItem);
    notifyListeners();
    saveData();
  }

  // 从待付移到想要
  void moveToWishlist(Clothing item) {
    pendingItems.remove(item);
    item.depositPaid = null;
    item.paymentDeadline = null;
    item.isInInventory = false;
    wishlistItems.add(item);
    notifyListeners();
    saveData();
  }

  // 从库存移到待付
  void moveToPending(Clothing item) {
    inventoryItems.remove(item);
    item.isInInventory = false;
    item.depositPaid = item.price * 0.2; // 默认20%定金
    item.paymentDeadline = DateTime.now().add(const Duration(days: 30));
    pendingItems.add(item);
    notifyListeners();
    saveData();
  }



  // 从待付移除
  void removeFromPending(Clothing item) {
    pendingItems.remove(item);
    notifyListeners();
    saveData();
  }

  // 从库存移除
  void removeFromInventory(Clothing item) {
    inventoryItems.remove(item);
    notifyListeners();
    saveData();
  }

  // 更新待付项目的截止日期
  void updatePendingDeadline(Clothing item, DateTime newDeadline) {
    item.paymentDeadline = newDeadline;
    notifyListeners();
    saveData();
  }

  // 更新待付项目的信息（价格、定金、截止日期）
  void updatePendingItem(Clothing item, double newPrice, double newDepositPaid, DateTime? newDeadline, {String? notes}) {
    // 从待付列表中移除旧项目
    pendingItems.removeWhere((i) => i.id == item.id);
    
    // 创建新的项目，使用新的价格、定金和截止日期
    Clothing updatedItem = Clothing(
      id: item.id,
      name: item.name,
      price: newPrice,
      imageUrl: item.imageUrl,
      description: item.description,
      size: item.size,
      shopName: item.shopName,
      paymentDeadline: newDeadline,
      depositPaid: newDepositPaid,
      reminderEnabled: item.reminderEnabled,
      reminderType: item.reminderType,
      notes: notes ?? item.notes,
    );
    
    // 添加到待付列表
    pendingItems.add(updatedItem);
    notifyListeners();
    saveData();
  }
  
  // 更新待付项目的提醒设置
  void updatePendingReminder(Clothing item, bool reminderEnabled, String reminderType) {
    // 从待付列表中移除旧项目
    pendingItems.removeWhere((i) => i.id == item.id);
    
    // 创建新的项目，使用更新后的提醒设置
    Clothing updatedItem = Clothing(
      id: item.id,
      name: item.name,
      price: item.price,
      imageUrl: item.imageUrl,
      description: item.description,
      size: item.size,
      shopName: item.shopName,
      paymentDeadline: item.paymentDeadline,
      depositPaid: item.depositPaid,
      reminderEnabled: reminderEnabled,
      reminderType: reminderType,
    );
    
    // 添加到待付列表
    pendingItems.add(updatedItem);
    
    // 取消旧的提醒
    notificationService.cancelNotification(item);
    
    // 如果启用了提醒，设置新的提醒
    if (reminderEnabled && item.paymentDeadline != null) {
      // 在截止日期前7天和前1天发送提醒
      final reminderDays = [7, 1];
      for (int days in reminderDays) {
        final reminderDate = item.paymentDeadline!.subtract(Duration(days: days));
        if (reminderDate.isAfter(DateTime.now())) {
          notificationService.scheduleNotification(updatedItem, reminderDate);
        }
      }
    }
    
    notifyListeners();
  }

  // 保存数据到本地存储
  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 保存愿望单数据
      final wishlistJson = wishlistItems.map((item) => item.toJson()).toList();
      await prefs.setString('wishlistItems', json.encode(wishlistJson));
      
      // 保存待付列表数据
      final pendingJson = pendingItems.map((item) => item.toJson()).toList();
      await prefs.setString('pendingItems', json.encode(pendingJson));
      
      // 保存库存数据
      final inventoryJson = inventoryItems.map((item) => item.toJson()).toList();
      await prefs.setString('inventoryItems', json.encode(inventoryJson));
      
      print('数据保存成功');
    } catch (e) {
      print('保存数据失败: $e');
    }
  }

  // 从本地存储加载数据
  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载愿望单数据
      final wishlistJson = prefs.getString('wishlistItems');
      if (wishlistJson != null) {
        final wishlistData = json.decode(wishlistJson) as List<dynamic>;
        wishlistItems = wishlistData.map((item) => Clothing.fromJson(item)).toList();
      }
      
      // 加载待付列表数据
      final pendingJson = prefs.getString('pendingItems');
      if (pendingJson != null) {
        final pendingData = json.decode(pendingJson) as List<dynamic>;
        pendingItems = pendingData.map((item) => Clothing.fromJson(item)).toList();
      }
      
      // 加载库存数据
      final inventoryJson = prefs.getString('inventoryItems');
      if (inventoryJson != null) {
        final inventoryData = json.decode(inventoryJson) as List<dynamic>;
        inventoryItems = inventoryData.map((item) => Clothing.fromJson(item)).toList();
      }
      
      notifyListeners();
      print('数据加载成功');
    } catch (e) {
      print('加载数据失败: $e');
    }
  }

}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LolitaPaymentSystemApp());
}

class LolitaPaymentSystemApp extends StatelessWidget {
  const LolitaPaymentSystemApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final appState = AppState();
        appState.loadData(); // 加载持久化的数据
        return appState;
      },
      child: MaterialApp(
        title: '喵的小橱窗',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          fontFamily: 'Roboto',
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // 初始化通知服务
    final appState = Provider.of<AppState>(context, listen: false);
    appState.initializeNotificationService();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SvgPicture.asset(
            'assets/images/cat_icon.svg',
            height: 40,
            width: 40,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: [
          WishlistScreen(appState: appState),
          PendingPaymentScreen(appState: appState),
          InventoryScreen(appState: appState),
        ].elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/wish_icon.svg', // 自定义愿望单图标
              height: 24,
              width: 24,
            ),
            label: '愿望单',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/pending_icon.svg', // 自定义期待中图标
              height: 24,
              width: 24,
            ),
            label: '期待中',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/inventory_icon.svg', // 自定义小橱窗图标
              height: 24,
              width: 24,
            ),
            label: '小橱窗',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}


