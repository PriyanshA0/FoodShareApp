import 'package:flutter/material.dart';
import 'package:fwm_sys/core/services/api_service.dart';
import 'package:fwm_sys/models/donation_model.dart';
import 'package:fwm_sys/widgets/custom_widgets.dart';

class ViewFoodPostsScreen extends StatefulWidget {
  const ViewFoodPostsScreen({super.key});

  @override
  State<ViewFoodPostsScreen> createState() => _ViewFoodPostsScreenState();
}

class _ViewFoodPostsScreenState extends State<ViewFoodPostsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Donation>> _donations;

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  void _fetchDonations() {
    setState(() {
      _donations = _apiService.getAllDonations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Food Posts')),
      body: FutureBuilder<List<Donation>>(
        future: _donations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No food posts available.'));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final donation = snapshot.data![index];
                return DonationCard(
                  title: donation.title,
                  quantity: '${donation.quantity} servings',
                  expiry: donation.expiryTime,
                  imageUrl: donation.imageUrl ?? '',
                  status: donation.status,
                  // FIX: Added the missing restaurantName parameter. Assuming DonationCard in custom_widgets.dart supports it.
                  restaurantName: donation.restaurantName ?? 'Unknown Hotel',
                  onAccept: () {
                    _acceptOrder(donation.id);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  void _acceptOrder(String donationId) async {
    try {
      final response = await _apiService.acceptDonation(donationId);

      if (mounted) {
        // Severity 2 fix
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response['message'])));
        _fetchDonations(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        // Severity 2 fix
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to accept order: $e')));
      }
    }
  }
}
