part of 'package:maid/main.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  Future<void> signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    final email = emailController.text;
    final password = passwordController.text;
    final username = usernameController.text;
    try {
      await Supabase.instance.client.auth.signUp(
          email: email, password: password, data: {'username': username});

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/chat', (route) => false);
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(exception: error),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: buildForm(context),
        ),
      ),
    );
  }

  Widget buildForm(BuildContext context) => Form(
    key: formKey,
    child: ListView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      children: [
        buildUsernameField(),
        const SizedBox(height: 16),
        buildEmailField(),
        const SizedBox(height: 16),
        buildPasswordField(),
        const SizedBox(height: 16),
        buildPasswordConfirmField(),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: signUp,
          child: const Text('Register'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed('/login'),
          child: const Text('I already have an account'),
        ),
      ],
    ),
  );

  Widget buildUsernameField() => TextFormField(
    controller: usernameController,
    decoration: const InputDecoration(
      label: Text('Username'),
    ),
    validator: (val) {
      if (val == null || val.isEmpty) {
        return 'Required';
      }
      final isValid = RegExp(r'^[A-Za-z0-9_]{3,24}$', caseSensitive: false).hasMatch(val);
      if (!isValid) {
        return 'Must be 3-24 characters, alphanumeric or underscore';
      }
      return null;
    },
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

  Widget buildPasswordField() => TextFormField(
    controller: passwordController,
    obscureText: true,
    decoration: const InputDecoration(
      label: Text('Password'),
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
    obscureText: true,
    decoration: const InputDecoration(
      label: Text('Confirm Password'),
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
