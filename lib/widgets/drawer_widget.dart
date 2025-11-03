import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../main.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(240, 144, 48, 1),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: user?.photo != null
                            ? NetworkImage(user!.photo!)
                            : const AssetImage('assets/images/default_avatar.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? 'Khách',
                        style: const TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/home', extra: user);
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
                leading: const Icon(Icons.search),
                title: const Text('Search Recipes'),
                onTap: () {
                  Navigator.pop(context);
                  if (user != null) {
                    context.push('/search', extra: user);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bạn cần đăng nhập để tìm kiếm.'),
                      ),
                    );
                  }
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
                  MyApp.themeNotifier.value =
                      val ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            ],
          );
        },
      ),
    );
  }
}