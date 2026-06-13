import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app/app.dart';

void main() {
  testWidgets('Portfolio app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PortfolioApp());
    expect(find.text('이상민'), findsOneWidget);
  });
}
