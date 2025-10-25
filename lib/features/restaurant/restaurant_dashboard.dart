import 'package:flutter/material.dart';
import 'package:fwm_sys/core/constants/colors.dart';
import 'package:fwm_sys/core/services/api_service.dart'; // Needed for data fetching
import 'package:fwm_sys/features/restaurant/donate_food_screen.dart';
import 'package:fwm_sys/features/restaurant/food_status_screen.dart';
import 'package:fwm_sys/features/restaurant/history_analytics_screen.dart';
import 'package:fwm_sys/features/common/profile_screen.dart'; // Profile navigation
import 'package:fwm_sys/features/auth/login_screen.dart'; // Logout navigation

class RestaurantDashboard extends StatelessWidget {
  const RestaurantDashboard({super.key});

  // Function to handle Logout
  Future<void> _handleLogout(BuildContext context) async {
    await ApiService().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.cloud_upload, color: AppColors.primary, size: 28),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Grand Hotel',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                ),
                Text(
                  'Hotel Dashboard',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Badge(
              label: Text('2'),
              child: Icon(
                Icons.notifications_none,
                color: AppColors.textPrimary,
              ),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textPrimary),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Welcome back, John Smith!\nReady to make a difference today?',
                  style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
                ),
              ),

              // === STATS CARDS ===
              _buildStatCard(
                title: 'Food Donated',
                value: '4',
                subtitle: '+4 this month',
                icon: Icons.ssid_chart,
                color: AppColors.success,
              ),
              _buildStatCard(
                title: 'Orders Accepted',
                value: '2',
                subtitle: '50% acceptance rate',
                icon: Icons.list_alt,
                color: AppColors.info,
              ),
              _buildStatCard(
                title: 'Meals Served',
                value: '40+',
                subtitle: 'People helped',
                icon: Icons.people_alt,
                color: const Color(0xFF9C27B0), // Purple for visibility
              ),

              const SizedBox(height: 24),
              // === QUICK ACTION CARDS ===
              _buildActionCard(
                context,
                title: 'Upload Food',
                subtitle:
                    'Post available food for donation to NGOs in your area',
                icon: Icons.cloud_upload_outlined,
                iconColor: AppColors.success,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DonateFoodScreen(),
                    ),
                  );
                },
              ),
              _buildActionCard(
                context,
                title: 'View Status',
                subtitle:
                    'Track the status of your donations and pickup requests',
                icon: Icons.list_alt_outlined,
                iconColor: AppColors.info,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FoodStatusScreen(),
                    ),
                  );
                },
              ),
              _buildActionCard(
                context,
                title: 'History & Reports',
                subtitle: 'View analytics and donation history with insights',
                icon: Icons.bar_chart_outlined,
                iconColor: const Color(0xFF9C27B0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryAnalyticsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              // === RECENT ACTIVITY ===
              const Text(
                'Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildRecentActivityItem(
                'Buffet Leftovers - Vegetarian',
                '50 servings',
                'Pending',
              ),
              _buildRecentActivityItem(
                'Fresh Bread and Pastries',
                '30 items',
                'Pending',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: color)),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 30),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
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

  Widget _buildRecentActivityItem(
    String title,
    String servings,
    String status,
  ) {
    Color statusColor = AppColors.warning;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.background,
            ),
            child: const Icon(Icons.fastfood, color: AppColors.textSecondary),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            servings,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
