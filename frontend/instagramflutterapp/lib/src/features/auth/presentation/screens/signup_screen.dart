import 'package:instagramflutterapp/src/imports/core_imports.dart';
import 'package:instagramflutterapp/src/imports/packages_imports.dart';

import 'package:instagramflutterapp/src/features/auth/presentation/providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late GlobalKey<FormState> formKey;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  final showSocialMediaSignin = false;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    Future<void> handleSignup() async {
      if (!(formKey.currentState?.validate() ?? false)) {
        return;
      }

      ref.read(authControllerProvider.notifier).signUp(
            context: context,
            name: nameController.text,
            email: emailController.text,
            password: passwordController.text,
          );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppSpacing.xl),
                Text(
                  'auth.create_account'.tr(),
                  style:
                      tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ).animate().fadeIn().slideY(begin: 0.2),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'auth.create_account_subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ).animate().fadeIn().slideY(begin: 0.2),
                SizedBox(height: AppSpacing.xxxl),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: nameController,
                        enabled: !isLoading,
                        label: 'auth.name'.tr(),
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (v) => AppUtils.isBlank(v)
                            ? 'auth.name_required'.tr()
                            : null,
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: emailController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.emailAddress,
                        label: 'auth.email'.tr(),
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (v) {
                          if (AppUtils.isBlank(v)) {
                            return 'auth.email_required'.tr();
                          }
                          if (!AppUtils.isValidEmail(v!)) {
                            return 'auth.email_invalid'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: passwordController,
                        enabled: !isLoading,
                        label: 'auth.password'.tr(),
                        obscureText: obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        validator: (v) {
                          if (AppUtils.isBlank(v)) {
                            return 'auth.password_required'.tr();
                          }
                          if (v!.length < 6) {
                            return 'auth.password_too_short'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: confirmPasswordController,
                        enabled: !isLoading,
                        label: 'auth.confirm_password'.tr(),
                        obscureText: obscureConfirmPassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (v) {
                          if (AppUtils.isBlank(v)) {
                            return 'auth.confirm_password_required'.tr();
                          }
                          if (v != passwordController.text) {
                            return 'auth.passwords_do_not_match'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: 'Create Account',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : handleSignup,
                        width: ButtonSize.large,
                        isFullWidth: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xxxl),
                if (showSocialMediaSignin)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 20,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFFEA4335)
                                    .withValues(alpha: 0.8),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppBorders.button,
                                ),
                              ),
                              child: SvgPicture.asset(AppAssets.googleIcon),
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF4285F4),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppBorders.button,
                                ),
                              ),
                              child: SvgPicture.asset(AppAssets.facebookIcon),
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF000000),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppBorders.button,
                                ),
                              ),
                              child: SvgPicture.asset(AppAssets.appleIcon),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                InkWell(
                  onTap: () => context.go(AppRoutes.login),
                  child: RichText(
                    text: TextSpan(
                      text: 'auth.already_have_account'.tr(),
                      style:
                          tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      children: [
                        TextSpan(
                          text: 'auth.sign_in'.tr(),
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
