import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instagramflutterapp/src/shared/widgets/app_text_field.dart';

void main() {
  testWidgets('AppTextField wires an outside-tap callback',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TapRegionSurface(
          child: Scaffold(
            body: const Padding(
              padding: EdgeInsets.all(24),
              child: AppTextField(
                label: 'Email',
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pump();

    final editableText = tester.widget<EditableText>(
      find.byType(EditableText),
    );

    expect(editableText.onTapOutside, isNotNull);
  });
}
