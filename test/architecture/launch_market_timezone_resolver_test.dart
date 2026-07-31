import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/scheduling/ports/timezone_resolver.dart';
import 'package:mentora/infrastructure/scheduling/launch_market_timezone_resolver.dart';

void main() {
  const resolver = LaunchMarketTimezoneResolver();

  group('AD-022 Wave A — supported launch-market zones', () {
    test('Africa/Bamako resolves civil time to the correct instant', () {
      final utc = resolver.toUtc(
        localDateTime: DateTime.utc(2026, 7, 25, 9),
        zone: TimezoneId('Africa/Bamako'),
      );

      expect(utc, DateTime.utc(2026, 7, 25, 9));
      expect(utc.isUtc, isTrue);
    });

    test('Africa/Dakar resolves civil time to the correct instant', () {
      expect(
        resolver.toUtc(
          localDateTime: DateTime.utc(2026, 7, 25, 14, 30),
          zone: TimezoneId('Africa/Dakar'),
        ),
        DateTime.utc(2026, 7, 25, 14, 30),
      );
    });

    test('Africa/Abidjan resolves civil time to the correct instant', () {
      expect(
        resolver.toUtc(
          localDateTime: DateTime.utc(2026, 12, 31, 23, 59),
          zone: TimezoneId('Africa/Abidjan'),
        ),
        DateTime.utc(2026, 12, 31, 23, 59),
      );
    });

    test('fromUtc projects an instant back to civil fields', () {
      final civil = resolver.fromUtc(
        utcDateTime: DateTime.utc(2026, 7, 25, 9),
        zone: TimezoneId('Africa/Bamako'),
      );

      expect(civil.year, 2026);
      expect(civil.month, 7);
      expect(civil.day, 25);
      expect(civil.hour, 9);
      expect(civil.isUtc, isTrue);
    });

    test('round-trips civil time through an instant', () {
      final zone = TimezoneId('Africa/Dakar');
      final civil = DateTime.utc(2026, 3, 8, 10, 15);

      expect(
        resolver.fromUtc(
          utcDateTime: resolver.toUtc(localDateTime: civil, zone: zone),
          zone: zone,
        ),
        civil,
      );
    });
  });

  group('AD-022 Wave A — identity is never replaced by an offset', () {
    test('the IANA name remains the identity even when the offset is UTC', () {
      final zone = TimezoneId('Africa/Bamako');

      expect(zone.value, 'Africa/Bamako');
      expect(zone.value, isNot('UTC'));
      expect(zone.value, isNot('+00:00'));
      expect(LaunchMarketTimezoneResolver.supports(zone), isTrue);
    });

    test('supported zones are declared as IANA identities', () {
      expect(LaunchMarketTimezoneResolver.supportedZones, {
        'Africa/Bamako',
        'Africa/Dakar',
        'Africa/Abidjan',
        'UTC',
      });
    });

    test('a UTC offset is rejected as an identity by the port', () {
      for (final offset in const ['+00:00', '-05:00', 'UTC+1']) {
        expect(() => TimezoneId(offset), throwsArgumentError, reason: offset);
      }
    });
  });

  group('AD-022 Wave A — unsupported zones fail closed', () {
    test('Europe/Paris is not supported and does not fall back', () {
      final paris = TimezoneId('Europe/Paris');

      expect(LaunchMarketTimezoneResolver.supports(paris), isFalse);
      expect(
        () => resolver.toUtc(
          localDateTime: DateTime.utc(2026, 7, 25, 9),
          zone: paris,
        ),
        throwsA(isA<UnsupportedTimezoneException>()),
      );
      expect(
        () => resolver.fromUtc(
          utcDateTime: DateTime.utc(2026, 7, 25, 9),
          zone: paris,
        ),
        throwsA(isA<UnsupportedTimezoneException>()),
      );
    });

    test('other DST zones also fail closed rather than approximate', () {
      for (final name in const [
        'America/New_York',
        'Europe/London',
        'Africa/Cairo',
      ]) {
        expect(
          () => resolver.toUtc(
            localDateTime: DateTime.utc(2026, 7, 25, 9),
            zone: TimezoneId(name),
          ),
          throwsA(isA<UnsupportedTimezoneException>()),
          reason: name,
        );
      }
    });

    test('an invalid identity is rejected before reaching the resolver', () {
      expect(() => TimezoneId(''), throwsArgumentError);
      expect(() => TimezoneId('   '), throwsArgumentError);
      expect(() => TimezoneId('Bamako'), throwsArgumentError);
    });
  });

  group('AD-022 Wave A — no device-time dependency', () {
    test('interpretation ignores the device timezone flag of the input', () {
      final zone = TimezoneId('Africa/Bamako');

      // Same civil fields, one device-local and one UTC-flagged. A resolver
      // that consulted the device offset would produce different instants.
      final fromDeviceLocal = resolver.toUtc(
        localDateTime: DateTime(2026, 7, 25, 9),
        zone: zone,
      );
      final fromUtcFlagged = resolver.toUtc(
        localDateTime: DateTime.utc(2026, 7, 25, 9),
        zone: zone,
      );

      expect(fromDeviceLocal, fromUtcFlagged);
      expect(fromDeviceLocal, DateTime.utc(2026, 7, 25, 9));
    });

    test('fromUtc refuses a device-local instant', () {
      expect(
        () => resolver.fromUtc(
          utcDateTime: DateTime(2026, 7, 25, 9),
          zone: TimezoneId('Africa/Bamako'),
        ),
        throwsArgumentError,
      );
    });

    test('interpretation is deterministic and clock-independent', () {
      final zone = TimezoneId('Africa/Abidjan');
      final civil = DateTime.utc(2026, 7, 25, 9);

      final first = resolver.toUtc(localDateTime: civil, zone: zone);
      final second = resolver.toUtc(localDateTime: civil, zone: zone);

      expect(first, second);
    });
  });
}
