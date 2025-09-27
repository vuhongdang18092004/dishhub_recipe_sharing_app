import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng nhập")),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Xin chào ${state.user.name}!")),
            );
            //chuyển sang màn hình chính
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: "Mật khẩu"),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          AuthSignInEmail(
                            email: emailController.text,
                            password: passwordController.text,
                          ),
                        );
                  },
                  child: const Text("Đăng nhập"),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthSignInGoogle());
                  },
                  icon: const Icon(Icons.login),
                  label: const Text("Đăng nhập với Google"),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          AuthResetPassword(email: emailController.text),
                        );
                  },
                  child: const Text("Quên mật khẩu?"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
