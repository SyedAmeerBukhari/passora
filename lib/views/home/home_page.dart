import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:passora/views/vault/credential_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../models/credential.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    developer.log('HomePage build called', name: 'HomePage');
    return FutureBuilder<String?>(
      future: AuthService.getCurrentUsername(),
      builder: (context, snapshot) {
        final username = snapshot.data ?? '';
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: Text('Vault${username.isNotEmpty ? ' - $username' : ''}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  developer.log('Logout button pressed', name: 'HomePage');
                  await AuthService.logout();
                  if (context.mounted) {
                    developer.log(
                      'Navigating to /login after logout',
                      name: 'HomePage',
                    );
                    context.go('/login');
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  context.go('/settings');
                },
              ),
            ],
          ),
          body: ValueListenableBuilder(
            valueListenable: StorageService.credentialBox.listenable(),
            builder: (context, Box<Credential> box, _) {
              final credentials = box.values.toList();
              developer.log(
                'Loaded ${credentials.length} credentials',
                name: 'HomePage',
              );
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: credentials.length,
                itemBuilder: (context, index) {
                  final item = credentials[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: Text(item.title),
                      subtitle: Text(item.username),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          developer.log(
                            'Deleting credential: ${item.title}',
                            name: 'HomePage',
                          );
                          await item.delete();
                        },
                      ),
                      onTap: () async {
                        developer.log(
                          'Editing credential: ${item.title}',
                          name: 'HomePage',
                        );
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => CredentialPage(
                                  existingCredential: {
                                    'title': item.title,
                                    'username': item.username,
                                    'password': item.password,
                                    'note': item.note ?? '',
                                  },
                                ),
                          ),
                        );
                        if (result != null && result is Map<String, String>) {
                          developer.log(
                            'Credential edited: ${item.title}',
                            name: 'HomePage',
                          );
                          item.title = result['title'] ?? item.title;
                          item.username = result['username'] ?? item.username;
                          item.password = result['password'] ?? item.password;
                          item.note = result['note'];
                          await item.save();
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'generatePassword',
                icon: const Icon(Icons.password),
                label: const Text('Generate Password'),
                onPressed: () async {
                  final password = _generateRandomPassword();
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Generated Password'),
                          content: SelectableText(
                            password,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          actions: [
                            TextButton.icon(
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Password copied to clipboard!',
                                    ),
                                  ),
                                );
                                // Copy to clipboard
                                // ignore: deprecated_member_use
                                Clipboard.setData(
                                  ClipboardData(text: password),
                                );
                              },
                            ),
                            TextButton(
                              child: const Text('Close'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                  );
                },
                backgroundColor: Colors.teal,
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'addCredential',
                onPressed: () async {
                  developer.log(
                    'Add credential button pressed',
                    name: 'HomePage',
                  );
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CredentialPage()),
                  );
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        );
      },
    );
  }

  String _generateRandomPassword({int length = 16}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()-_=+[]{}|;:,.<>?';
    final rand = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(chars[(rand + i * 31) % chars.length]);
    }
    return buffer.toString();
  }
}
