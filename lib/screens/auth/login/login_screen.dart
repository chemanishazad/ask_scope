import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loop/core/TextField.dart/reactive_textfield.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/provider/auth/auth_provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final FormGroup form = FormGroup({
    'email': FormControl<String>(
        validators: [Validators.required, Validators.email]),
    'password': FormControl<String>(
        validators: [Validators.required, Validators.minLength(6)]),
  });

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: ReactiveForm(
            formGroup: form,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo section
                Image.asset(
                  'assets/icons/logo.png',
                  height: 15.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 5.h),

                // Title
                Text(
                  'Sign in to your account',
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        fontSize: 18.sp,
                        color: Palette.themeColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 3.h),

                // Email Field
                const CustomReactiveTextField(
                  formControlName: 'email',
                  label: 'Email',
                  hint: 'Enter your email',
                  icon: Icons.email,
                ),

                const CustomReactiveTextField(
                  formControlName: 'password',
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock,
                  obscureText: true,
                ),

                // Login Button
                ElevatedButton(
                  onPressed: () async {
                    form.markAllAsTouched();

                    if (form.valid) {
                      setState(() => isLoading = true);
                      // final prefs = await SharedPreferences.getInstance();
                      // String? deviceToken = prefs.getString('deviceToken');
                      // print(deviceToken);
                      final response = await ref.read(loginProvider({
                        'email': form.control('email').value ?? '',
                        'password': form.control('password').value ?? '',
                        // 'deviceToken': deviceToken ?? '',
                      }).future);
                      print('response$response');
                      if (response['status'] == true) {
                        Fluttertoast.showToast(msg: response['message']);
                        Navigator.pushReplacementNamed(
                            context, '/bottomNavigation');
                      } else {
                        Fluttertoast.showToast(msg: response['message']);
                      }
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Please Fill Required Details');
                    }

                    setState(() => isLoading = false);
                  },
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
