// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:fwm_sys/core/constants/colors.dart';
import 'package:fwm_sys/core/constants/strings.dart';
import 'package:fwm_sys/core/services/api_service.dart';
import 'package:fwm_sys/features/auth/login_screen.dart';
import 'package:fwm_sys/widgets/custom_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _addressController = TextEditingController();
  final _licenseController = TextEditingController();
  final _registrationNoController = TextEditingController();
  final _volunteersController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _obscurePassword = true;
  String _selectedUserType = 'restaurant';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _licenseController.dispose();
    _registrationNoController.dispose();
    _volunteersController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        // --- FINAL DATA CLEANUP BEFORE API CALL ---
        // Clean the optional fields: convert empty strings to null for database safety
        final contact = _contactController.text.trim().isEmpty
            ? null
            : _contactController.text.trim();
        final address = _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim();

        // 1. Restaurant Specific Fields (Check if user selected restaurant)
        final license =
            _selectedUserType == 'restaurant' &&
                _licenseController.text.trim().isNotEmpty
            ? _licenseController.text.trim()
            : null;

        // 2. NGO Specific Fields (Check if user selected ngo)
        final registrationNo =
            _selectedUserType == 'ngo' &&
                _registrationNoController.text.trim().isNotEmpty
            ? _registrationNoController.text.trim()
            : null;

        // Safely parse or default volunteer count to null
        int? volunteersCount;
        if (_selectedUserType == 'ngo' &&
            _volunteersController.text.trim().isNotEmpty) {
          try {
            volunteersCount = int.parse(_volunteersController.text.trim());
          } catch (e) {
            // Display specific parsing error and stop execution
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: Volunteer count must be a number.'),
              ),
            );
            setState(() => _isLoading = false);
            return;
          }
        }
        // --- END DATA CLEANUP ---

        final response = await _apiService.registerUser(
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedUserType,
          name: _nameController.text,

          contact: contact, // Cleaned
          address: address, // Cleaned
          license: license, // Cleaned
          registrationNo: registrationNo, // Cleaned
          volunteersCount: volunteersCount, // Cleaned & Parsed
        );

        if (response['message'] ==
            'Registration successful! Awaiting admin approval.') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response['message'])));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          // Display the error message returned from the Node.js server
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['message'] ??
                    'Registration failed due to server error.',
              ),
            ),
          );
        }
      } catch (e) {
        // Final fallback for network/timeout errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Critical Failure: Could not finalize registration. Please check network.',
            ),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  AppStrings.signupTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: UserTypeCard(
                        type: 'restaurant',
                        label: AppStrings.restaurant,
                        icon: Icons.restaurant,
                        isSelected: _selectedUserType == 'restaurant',
                        onTap: () {
                          setState(() {
                            _selectedUserType = 'restaurant';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: UserTypeCard(
                        type: 'ngo',
                        label: AppStrings.ngo,
                        icon: Icons.volunteer_activism,
                        isSelected: _selectedUserType == 'ngo',
                        onTap: () {
                          setState(() {
                            _selectedUserType = 'ngo';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _nameController,
                  label: _selectedUserType == 'restaurant'
                      ? 'Hotel/Hall Name'
                      : 'NGO/NSS Name',
                  icon: Icons.business,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: AppStrings.email,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _contactController,
                  label: 'Contact Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 16),
                if (_selectedUserType == 'restaurant') ...[
                  _buildTextField(
                    controller: _licenseController,
                    label: 'License/ID Proof Number',
                    icon: Icons.description,
                  ),
                ],
                if (_selectedUserType == 'ngo') ...[
                  _buildTextField(
                    controller: _registrationNoController,
                    label: 'Registration Certificate No.',
                    icon: Icons.receipt,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _volunteersController,
                    label: 'No. of Volunteers',
                    icon: Icons.people,
                    keyboardType: TextInputType.number,
                  ),
                ],
                const SizedBox(height: 16),
                _buildPasswordTextField(),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          AppStrings.signup,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        AppStrings.login,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: AppStrings.password,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty || value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }
}
