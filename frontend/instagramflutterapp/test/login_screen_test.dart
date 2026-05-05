import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instagramflutterapp/src/features/auth/presentation/screens/login_screen.dart';
import 'package:instagramflutterapp/src/services/storage_service.dart';
import 'package:instagramflutterapp/src/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'auth_remember_me': true,
      'auth_remembered_email': 'student@example.com',
      'auth_password': 'should-not-load',
    });
    await EasyLocalization.ensureInitialized();
    await StorageService.instance.init();
  });

  testWidgets(
    'Login screen restores remembered email and checkbox state without loading a password',
    (tester) async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('es')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          child: ProviderScope(
            child: Builder(
              builder: (context) => MaterialApp(
                theme: buildLightTheme(primaryColorHex: '#DF8CBA'),
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
                home: const LoginScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final fields = tester.widgetList<TextFormField>(find.byType(TextFormField));

      expect(fields.length, 2);
      expect(fields.first.controller?.text, 'student@example.com');
      expect(fields.last.controller?.text, isEmpty);

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    },
  );
}
