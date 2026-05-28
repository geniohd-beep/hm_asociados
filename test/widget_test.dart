import 'package:flutter_test/flutter_test.dart';

import 'package:hm_asociados/main.dart';

void main() {
  testWidgets('App renders home screen with HM & Asociados title', (WidgetTester tester) async {
    await tester.pumpWidget(const HMAsociadosApp());

    expect(find.text('HM & ASOCIADOS'), findsOneWidget);
    expect(find.text('ESTUDIO JURÍDICO'), findsOneWidget);
  });

  testWidgets('Bottom navigation has three tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const HMAsociadosApp());

    expect(find.text('INICIO'), findsOneWidget);
    expect(find.text('BLOG'), findsOneWidget);
    expect(find.text('PERFIL'), findsOneWidget);
  });

  testWidgets('Can navigate to blog tab', (WidgetTester tester) async {
    await tester.pumpWidget(const HMAsociadosApp());

    await tester.tap(find.text('BLOG'));
    await tester.pumpAndSettle();

    expect(find.text('BLOG JURÍDICO'), findsOneWidget);
  });

  testWidgets('Can navigate to profile tab', (WidgetTester tester) async {
    await tester.pumpWidget(const HMAsociadosApp());

    await tester.tap(find.text('PERFIL'));
    await tester.pumpAndSettle();

    expect(find.text('MI PERFIL'), findsOneWidget);
  });
}
