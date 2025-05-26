import 'package:flutter/material.dart';
import 'package:passora/views/vault/credential_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Map<String, String>> mockCredentials = const [
    {'title': 'Gmail', 'username': 'john.doe@gmail.com'},
    {'title': 'GitHub', 'username': 'johndoe123'},
    {'title': 'Netflix', 'username': 'j.doe'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockCredentials.length,
        itemBuilder: (context, index) {
          final item = mockCredentials[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(item['title']!),
              subtitle: Text(item['username']!),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  // TODO: Implement delete
                },
              ),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CredentialPage(existingCredential: item),
                  ),
                );

                if (result != null) {
                  // TODO: Update existing entry
                  debugPrint('Credential Updated: $result');
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CredentialPage()),
          );

          if (result != null) {
            // TODO: Add to vault list
            debugPrint('Credential Saved: $result');
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
