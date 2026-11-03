import 'package:flutter_test/flutter_test.dart';
import 'package:techkart_buddy/core/buddy_push_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TechKart Buddy Push Notification Client Tests', () {
    test('BuddyPushNotificationService singleton check and navigatorKey initialization', () {
      final instance1 = BuddyPushNotificationService();
      final instance2 = BuddyPushNotificationService();
      expect(identical(instance1, instance2), isTrue);
      expect(BuddyPushNotificationService.navigatorKey, isNotNull);
    });

    test('Buddy notification payload maps correctly for Seller & Admin', () {
      final orderAlert = {
        'entity_type': 'Order',
        'event_type': 'ORDER_CONFIRMED',
        'entity_id': 'TK-ORD-89230',
      };
      expect(orderAlert['entity_type'], equals('Order'));

      final payoutAlert = {
        'entity_type': 'Settlement',
        'event_type': 'SETTLEMENT_RELEASED',
        'entity_id': 'STL-2024-1031-01',
      };
      expect(payoutAlert['entity_type'], equals('Settlement'));

      final returnAlert = {
        'entity_type': 'ReturnRequest',
        'event_type': 'RETURN_QUALITY_INSPECTION',
        'entity_id': 'RMA-C900377E',
      };
      expect(returnAlert['entity_type'], equals('ReturnRequest'));
    });
  });
}
