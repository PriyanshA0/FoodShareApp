import 'package:flutter/material.dart';
import 'package:fwm_sys/core/constants/colors.dart';
import 'package:fwm_sys/core/services/api_service.dart';
import 'package:fwm_sys/models/donation_model.dart';

class FoodStatusScreen extends StatefulWidget {
  const FoodStatusScreen({super.key});

  @override
  State<FoodStatusScreen> createState() => _FoodStatusScreenState();
}

class _FoodStatusScreenState extends State<FoodStatusScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Donation>> _myDonations;

  @override
  void initState() {
    super.initState();
    _myDonations = _apiService.getMyDonations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Donation Status')),
      body: FutureBuilder<List<Donation>>(
        future: _myDonations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No donations posted yet.'));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final donation = snapshot.data![index];
                return DonationStatusCard(
                  title: donation.title,
                  quantity: donation.quantity.toString(),
                  status: donation.status,
                  ngoName: donation.ngoName,
                );
              },
            );
          }
        },
      ),
    );
  }
}

class DonationStatusCard extends StatelessWidget {
  final String title;
  final String quantity;
  final String status;
  final String? ngoName;

  const DonationStatusCard({
    super.key,
    required this.title,
    required this.quantity,
    required this.status,
    this.ngoName,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    String subtitleText = 'Quantity: $quantity servings';

    switch (status) {
      case 'accepted':
        statusColor = AppColors.info;
        statusText = 'ACCEPTED';
        subtitleText = 'Claimed by: ${ngoName ?? 'Pending details'}';
        break;
      case 'in_transit': // ADD THIS CASE
        statusColor = Colors.purple; // Use a distinct color for in-transit
        statusText = 'IN TRANSIT';
        subtitleText = 'Pickup in progress by: ${ngoName ?? 'N/A'}';
        break;
      case 'picked_up':
        statusColor = AppColors.success;
        statusText = 'COMPLETED';
        subtitleText = 'Picked up by: ${ngoName ?? 'N/A'}';
        break;
      default:
        statusColor = AppColors.warning;
        statusText = 'PENDING';
        break;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitleText,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.circle, size: 10, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  'Status: $statusText',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
