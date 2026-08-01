import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/infrastructure/video_session/production_video_token_provider.dart';
import 'package:mentora/infrastructure/video_session/simulated_video_token_provider.dart';
import 'package:mentora/infrastructure/video_session/video_token_provider.dart';

void main() {
  group('SimulatedVideoTokenProvider — development only', () {
    test('the source is unmistakably marked DEVELOPMENT ONLY', () {
      final source = File(
        'lib/infrastructure/video_session/simulated_video_token_provider.dart',
      ).readAsStringSync();

      expect(source, contains('DEVELOPMENT ONLY.'));
      expect(source, contains('Never usable against a real LiveKit server.'));
      expect(source, contains('Replace by ProductionVideoTokenProvider.'));
    });

    test('its token can never be mistaken for a real JWT', () async {
      const provider = SimulatedVideoTokenProvider();

      final credentials = await provider.credentialsFor(
        roomName: 'mentora_consultation_b1',
        identity: 'b1_client_userA',
      );

      expect(credentials.jwt, endsWith('.DEVELOPMENT_ONLY_UNSIGNED'));
      // The server URL is a reserved invalid host: unreachable by design.
      expect(credentials.serverUrl, contains('.invalid'));
    });
  });

  group('ProductionVideoTokenProvider — skeleton', () {
    test('exists behind the same production-ready contract', () {
      const VideoTokenProvider provider = ProductionVideoTokenProvider();

      expect(provider, isA<VideoTokenProvider>());
    });

    test('every method fails closed until the backend is connected', () {
      const provider = ProductionVideoTokenProvider();

      expect(
        () => provider.credentialsFor(
          roomName: 'mentora_consultation_b1',
          identity: 'b1_client_userA',
        ),
        throwsA(
          isA<UnimplementedError>().having(
            (error) => error.message,
            'message',
            contains('LiveKit token backend is not connected'),
          ),
        ),
      );
    });

    test('no endpoint, no HTTP and no invented API in the skeleton', () {
      final source = File(
        'lib/infrastructure/video_session/production_video_token_provider.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('http')));
      expect(source, isNot(contains('Uri')));
      expect(source, isNot(contains('wss://')));
      // The backend obligations are documented as a contract.
      for (final obligation in const [
        'belongs to the reservation',
        '`confirmed` or `paid`',
        'limit the token permissions',
        'sign the token',
      ]) {
        expect(source, contains(obligation), reason: obligation);
      }
    });
  });

  group('ARC-LK01 — single authorized LiveKit backend access', () {
    test('the token boundary lives ONLY under infrastructure/video_session '
        'and ProductionVideoTokenProvider is its only backend door', () {
      final tokenSurfaceOffenders = <String>[];
      final productionReferenceOffenders = <String>[];

      const allowedTokenSurface = [
        'lib/infrastructure/video_session/video_token_provider.dart',
        'lib/infrastructure/video_session/simulated_video_token_provider.dart',
        'lib/infrastructure/video_session/production_video_token_provider.dart',
        'lib/infrastructure/video_session/livekit_cloud_adapter.dart',
      ];
      // The composition root joins this list the day the production
      // provider is wired in. The contract and the simulated stand-in may
      // NAME the production provider in their documentation.
      const allowedProductionReferences = [
        'lib/infrastructure/video_session/production_video_token_provider.dart',
        'lib/infrastructure/video_session/video_token_provider.dart',
        'lib/infrastructure/video_session/simulated_video_token_provider.dart',
        'lib/composition/mentora_composition_root.dart',
      ];

      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();

        if (source.contains('VideoTokenProvider') &&
            !allowedTokenSurface.contains(normalized)) {
          tokenSurfaceOffenders.add(normalized);
        }
        if (source.contains('ProductionVideoTokenProvider') &&
            !allowedProductionReferences.contains(normalized)) {
          productionReferenceOffenders.add(normalized);
        }
      }

      expect(tokenSurfaceOffenders, isEmpty);
      expect(productionReferenceOffenders, isEmpty);
    });
  });
}
