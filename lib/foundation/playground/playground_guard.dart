import 'package:flutter/foundation.dart' show kReleaseMode;

/// The playground is an internal laboratory — developers, designers,
/// QA and architects only. It never ships: launching it in a release
/// build is refused, fail closed.
void guardPlaygroundAccess({bool isRelease = kReleaseMode}) {
  if (isRelease) {
    throw StateError(
      'The Design Kit Playground is a development tool — it never runs '
      'in production.',
    );
  }
}
