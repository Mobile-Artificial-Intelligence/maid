part of 'package:maid/main.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();

  bool submitting = false;

  Future<void> resetPassword() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    final email = emailController.text;

    try {
      setState(() => submitting = true);

      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      setState(() => submitting = false);

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Check Your Email'),
          content: const Text('A password reset link has been sent to your email.'),
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
      buildEmailField(),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: submitting ? null : resetPassword,
        child: const Text('Send Reset Link'),
      ),
      const SizedBox(height: 16),
      TextButton(
        onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
        child: const Text('Back to Login'),
      ),
    ],
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
}