import 'package:flutter_test/flutter_test.dart';
import 'package:maid/main.dart';
import 'package:maid/static/theme.dart';
import 'package:maid/types/character.dart';
import 'package:maid/types/model.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App runs without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => Model()),
          ChangeNotifierProvider(create: (context) => Character()),
        ],
        child: const MaidApp(),
      ),
    );
  });
}
