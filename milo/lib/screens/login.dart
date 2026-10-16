import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:milo/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milo'),
        centerTitle: true,
        backgroundColor: colors.surface,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.lock_outline, size: 36, color: colors.primary),
                      const SizedBox(height: 24),

                      Text(
                        _otpSent ? 'Check your email' : 'Welcome to Milo',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        _otpSent
                            ? 'Enter the code sent to ${_emailController.text.trim()}.'
                            : 'Sign in or create an account with your email.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),

                      if (_otpSent) _buildOtpField() else _buildEmailField(),

                      if (auth.error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          auth.error!,
                          style: TextStyle(color: colors.error),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 24),

                      FilledButton(
                        onPressed: auth.isLoading ? null : _submit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: auth.isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.onPrimary,
                                  ),
                                )
                              : Text(
                                  _otpSent ? 'Verify and sign in' : 'Get OTP',
                                ),
                        ),
                      ),

                      if (_otpSent) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: auth.isLoading ? null : _resendOtp,
                          child: const Text('Resend code'),
                        ),
                        TextButton(
                          onPressed: auth.isLoading ? null : _useDifferentEmail,
                          child: const Text('Use another email'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      decoration: const InputDecoration(
        labelText: 'Email address',
        hintText: 'you@example.com',
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final email = value?.trim() ?? '';

        if (email.isEmpty) {
          return 'Enter your email address.';
        }

        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
          return 'Enter a valid email address.';
        }

        return null;
      },
      onFieldSubmitted: (_) => _submit(),
    );
  }

  Widget _buildOtpField() {
    return TextFormField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.oneTimeCode],
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 22, letterSpacing: 8),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: const InputDecoration(
        labelText: 'Verification code',
        hintText: '000000',
        border: OutlineInputBorder(),
        counterText: '',
      ),
      maxLength: 6,
      validator: (value) {
        if (!RegExp(r'^\d{6}$').hasMatch(value ?? '')) {
          return 'Enter the six-digit code.';
        }

        return null;
      },
      onFieldSubmitted: (_) => _submit(),
    );
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();

    if (auth.isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_otpSent) {
      final sent = await auth.sendOtp(_emailController.text.trim());

      if (!mounted || !sent) return;

      setState(() => _otpSent = true);
      return;
    }

    final signedIn = await auth.verifyOtp(
      email: _emailController.text.trim(),
      otp: _otpController.text.trim(),
    );

    if (signedIn) {
      TextInput.finishAutofillContext();
    }
  }

  Future<void> _resendOtp() async {
    final auth = context.read<AuthProvider>();

    if (auth.isLoading) return;

    final sent = await auth.sendOtp(_emailController.text.trim());

    if (!mounted || !sent) return;

    _otpController.clear();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('A new code was sent.')));
  }

  void _useDifferentEmail() {
    context.read<AuthProvider>().clearError();
    _otpController.clear();

    setState(() => _otpSent = false);
  }
}
