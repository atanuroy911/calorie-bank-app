import 'dart:io';

void main() {
  final directories = [
    'lib/models',
    'lib/providers',
    'lib/utils',
    'lib/screens/profile_setup',
    'lib/screens/settings',
  ];

  for (final dir in directories) {
    Directory(dir).createSync(recursive: true);
    print('Created: $dir');
  }

  print('All directories created successfully!');
}
