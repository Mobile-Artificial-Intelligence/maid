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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.resetCodeSent),
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
          title: Text(AppLocalizations.of(context)!.success),
          content: Text(AppLocalizations.of(context)!.resetSuccess),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context)
                  .popUntil((route) => route.isFirst),
              child: Text(AppLocalizations.of(context)!.ok),
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
        AppLocalizations.of(context)!.resetPassword,
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
        child: Text(AppLocalizations.of(context)!.sendResetCode),
      ),
      const SizedBox(height: 16),
      TextButton(
        onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
        child: Text(AppLocalizations.of(context)!.backToLogin),
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
        child: Text(AppLocalizations.of(context)!.resetPassword),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: submitting ? null : sendOtp,
            child: Text(AppLocalizations.of(context)!.sendAgain),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
            child: Text(AppLocalizations.of(context)!.backToLogin),
          ),
        ]
      )
    ]
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

  Widget buildOtpField() => TextFormField(
    controller: otpController,
    decoration: InputDecoration(
      label: Text(AppLocalizations.of(context)!.resetCode)
    ),
    validator: (val) => val == null || val.isEmpty ? AppLocalizations.of(context)!.required : null,
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
}