import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../../widgets/video_track_view.dart';

/// Renders an opaque Domain video track handle with the LiveKit renderer.
///
/// This is the single place where a LiveKit track meets Flutter; the
/// composition edge injects it as the app's [VideoTrackViewBuilder] so
/// screens and widgets never import the SDK.
Widget buildLiveKitVideoView(BuildContext context, Object track) {
  if (track is lk.VideoTrack) {
    return lk.VideoTrackRenderer(track);
  }
  return const ColoredBox(color: Colors.black);
}
