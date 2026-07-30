import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/scheduling/engine/timezone_engine.dart';
import 'package:mentora/core/scheduling/models/timezone_info.dart';

void main() {
  group('Timezone Engine', () {
    test('should convert Bamako time to Tokyo time', () {
      const bamako = TimezoneInfo(
        id: 'africa_bamako',
        name: 'Africa/Bamako',
        country: 'Mali',
        abbreviation: 'GMT',
        offset: Duration(hours: 0),
      );

      const tokyo = TimezoneInfo(
        id: 'asia_tokyo',
        name: 'Asia/Tokyo',
        country: 'Japan',
        abbreviation: 'JST',
        offset: Duration(hours: 9),
      );

      final bamakoTime = DateTime(2026, 7, 7, 10);

      final tokyoTime = TimezoneEngine.instance.convert(
        dateTime: bamakoTime,
        from: bamako,
        to: tokyo,
      );

      expect(tokyoTime.hour, 19);
    });
  });
}
