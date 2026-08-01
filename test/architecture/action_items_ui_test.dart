import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/domain/action_items/action_item.dart';
import 'package:mentora/domain/action_items/action_items_provider.dart';
import 'package:mentora/domain/consultation_memory/consultation_memory.dart';
import 'package:mentora/widgets/action_item_card.dart';
import 'package:mentora/widgets/action_items_controller.dart';
import 'package:mentora/widgets/action_items_overlay.dart';

void main() {
  group('ActionItemsController', () {
    test('follows ONLY the action-items stream', () async {
      final stream = _ActionItemsStream();
      final controller = ActionItemsController(actionItems: stream);
      addTearDown(controller.dispose);

      stream.push(_item('a1', 'Envoyer le devis'));
      stream.push(_item('a2', 'Planifier un suivi'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.items, hasLength(2));
      expect(controller.items.first.title, 'Envoyer le devis');
      expect(
        () => controller.items.removeAt(0),
        throwsUnsupportedError,
      );
    });

    test('accepting is ONLY a visual state', () async {
      final stream = _ActionItemsStream();
      final controller = ActionItemsController(actionItems: stream);
      addTearDown(controller.dispose);

      stream.push(_item('a1', 'Envoyer le devis'));
      await Future<void>.delayed(Duration.zero);

      controller.accept('a1');

      final entry = controller.items.single;
      expect(entry.accepted, isTrue);
      // The proposal itself is untouched — nothing left the overlay.
      expect(entry.item.title, 'Envoyer le devis');
      expect(controller.items, hasLength(1));
    });

    test('editing stays strictly local — the AI proposal is never '
        'modified', () async {
      final stream = _ActionItemsStream();
      final controller = ActionItemsController(actionItems: stream);
      addTearDown(controller.dispose);

      stream.push(_item('a1', 'Envoyer le devis'));
      await Future<void>.delayed(Duration.zero);

      controller.edit('a1', title: 'Envoyer le devis révisé');

      final entry = controller.items.single;
      expect(entry.title, 'Envoyer le devis révisé');
      // The original AI proposal is preserved verbatim underneath.
      expect(entry.item.title, 'Envoyer le devis');
    });

    test('rejecting only removes from the overlay', () async {
      final stream = _ActionItemsStream();
      final controller = ActionItemsController(actionItems: stream);
      addTearDown(controller.dispose);

      stream.push(_item('a1', 'Un'));
      stream.push(_item('a2', 'Deux'));
      await Future<void>.delayed(Duration.zero);

      controller.reject('a1');

      expect(controller.items.map((entry) => entry.item.actionId), ['a2']);
    });

    test('a failed flux stops producing — nothing invented', () async {
      final stream = _ActionItemsStream();
      final controller = ActionItemsController(actionItems: stream);
      addTearDown(controller.dispose);

      stream.push(_item('a1', 'Un'));
      await Future<void>.delayed(Duration.zero);
      stream.pushError(StateError('engine down'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.items, hasLength(1));
    });
  });

  group('ActionItemsOverlay', () {
    testWidgets('shows priority, title, description and exactly the three '
        'decisions', (tester) async {
      final stream = _ActionItemsStream();
      final controller = ActionItemsController(actionItems: stream);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(controller));
      stream.push(
        _item('a1', 'Envoyer le devis', priority: ActionItemPriority.high),
      );
      await tester.pump();

      expect(find.text('Envoyer le devis'), findsOneWidget);
      expect(find.text('Description a1'), findsOneWidget);
      expect(find.text('Prioritaire'), findsOneWidget);
      expect(find.byTooltip('Accepter'), findsOneWidget);
      expect(find.byTooltip('Modifier'), findsOneWidget);
      expect(find.byTooltip('Rejeter'), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('accepting marks the card visually — nothing else '
        'happens', (tester) async {
      final stream = _ActionItemsStream();
      final controller = ActionItemsController(actionItems: stream);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(controller));
      stream.push(_item('a1', 'Envoyer le devis'));
      await tester.pump();

      await tester.tap(find.byTooltip('Accepter'));
      await tester.pump();

      expect(find.text('Acceptée'), findsOneWidget);
      expect(find.text('Envoyer le devis'), findsOneWidget);
      expect(find.byTooltip('Accepter'), findsNothing);
    });

    testWidgets('editing is inline and local — never a popup', (
      tester,
    ) async {
      final stream = _ActionItemsStream();
      final controller = ActionItemsController(actionItems: stream);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(controller));
      stream.push(_item('a1', 'Envoyer le devis'));
      await tester.pump();

      await tester.tap(find.byTooltip('Modifier'));
      await tester.pump();
      expect(find.byType(Dialog), findsNothing);

      await tester.enterText(
        find.byType(TextField).first,
        'Envoyer le devis révisé',
      );
      await tester.tap(find.text('Enregistrer'));
      await tester.pump();

      expect(find.text('Envoyer le devis révisé'), findsOneWidget);
      expect(controller.items.single.title, 'Envoyer le devis révisé');
      expect(controller.items.single.item.title, 'Envoyer le devis');
    });

    testWidgets('rejecting removes the card from the overlay', (
      tester,
    ) async {
      final stream = _ActionItemsStream();
      final controller = ActionItemsController(actionItems: stream);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(controller));
      stream.push(_item('a1', 'Envoyer le devis'));
      await tester.pump();

      await tester.tap(find.byTooltip('Rejeter'));
      await tester.pump();

      expect(find.byType(ActionItemCard), findsNothing);
      expect(find.text('Actions proposées'), findsOneWidget);
    });

    testWidgets('the overlay retracts and the video underneath keeps '
        'receiving taps', (tester) async {
      final stream = _ActionItemsStream();
      final controller = ActionItemsController(actionItems: stream);
      addTearDown(controller.dispose);
      var tapped = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => tapped++,
                    child: const ColoredBox(color: Colors.black),
                  ),
                ),
                Positioned.fill(
                  child: ActionItemsOverlay(controller: controller),
                ),
              ],
            ),
          ),
        ),
      );
      stream.push(_item('a1', 'Envoyer le devis'));
      await tester.pump();

      await tester.tap(find.text('Actions proposées'));
      await tester.pump();
      expect(find.byType(ActionItemCard), findsNothing);

      // The consultation is never interrupted.
      await tester.tapAt(const Offset(400, 200));
      expect(tapped, 1);
    });
  });

  group('Governance — the review UI is local collaboration only', () {
    test('the review components know only the action-items stream', () {
      for (final path in const [
        'lib/widgets/action_items_controller.dart',
        'lib/widgets/action_item_card.dart',
        'lib/widgets/action_items_overlay.dart',
      ]) {
        final source = File(path).readAsStringSync();
        for (final forbidden in const [
          'ActionItemsProvider',
          'AIGateway',
          'openai',
          'OpenAI',
          'ConsultationActionItemsApplicationService',
          'ConsultationMemory',
          'cloud_firestore',
          'Firestore',
          'HttpClient',
          'showDialog',
        ]) {
          expect(
            source,
            isNot(contains(forbidden)),
            reason: '$path must not know $forbidden',
          );
        }
      }
      final controller = File(
        'lib/widgets/action_items_controller.dart',
      ).readAsStringSync();
      expect(controller, contains('ActionItemsStream'));
    });

    test('the review surface in the live screen is expert-only, fail '
        'closed', () {
      final source = File(
        'lib/screens/live_consultation_screen.dart',
      ).readAsStringSync();

      expect(source, contains('ActionItemsController'));
      expect(source, contains('isExpert'));
      expect(source, contains('isExpert = false'));
    });
  });
}

ActionItem _item(
  String id,
  String title, {
  ActionItemPriority priority = ActionItemPriority.normal,
}) {
  return ActionItem(
    sessionId: 's1',
    actionId: id,
    title: title,
    description: 'Description $id',
    priority: priority,
    createdAt: DateTime.utc(2026, 8, 1, 9),
  );
}

Widget _app(ActionItemsController controller) {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Colors.black)),
          Positioned.fill(child: ActionItemsOverlay(controller: controller)),
        ],
      ),
    ),
  );
}

final class _ActionItemsStream implements ActionItemsStream {
  final StreamController<ActionItem> _items =
      StreamController<ActionItem>.broadcast(sync: true);

  void push(ActionItem item) => _items.add(item);

  void pushError(Object error) => _items.addError(error);

  @override
  Stream<ActionItem> get items => _items.stream;

  @override
  ActionItemsStatus get status => ActionItemsStatus.proposing;

  @override
  Future<void> refresh(ConsultationMemory memory) async {}

  @override
  Future<ActionItemsResult> stop() async {
    return const ActionItemsResult(
      sessionId: 's1',
      status: ActionItemsStatus.stopped,
    );
  }
}
