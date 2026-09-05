import 'package:flutter_test/flutter_test.dart';
import 'package:website/main.dart';

void main() {
  testWidgets('MiniBinWebsiteApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MiniBinWebsiteApp());
    expect(find.text('MiniBin v2'), findsOneWidget);
  });
}
