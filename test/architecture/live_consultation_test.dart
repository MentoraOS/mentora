import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/domain/video_session/live_consultation_room.dart';
import 'package:mentora/domain/video_session/video_session_provider.dart';
import 'package:mentora/infrastructure/video_session/simulated_video_token_provider.dart';
import 'package:mentora/screens/live_consultation_screen.dart';
import 'package:mentora/widgets/video_track_view.dart';
import 'package:provider/provider.dart';

void main() {
  group('SimulatedVideoTokenProvider', () {
    test('derives full credentials, never a hard-coded JWT', () async {
      const provider = SimulatedVideoTokenProvider();

      final credentials = await provider.credentialsFor(
        roomName: 'mentora_consultation_b1',
        identity: 'b1_client_userA',
      );
      final other = await provider.credentialsFor(
        roomName: 'mentora_consultation_b2',
        identity: 'b2_client_userA',
      );

      expect(credentials.serverUrl, startsWith('wss://'));
      expect(credentials.roomName, 'mentora_consultation_b1');
      expect(credentials.identity, 'b1_client_userA');
      expect(credentials.jwt.split('.'), hasLength(3));
      // Derived from the inputs: different rooms, different tokens.
      expect(other.jwt, isNot(credentials.jwt));
    });
  });

  group('LiveKit boundary — ARC governance', () {
    test('livekit_client is imported ONLY under lib/infrastructure/', () {
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        if (normalized.startsWith('lib/infrastructure/')) continue;
        if (entity.readAsStringSync().contains('package:livekit_client/')) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });

    test('the real adapter uses the LiveKit room primitives', () {
      final source = File(
        'lib/infrastructure/video_session/livekit_room_adapter.dart',
      ).readAsStringSync();

      for (final primitive in const [
        'Room(',
        'RoomOptions',
        'ConnectOptions',
        'createListener',
        'ParticipantConnectedEvent',
        'ParticipantDisconnectedEvent',
        'RoomReconnectingEvent',
        'RoomReconnectedEvent',
        'RoomDisconnectedEvent',
        'ConnectionState',
        'setMicrophoneEnabled',
        'setCameraEnabled',
      ]) {
        expect(source, contains(primitive), reason: primitive);
      }
      for (final failure in const [
        'AuthenticationFailure',
        'RoomUnavailableFailure',
        'ConnectionFailure',
        'UnexpectedVideoFailure',
      ]) {
        expect(source, contains(failure), reason: failure);
      }
    });
  });

  group('Consultation extension hooks — present but inactive', () {
    // ConversationAudioStream and LiveTranscriptProvider were realized by
    // the transcript foundation wave (domain/transcript) and left the
    // hooks file; the remaining three stay empty and unreferenced.
    // The translation hook was realized by the realtime translation wave
    // (domain/translation) and left the hooks file.
    // The recording hook was realized by the recording foundation wave
    // (domain/recording) and left the hooks file.
    const names = ['VideoFrameObserver'];

    test('the remaining hooks exist as empty dependency-free contracts', () {
      final source = File(
        'lib/domain/video_session/consultation_extension_hooks.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('import ')));
      for (final name in names) {
        expect(
          source,
          contains('abstract interface class $name {}'),
          reason: name,
        );
      }
    });

    test('nothing implements or references them yet', () {
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        if (normalized.endsWith('consultation_extension_hooks.dart')) {
          continue;
        }
        final source = entity.readAsStringSync();
        for (final name in names) {
          expect(source, isNot(contains(name)), reason: '$normalized: $name');
        }
      }
    });
  });

  group('LiveConsultationScreen', () {
    testWidgets('shows the connecting state until the room is joined', (
      tester,
    ) async {
      final room = _FakeRoom(connectCompleter: Completer<void>());

      await tester.pumpWidget(_app(room));
      await tester.tap(find.text('Ouvrir'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Connexion…'), findsOneWidget);
      room.connectCompleter!.complete();
      await tester.pump();
    });

    testWidgets('renders both videos once connected to the peer', (
      tester,
    ) async {
      final room = _FakeRoom()
        ..localTrack = 'local_track'
        ..remoteTrack = 'remote_track'
        ..remoteIdentity = 'b1_expert_expert_1';

      await tester.pumpWidget(_app(room));
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text('Connecté'), findsOneWidget);
      expect(find.text('video:local_track'), findsOneWidget);
      expect(find.text('video:remote_track'), findsOneWidget);
    });

    testWidgets('reconnection and lone-participant states are visible', (
      tester,
    ) async {
      final room = _FakeRoom();

      await tester.pumpWidget(_app(room));
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();
      // Connected but alone in the room.
      expect(
        find.text('En attente du participant distant…'),
        findsNWidgets(2),
      );

      room.state = LiveConsultationConnectionState.reconnecting;
      room.notify();
      await tester.pump();
      expect(find.text('Reconnexion…'), findsOneWidget);
    });

    testWidgets('the microphone toggles through the room contract', (
      tester,
    ) async {
      final room = _FakeRoom();

      await tester.pumpWidget(_app(room));
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Couper le micro'));
      await tester.pump();

      expect(room.microphoneCalls, [false]);
      expect(find.byTooltip('Activer le micro'), findsOneWidget);
    });

    testWidgets('the camera toggles and the local preview reflects it', (
      tester,
    ) async {
      final room = _FakeRoom()..localTrack = 'local_track';

      await tester.pumpWidget(_app(room));
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();
      expect(find.text('video:local_track'), findsOneWidget);

      await tester.tap(find.byTooltip('Couper la caméra'));
      await tester.pump();

      expect(room.cameraCalls, [false]);
      expect(find.text('Caméra coupée'), findsOneWidget);
    });

    testWidgets('leaving disconnects cleanly and closes the screen', (
      tester,
    ) async {
      final room = _FakeRoom();

      await tester.pumpWidget(_app(room));
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Quitter'));
      await tester.pumpAndSettle();

      expect(room.disconnected, isTrue);
      expect(find.byType(LiveConsultationScreen), findsNothing);
    });

    testWidgets('a rejected token is a visible failure, never a success', (
      tester,
    ) async {
      final room = _FakeRoom(
        connectError: const AuthenticationFailure(cause: 'invalid token'),
      );

      await tester.pumpWidget(_app(room));
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text('Échec de connexion'), findsOneWidget);
      expect(
        find.text('Accès vidéo refusé. Reconnectez-vous et réessayez.'),
        findsOneWidget,
      );
      expect(find.text('Connecté'), findsNothing);
    });

    testWidgets('an unreachable room reports the connection failure', (
      tester,
    ) async {
      final room = _FakeRoom(
        connectError: const ConnectionFailure(cause: 'socket closed'),
      );

      await tester.pumpWidget(_app(room));
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(
        find.text('Connexion à la salle impossible. Vérifiez votre réseau.'),
        findsOneWidget,
      );
    });
  });
}

VideoSessionInfo _session() {
  return const VideoSessionInfo(
    sessionId: 'mentora_consultation_b1',
    participantIdentity: 'b1_client_client_1',
    role: VideoParticipantRole.client,
    serverUrl: 'wss://fake.livekit.cloud/mentora',
    accessToken: 'a.b.c',
  );
}

Widget _app(_FakeRoom room) {
  return MultiProvider(
    providers: [
      Provider<LiveConsultationRoomProvider>.value(
        value: _FakeRoomProvider(room),
      ),
      Provider<VideoTrackViewBuilder>.value(
        value: (context, track) => Text('video:$track'),
      ),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LiveConsultationScreen(session: _session()),
                  ),
                );
              },
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ),
    ),
  );
}

final class _FakeRoomProvider implements LiveConsultationRoomProvider {
  _FakeRoomProvider(this.room);

  final _FakeRoom room;

  @override
  LiveConsultationRoom createRoom(VideoSessionInfo session) => room;
}

final class _FakeRoom implements LiveConsultationRoom {
  _FakeRoom({this.connectCompleter, this.connectError});

  final Completer<void>? connectCompleter;
  final VideoRoomFailure? connectError;
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );

  LiveConsultationConnectionState state =
      LiveConsultationConnectionState.disconnected;
  bool micEnabled = true;
  bool camEnabled = true;
  Object? localTrack;
  Object? remoteTrack;
  String? remoteIdentity;
  bool disconnected = false;
  final List<bool> microphoneCalls = [];
  final List<bool> cameraCalls = [];

  void notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  @override
  Future<void> connect() async {
    state = LiveConsultationConnectionState.connecting;
    notify();
    if (connectCompleter case final completer?) await completer.future;
    if (connectError case final failure?) {
      state = LiveConsultationConnectionState.disconnected;
      notify();
      throw failure;
    }
    state = LiveConsultationConnectionState.connected;
    notify();
  }

  @override
  Future<void> disconnect() async {
    disconnected = true;
    state = LiveConsultationConnectionState.disconnected;
    notify();
  }

  @override
  Future<void> reconnect() => connect();

  @override
  Future<void> setMicrophoneEnabled(bool enabled) async {
    micEnabled = enabled;
    microphoneCalls.add(enabled);
    notify();
  }

  @override
  Future<void> setCameraEnabled(bool enabled) async {
    camEnabled = enabled;
    cameraCalls.add(enabled);
    if (!enabled) localTrack = null;
    notify();
  }

  @override
  LiveConsultationConnectionState get connectionState => state;

  @override
  bool get microphoneEnabled => micEnabled;

  @override
  bool get cameraEnabled => camEnabled;

  @override
  String? get remoteParticipantIdentity => remoteIdentity;

  @override
  Object? get localVideoTrack => localTrack;

  @override
  Object? get remoteVideoTrack => remoteTrack;

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<void> dispose() async {
    await _changes.close();
  }
}
