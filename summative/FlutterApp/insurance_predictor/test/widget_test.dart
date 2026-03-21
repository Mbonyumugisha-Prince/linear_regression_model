import 'package:flutter_test/flutter_test.dart';
import 'package:insurance_predictor/main.dart';

void main() {
  testWidgets('App launches and shows greeting', (WidgetTester tester) async {
    await tester.pumpWidget(const InsuranceApp());
    expect(find.text('Predict your insurance cost'), findsOneWidget);
  });
}
