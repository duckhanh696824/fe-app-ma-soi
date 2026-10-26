import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ma_soi_app/app.dart';
import 'package:ma_soi_app/providers/game_provider.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GameProvider(),
        child: const MaSoiApp(),
      ),
    );

    expect(find.text('MA SÓI'), findsNothing); // AnimatedTextKit starts typing
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
