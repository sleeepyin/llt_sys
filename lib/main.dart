import 'package:flutter/material.dart';
import 'screens/wishlist_screen.dart';
import 'screens/pending_payment_screen.dart';
import 'screens/inventory_screen.dart';

void main() {
  runApp(const LolitaPaymentSystemApp());
}

class LolitaPaymentSystemApp extends StatelessWidget {
  const LolitaPaymentSystemApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '洛丽塔尾款管理系统',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
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

  static final List<Widget> _widgetOptions = <Widget>[
    WishlistScreen(),
    PendingPaymentScreen(),
    InventoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('洛丽塔尾款管理系统'),
        centerTitle: true,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '想要',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: '待付',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: '库存',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        onTap: _onItemTapped,
      ),
    );
  }
}
