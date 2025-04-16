part of 'package:maid/main.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  bool submitting = false;
  bool otpSent = false;
  bool obscurePassword = true;
  bool obscurePasswordConfirm = true;

  Future<void> sendOtp() async {
    if (!otpSent && !formKey.currentState!.validate()) return;

    final email = emailController.text;

    try {
      setState(() => submitting = true);

      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      setState(() {
        submitting = false;
        otpSent = true;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A reset code has been sent to your email.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating
        ),
      );
    } 
    on AuthException catch (error) {
      setState(() => submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating
        ),
      );
    } 
    catch (error) {
      setState(() => submitting = false);
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(exception: error),
      );
    }
  }

  Future<void> resetPasswordWithOtp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    final email = emailController.text;
    final otp = otpController.text;
    final newPassword = passwordController.text;

    try {
      setState(() => submitting = true);

      await Supabase.instance.client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.recovery,
      );

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      setState(() => submitting = false);

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Your password has been reset successfully.'),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context)
                  .popUntil((route) => route.isFirst),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      setState(() => submitting = false);
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(exception: error),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: buildForm(context),
          ),
        ),
      );

  Widget buildForm(BuildContext context) => Form(
        key: formKey,
        child: SingleChildScrollView(
          child: buildColumn(context),
        ),
      );

  Widget buildColumn(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Reset Password',
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      if (otpSent) buildResetColumn() else
        buildRequestColumn()
    ],
  );

  Widget buildRequestColumn() => Column(
    children: [
      buildEmailField(),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: submitting ? null : sendOtp,
        child: const Text('Send Reset Code'),
      ),
      const SizedBox(height: 16),
      TextButton(
        onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
        child: const Text('Back to Login'),
      ),
    ]
  );

  Widget buildResetColumn() => Column(
    children: [
      buildOtpField(),
      const SizedBox(height: 16),
      buildPasswordField(),
      const SizedBox(height: 16),
      buildPasswordConfirmField(),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: submitting ? null : resetPasswordWithOtp,
        child: const Text('Reset Password'),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: submitting ? null : sendOtp,
            child: const Text('Send Again'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
            child: const Text('Back to Login'),
          ),
        ]
      )
    ]
  );

  Widget buildEmailField() => TextFormField(
    controller: emailController,
    decoration: const InputDecoration(
      label: Text('Email'),
    ),
    validator: (val) {
      if (val == null || val.isEmpty) {
        return 'Required';
      }
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(val)) {
        return 'Please enter a valid email';
      }
      return null;
    },
    keyboardType: TextInputType.emailAddress,
  );

  Widget buildOtpField() => TextFormField(
    controller: otpController,
    decoration: const InputDecoration(label: Text('Reset Code')),
    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
  );

  Widget buildPasswordField() => TextFormField(
    controller: passwordController,
    obscureText: obscurePassword,
    decoration: InputDecoration(
      label: Text('Password'),
      suffixIcon: IconButton(
        onPressed: () => setState(() => obscurePassword = !obscurePassword), 
        icon: obscurePassword 
          ? const Icon(Icons.visibility_off) 
          : const Icon(Icons.visibility)
      )
    ),
    validator: (val) {
      if (val == null || val.isEmpty) {
        return 'Required';
      }
      if (val.length < 8) {
        return 'Minimum 8 characters';
      }
      final hasUppercase = val.contains(RegExp(r'[A-Z]'));
      final hasLowercase = val.contains(RegExp(r'[a-z]'));
      final hasDigit = val.contains(RegExp(r'[0-9]'));
      final hasSymbol = val.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
      if (!hasUppercase || !hasLowercase || !hasDigit || !hasSymbol) {
        return 'Include upper, lower, number, and symbol';
      }
      return null;
    },
  );

  Widget buildPasswordConfirmField() => TextFormField(
    controller: passwordConfirmController,
    obscureText: obscurePasswordConfirm,
    decoration: InputDecoration(
      label: Text('Confirm Password'),
      suffixIcon: IconButton(
        onPressed: () => setState(() => obscurePasswordConfirm = !obscurePasswordConfirm), 
        icon: obscurePasswordConfirm 
          ? const Icon(Icons.visibility_off) 
          : const Icon(Icons.visibility)
      )
    ),
    validator: (val) {
      if (val == null || val.isEmpty) {
        return 'Required';
      }
      if (val != passwordController.text) {
        return 'Passwords do not match';
      }
      return null;
    },
  );
}