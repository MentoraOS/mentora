import 'mentora_navigation_coordinator.dart';
import 'mentora_navigation_request.dart';
import 'mentora_navigation_resolution.dart';
import 'mentora_navigation_state.dart';

/// The official dialogue navigation is currently carrying. Nothing
/// else.
///
/// Every voice of navigation answers its own question, and none of
/// them answers this one: WHICH dialogue is the current one. The
/// session is that owner — it states which state, which demand, which
/// answer and which order of voices make up the dialogue in progress,
/// and it states nothing more.
///
/// It is not a machine, not a workflow, not a memory: it holds no
/// past dialogue, no next one, no pile of them — there is the dialogue
/// in progress, whole, and that is all there is. It steers nothing and
/// moves no one: a new dialogue is a new session, announced whole, and
/// the old one never changes.
///
/// It does not know the topology or the gathering: they already exist
/// behind the state, with their one holder, and the session does not
/// reach past its own parts.
///
/// It invents no refusal. The coordinator speaks with its own voice —
/// and through it every voice below. What the session adds is only the
/// agreements no one else can see: that the coordinator of this
/// dialogue speaks of THIS dialogue's parts.
final class MentoraNavigationSession {
  /// Where the person is, in the dialogue in progress.
  final MentoraNavigationState state;

  /// What is asked, in the dialogue in progress.
  final MentoraNavigationRequest request;

  /// What was resolved, in the dialogue in progress.
  final MentoraNavigationResolution resolution;

  /// The order the voices of this dialogue talk in.
  final MentoraNavigationCoordinator coordinator;

  const MentoraNavigationSession({
    required this.state,
    required this.request,
    required this.resolution,
    required this.coordinator,
  });

  /// What the session refuses — fail closed.
  ///
  /// The coordinator speaks first, in its own voice, and every voice
  /// below through it; no message is rewritten here. Then the session
  /// verifies the only thing it owns: that the dialogue is ONE — the
  /// coordinator's parts are this session's parts.
  void verify() {
    coordinator.verify();

    if (coordinator.state != state) {
      throw StateError(
        'A session carries one dialogue: its coordinator speaks of '
        'another position than the one this session carries.',
      );
    }
    if (coordinator.request != request) {
      throw StateError(
        'A session carries one dialogue: its coordinator speaks of '
        'another demand than the one this session carries.',
      );
    }
    if (coordinator.resolution != resolution) {
      throw StateError(
        'A session carries one dialogue: its coordinator speaks of '
        'another answer than the one this session carries.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraNavigationSession &&
        other.state == state &&
        other.request == request &&
        other.resolution == resolution &&
        other.coordinator == coordinator;
  }

  @override
  int get hashCode => Object.hash(state, request, resolution, coordinator);
}
