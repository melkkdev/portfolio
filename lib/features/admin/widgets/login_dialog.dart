import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/dev_constants.dart';
import '../admin_scope.dart';
import '../admin_service.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoginDialog(),
    );
  }

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await AdminService.signIn(_emailCtrl.text.trim(), _pwCtrl.text);
      if (mounted) {
        AdminScope.of(context).enter();
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? '로그인 실패';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text(
        '관리자 로그인',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              onSubmitted: (_) => _signIn(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pwCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              onSubmitted: (_) => _signIn(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (kDebugMode)
          TextButton(
            onPressed: () async {
              setState(() => _loading = true);
              try {
                await AdminService.signIn(kDevAdminEmail, kDevAdminPassword);
                if (context.mounted) {
                  AdminScope.of(context).enter();
                  Navigator.of(context).pop();
                }
              } on FirebaseAuthException catch (e) {
                setState(() {
                  _error = e.message ?? '로그인 실패';
                  _loading = false;
                });
              }
            },
            child: const Text('Debug 진입',
                style: TextStyle(color: Colors.orange)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _loading ? null : _signIn,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('로그인'),
        ),
      ],
    );
  }
}
