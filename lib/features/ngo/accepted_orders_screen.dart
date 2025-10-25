import 'package:flutter/material.dart';
import 'package:fwm_sys/core/constants/colors.dart';
import 'package:fwm_sys/core/services/api_service.dart';
import 'package:fwm_sys/models/donation_model.dart';

class AcceptedOrdersScreen extends StatefulWidget {
  const AcceptedOrdersScreen({super.key});

  @override
  State<AcceptedOrdersScreen> createState() => _AcceptedOrdersScreenState();
}

class _AcceptedOrdersScreenState extends State<AcceptedOrdersScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Donation>> _acceptedDonations;

  @override
  void initState() {
    super.initState();
    _fetchAcceptedDonations();
  }

  void _fetchAcceptedDonations() {
    setState(() {
      _acceptedDonations = _apiService.getAcceptedDonations();
    });
  }

  void _markInTransit(String donationId) async {
    try {
      final response = await _apiService.markInTransit(donationId);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response['message'])));
        _fetchAcceptedDonations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
      }
    }
  }

  void _markAsPickedUp(String donationId) async {
    try {
      final response = await _apiService.completePickup(donationId);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response['message'])));
        _fetchAcceptedDonations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as picked up: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Accepted Orders')),
      body: FutureBuilder<List<Donation>>(
        future: _acceptedDonations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No accepted orders yet.'));
          } else {
            // Filter into states: Active (Accepted/In Transit) and Completed (Picked Up)
            final activePickups = snapshot.data!
                .where(
                  (d) => d.status == 'accepted' || d.status == 'in_transit',
                )
                .toList();
            final completed = snapshot.data!
                .where((d) => d.status == 'picked_up')
                .toList();

            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    tabs: [
                      Tab(text: 'Active Pickups'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildDonationList(activePickups),
                        _buildDonationList(completed),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDonationList(List<Donation> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No orders in this status.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final donation = list[index];
        bool isPending = donation.status == 'accepted';
        bool isInTransit = donation.status == 'in_transit';

        return AcceptedDonationCard(
          donation: donation,
          isPending: isPending,
          isInTransit: isInTransit,
          onPickedUp: () => _markAsPickedUp(donation.id),
          onInTransit: () => _markInTransit(donation.id),
        );
      },
    );
  }
}

class AcceptedDonationCard extends StatelessWidget {
  final Donation donation;
  final bool isPending;
  final bool isInTransit;
  final VoidCallback onPickedUp;
  final VoidCallback onInTransit;

  const AcceptedDonationCard({
    super.key,
    required this.donation,
    required this.isPending,
    required this.isInTransit,
    required this.onPickedUp,
    required this.onInTransit,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    if (donation.status == 'picked_up') {
      statusColor = AppColors.success;
      statusText = 'PICKED UP';
    } else if (isInTransit) {
      statusColor = Colors.purple; // New color for In Transit
      statusText = 'IN TRANSIT';
    } else {
      // status == 'accepted'
      statusColor = AppColors.info;
      statusText = 'ACCEPTED';
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
              donation.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text('Hotel: ${donation.restaurantName ?? 'N/A'}'),
            Text('Quantity: ${donation.quantity} servings'),
            Text('Location: ${donation.pickupLocation ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text(
              'Status: $statusText',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (isPending) // Status: Accepted
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: onInTransit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.info,
                    ),
                    child: const Text('Mark In Transit'),
                  ),
                ],
              )
            else if (isInTransit) // Status: In Transit
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: onPickedUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    'Mark as Picked Up',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            else
              Text(
                'Completed on: ${donation.postedAt?.substring(0, 10) ?? 'N/A'}',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
