part of 'package:maid/main.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final formKey = GlobalKey<FormState>();

  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  bool submitting = false;
  bool obscurePassword = true;
  bool obscurePasswordConfirm = true;

  Future<void> signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    final email = emailController.text;
    final password = passwordController.text;
    final userName = userNameController.text;
    try {
      setState(() => submitting = true);
      await Supabase.instance.client.auth.signUp(
          email: email, password: password, data: {'user_name': userName});
      setState(() => submitting = false);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
      
      showDialog(
        context: context,
        builder: buildRegistrationSuccessDialog,
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
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(exception: error),
      );
    }
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
        AppLocalizations.of(context)!.register,
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      buildUserNameField(),
      const SizedBox(height: 16),
      buildEmailField(),
      const SizedBox(height: 16),
      buildPasswordField(),
      const SizedBox(height: 16),
      buildPasswordConfirmField(),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: submitting ? null : signUp,
        child: Text(AppLocalizations.of(context)!.register),
      ),
      const SizedBox(height: 16),
      TextButton(
        onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
        child: Text(AppLocalizations.of(context)!.alreadyHaveAccount),
      ),
    ],
  );

  Widget buildUserNameField() => TextFormField(
    controller: userNameController,
    decoration: InputDecoration(
      label: Text(AppLocalizations.of(context)!.userName),
    ),
    validator: (val) {
      if (val == null || val.isEmpty) {
        return AppLocalizations.of(context)!.required;
      }
      final isValid = RegExp(r'^[A-Za-z0-9_]{3,24}$', caseSensitive: false).hasMatch(val);
      if (!isValid) {
        return AppLocalizations.of(context)!.invalidUserName;
      }
      return null;
    },
  );

  Widget buildEmailField() => TextFormField(
    controller: emailController,
    decoration: InputDecoration(
      label: Text(AppLocalizations.of(context)!.email),
    ),
    validator: (val) {
      if (val == null || val.isEmpty) {
        return AppLocalizations.of(context)!.required;
      }
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(val)) {
        return AppLocalizations.of(context)!.invalidEmail;
      }
      return null;
    },
    keyboardType: TextInputType.emailAddress,
  );

  Widget buildPasswordField() => TextFormField(
    controller: passwordController,
    obscureText: obscurePassword,
    decoration: InputDecoration(
      label: Text(AppLocalizations.of(context)!.password),
      suffixIcon: IconButton(
        onPressed: () => setState(() => obscurePassword = !obscurePassword), 
        icon: obscurePassword 
          ? const Icon(Icons.visibility_off) 
          : const Icon(Icons.visibility)
      )
    ),
    validator: (val) {
      if (val == null || val.isEmpty) {
        return AppLocalizations.of(context)!.required;
      }
      if (val.length < 8) {
        return AppLocalizations.of(context)!.invalidPasswordLength;
      }
      final hasUppercase = val.contains(RegExp(r'[A-Z]'));
      final hasLowercase = val.contains(RegExp(r'[a-z]'));
      final hasDigit = val.contains(RegExp(r'[0-9]'));
      final hasSymbol = val.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
      if (!hasUppercase || !hasLowercase || !hasDigit || !hasSymbol) {
        return AppLocalizations.of(context)!.invalidPassword;
      }
      return null;
    },
  );

  Widget buildPasswordConfirmField() => TextFormField(
    controller: passwordConfirmController,
    obscureText: obscurePasswordConfirm,
    decoration: InputDecoration(
      label: Text(AppLocalizations.of(context)!.confirmPassword),
      suffixIcon: IconButton(
        onPressed: () => setState(() => obscurePasswordConfirm = !obscurePasswordConfirm), 
        icon: obscurePasswordConfirm 
          ? const Icon(Icons.visibility_off) 
          : const Icon(Icons.visibility)
      )
    ),
    validator: (val) {
      if (val == null || val.isEmpty) {
        return AppLocalizations.of(context)!.required;
      }
      if (val != passwordController.text) {
        return AppLocalizations.of(context)!.passwordNoMatch;
      }
      return null;
    },
  );

  Widget buildRegistrationSuccessDialog(BuildContext context) => AlertDialog(
    title: Text(AppLocalizations.of(context)!.registrationSuccess),
    content: Text(AppLocalizations.of(context)!.emailVerify),
    actionsAlignment: MainAxisAlignment.center,
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(AppLocalizations.of(context)!.ok),
      ),
    ],
  );
}
