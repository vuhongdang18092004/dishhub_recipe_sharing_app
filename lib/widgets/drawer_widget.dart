import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color.fromRGBO(240, 144, 48, 1)),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              context.go('/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add Recipe'),
            onTap: () {
              Navigator.pop(context);
              context.go('/add');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
          const Divider(),
          SwitchListTile(
            secondary: Icon(
              MyApp.themeNotifier.value == ThemeMode.dark
                  ? Icons.nightlight_round 
                  : Icons.wb_sunny,
              color: MyApp.themeNotifier.value == ThemeMode.dark
                  ? Colors.yellow
                  : Colors.orange,
            ),
            title: const Text('Dark Mode'),
            value: MyApp.themeNotifier.value == ThemeMode.dark,
            onChanged: (val) {
              MyApp.themeNotifier.value = val
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
          ),
        ],
      ),
    );
  }
}
