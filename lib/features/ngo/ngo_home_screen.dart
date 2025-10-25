import 'package:flutter/material.dart';
import 'package:fwm_sys/core/constants/colors.dart';
import 'package:fwm_sys/features/ngo/ngo_dashboard.dart';
import 'package:fwm_sys/features/ngo/view_food_posts_screen.dart';
import 'package:fwm_sys/features/ngo/accepted_orders_screen.dart';
import 'package:fwm_sys/features/ngo/collection_summary_screen.dart';

class NGOHomeScreen extends StatefulWidget {
  const NGOHomeScreen({super.key});

  @override
  State<NGOHomeScreen> createState() => _NGOHomeScreenState();
}

class _NGOHomeScreenState extends State<NGOHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const NGODashboard(),
    const ViewFoodPostsScreen(),
    const AcceptedOrdersScreen(),
    const CollectionSummaryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'New Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Accepted',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'Summary'),
        ],
      ),
    );
  }
}
