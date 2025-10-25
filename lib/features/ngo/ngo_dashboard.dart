import 'package:flutter/material.dart';
import 'package:fwm_sys/core/constants/colors.dart';
import 'package:fwm_sys/core/services/api_service.dart';
import 'package:fwm_sys/features/ngo/view_food_posts_screen.dart';
import 'package:fwm_sys/features/ngo/accepted_orders_screen.dart';
import 'package:fwm_sys/features/ngo/collection_summary_screen.dart';
import 'package:fwm_sys/features/common/notifications_screen.dart';
import 'package:fwm_sys/features/common/profile_screen.dart';
import 'package:fwm_sys/features/auth/login_screen.dart';

class NGODashboard extends StatelessWidget {
  const NGODashboard({super.key});

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
            const Icon(Icons.category_sharp, color: AppColors.accent, size: 28),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Food Aid Foundation',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                ),
                Text(
                  'NGO Dashboard',
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
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
                  'Welcome, Sarah Johnson!\nFind and collect food donations from local restaurants',
                  style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
                ),
              ),

              // === STATS CARDS ===
              _buildNgoStatCard(
                title: 'Available Posts',
                value: '2',
                subtitle: 'Ready to accept',
                icon: Icons.search,
                color: AppColors.warning,
              ),
              _buildNgoStatCard(
                title: 'Pending Pickups',
                value: '1',
                subtitle: 'Awaiting collection',
                icon: Icons.inventory_2_outlined,
                color: AppColors.info,
              ),
              _buildNgoStatCard(
                title: 'Food Collected',
                value: '1',
                subtitle: 'Successfully picked',
                icon: Icons.ssid_chart,
                color: AppColors.success,
              ),
              _buildNgoStatCard(
                title: 'Meals Distributed',
                value: '40+',
                subtitle: 'People helped',
                icon: Icons.people_alt,
                color: const Color(0xFF9C27B0),
              ),

              const SizedBox(height: 24),
              // === QUICK ACTION CARDS ===
              _buildNgoActionCard(
                context,
                title: 'View Food Posts',
                subtitle:
                    'Browse available food donations from restaurants and hotels',
                icon: Icons.search_outlined,
                iconColor: AppColors.warning,
                badgeText: '2 new donations available',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewFoodPostsScreen(),
                    ),
                  );
                },
              ),
              _buildNgoActionCard(
                context,
                title: 'My Accepted Orders',
                subtitle:
                    'View and manage your accepted food donations for pickup',
                icon: Icons.inventory_2,
                iconColor: AppColors.info,
                badgeText: '1 pending pickup',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AcceptedOrdersScreen(),
                    ),
                  );
                },
              ),
              _buildNgoActionCard(
                context,
                title: 'Collection Summary',
                subtitle: 'View your impact, analytics and collection history',
                icon: Icons.bar_chart_outlined,
                iconColor: const Color(0xFF9C27B0),
                badgeText: '',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CollectionSummaryScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              // === ORGANIZATION DETAILS (Placeholder for Profile data) ===
              const Text(
                'Organization Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildNgoDetailCard(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNgoStatCard({
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

  Widget _buildNgoActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String badgeText,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: iconColor, size: 30),
                    ),
                    if (badgeText.isNotEmpty)
                      Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 12,
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
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
        ),
      ),
    );
  }

  Widget _buildNgoDetailCard() {
    return Card(
      elevation: 0,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Registration Number', 'REG789012'),
            _buildDetailRow('Volunteers', '25 active volunteers'),
            _buildDetailRow('Contact', '+1234567891'),
            _buildDetailRow('Address', '456 Community Avenue'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
