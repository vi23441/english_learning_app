import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: user == null
          ? const Center(child: Text('Please log in to view your profile.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                          ? NetworkImage(user.profileImageUrl!) as ImageProvider
                          : const AssetImage('assets/images/default_avatar.png'), // Placeholder image
                      child: user.profileImageUrl == null || user.profileImageUrl!.isEmpty
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildProfileInfoRow('Name', user.name),
                  _buildProfileInfoRow('Email', user.email),
                  _buildProfileInfoRow('Role', user.role.name.toUpperCase()),
                  if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                    _buildProfileInfoRow('Phone', user.phoneNumber!),
                  _buildProfileInfoRow('Member Since', DateFormat('MMM dd, yyyy').format(user.createdAt)),
                  if (user.lastLoginAt != null)
                    _buildProfileInfoRow('Last Login', DateFormat('MMM dd, yyyy HH:mm').format(user.lastLoginAt!)),
                  
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to edit profile screen (will be implemented in Settings)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit profile functionality is in Settings.')),
                      );
                    },
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}