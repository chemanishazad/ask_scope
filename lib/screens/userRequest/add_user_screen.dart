import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/provider/home/home_provider.dart'; // Your provider

class AddUserScreen extends ConsumerStatefulWidget {
  const AddUserScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends ConsumerState<AddUserScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final asyncUsers = ref.watch(tlAssignedUserDropdownProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.themeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search user...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),

            // 👥 User List
            Expanded(
              child: asyncUsers.when(
                data: (users) {
                  final filtered = users.where((user) {
                    final name = (user['name'] ?? '').toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final user = filtered[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(user['name']?[0] ?? '?'),
                        ),
                        title: Text(user['name'] ?? 'No Name'),
                        subtitle: Text(user['email'] ?? 'No Email'),
                        onTap: () {
                          Navigator.pushNamed(context, '/userQueryHistory',
                              arguments: user);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
