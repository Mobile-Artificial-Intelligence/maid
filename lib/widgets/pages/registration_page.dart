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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: buildForm(context),
    );
  }

  Widget buildForm(BuildContext context) => Form(
    key: formKey,
    child: ListView(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      children: [
        buildUsernameField(),
        SizedBox(width: 16, height: 16),
        buildEmailField(),
        SizedBox(width: 16, height: 16),
        buildPasswordField(),
        SizedBox(width: 16, height: 16),
        buildPasswordConfirmField(),
        SizedBox(width: 16, height: 16),
        ElevatedButton(
          onPressed: signUp,
          child: const Text('Register'),
        ),
        SizedBox(width: 16, height: 16),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed('/login'),
          child: const Text('I already have an account'),
        )
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
      final isValid = RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(val);
      if (!isValid) {
        return '3-24 long with alphanumeric or underscore';
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
      if (val.length < 6) {
        return '6 characters minimum';
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