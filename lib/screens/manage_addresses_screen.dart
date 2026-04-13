import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import 'add_address_map_screen.dart';

class ManageAddressesScreen extends StatefulWidget {
  const ManageAddressesScreen({super.key});

  @override
  State<ManageAddressesScreen> createState() => _ManageAddressesScreenState();
}

class _ManageAddressesScreenState extends State<ManageAddressesScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _deleteAddress(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to remove this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Direct firestore call inside manage screen for simplicity
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_firestoreService.currentUserId)
          .collection('addresses')
          .doc(docId)
          .delete();
    }
  }

  Future<void> _makeDefault(String docId) async {
    final batch = FirebaseFirestore.instance.batch();
    
    // Clear all
    final existing = await FirebaseFirestore.instance
        .collection('users')
        .doc(_firestoreService.currentUserId)
        .collection('addresses')
        .where('isDefault', isEqualTo: true)
        .get();
        
    for (var doc in existing.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    
    // Set new default
    final targetDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(_firestoreService.currentUserId)
        .collection('addresses')
        .doc(docId);
        
    batch.update(targetDoc, {'isDefault': true});
    
    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primary location updated!')),
      );
    }
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'office':
        return Icons.business_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Addresses'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getUserAddresses(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          final docs = snapshot.data?.docs ?? [];
          
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_rounded, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text(
                    'No saved addresses yet',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                  )
                ],
              ),
            );
          }

          // Sort so defaults are at the top
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aDefault = aData['isDefault'] ?? false;
            final bDefault = bData['isDefault'] ?? false;
            if (aDefault && !bDefault) return -1;
            if (!aDefault && bDefault) return 1;
            return 0;
          });

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              final label = data['label'] ?? 'Other';
              final address = data['address'] ?? '';
              final landmark = data['landmark'] ?? '';
              final isDefault = data['isDefault'] ?? false;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isDefault
                      ? Border.all(color: AppTheme.primaryGreen, width: 2)
                      : Border.all(color: AppTheme.dividerColor.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDefault ? AppTheme.primaryGreen.withValues(alpha: 0.1) : AppTheme.inputBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForLabel(label),
                        color: isDefault ? AppTheme.primaryGreen : AppTheme.textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              if (isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'PRIMARY',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                )
                              ]
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address,
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (landmark.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Landmark: $landmark',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
                      onSelected: (val) {
                        if (val == 'default') _makeDefault(doc.id);
                        if (val == 'delete') _deleteAddress(doc.id);
                      },
                      itemBuilder: (context) => [
                        if (!isDefault)
                          const PopupMenuItem(
                            value: 'default',
                            child: Text('Set as Primary'),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Address', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAddressMapScreen()),
          );
        },
      ),
    );
  }
}
