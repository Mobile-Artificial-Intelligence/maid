import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maid/main.dart';
import 'package:maid/providers/character.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/providers/user.dart';

void main() {
  group('Change User Picture Tests', () {
    testWidgets('Build and trigger frame', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MaidApp(
        appPreferences: AppPreferences(),
        user: User(),
        character: Character(),
        session: Session()
      ));
    });

    testWidgets('Find drawer menu button', (WidgetTester tester) async {
      await tester.pumpWidget(MaidApp(
        appPreferences: AppPreferences(),
        user: User(),
        character: Character(),
        session: Session()
      ));
      
      // Verify the dawer menu button is present
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('Open drawer menu', (WidgetTester tester) async {
      await tester.pumpWidget(MaidApp(
        appPreferences: AppPreferences(),
        user: User(),
        character: Character(),
        session: Session()
      ));

      // Verify the dawer menu button is present
      expect(find.byIcon(Icons.menu), findsOneWidget);

      // Press the button to open the drawer.
      await tester.tap(find.byIcon(Icons.menu));

      // Wait for the drawer to open
      await tester.pump(const Duration(seconds: 1));

      // Verify the user menu button is present
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    //testWidgets('Open user menu', (WidgetTester tester) async {
    //  await tester.pumpWidget(MaidApp(
    //    user: User(),
    //    character: Character(),
    //    session: Session()
    //  ));
    //
    //  // Press the button to open the drawer.
    //  await tester.tap(find.byIcon(Icons.menu));
    //
    //  // Wait for the drawer to open
    //  await tester.pump(const Duration(seconds: 1)); // Timed out
    //
    //  // Verify the user menu button is present
    //  expect(find.byIcon(Icons.more_vert), findsOneWidget);
    //
    //  // Tap the user menu button
    //  await tester.tap(find.byIcon(Icons.more_vert));
    //
    //  // Wait for the user menu to open
    //  await tester.pump(const Duration(seconds: 2));
    //
    //  // Verify Change Picture listtile in the popup menu
    //  expect(find.text('Change Picture'), findsOneWidget);
    //});
    
    //testWidgets('Open Change Picture dialog', (WidgetTester tester) async {
    //  await tester.pumpWidget(MaidApp(
    //    user: User(),
    //    character: Character(),
    //    session: Session()
    //  ));
    //
    //  // Press the button to open the drawer.
    //  await tester.tap(find.byIcon(Icons.menu));
    //
    //  // Wait for the drawer to open
    //  await tester.pump(const Duration(seconds: 1));
    //
    //  // Verify the user menu button is present
    //  expect(find.byIcon(Icons.more_vert), findsOneWidget);
    //
    //  // Wait for the user menu to open
    //  await tester.pump(const Duration(seconds: 1));
    //
    //  // Tap the Change Picture listtile
    //  await tester.tap(find.text('Change Picture'));
    //
    //  // Wait for the Change Picture alert dialog to open
    //  await tester.pump(const Duration(seconds: 1));
    //
    //  // Verify Change Profile Picture text in the alert dialog
    //  expect(find.text('Change Profile Picture'), findsOneWidget);
    //});
  });
}
