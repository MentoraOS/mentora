/// Official infrastructure boundary registry for Mentora.
///
/// Sprint -1.2 / Lot E.
///
/// This registry defines technical SDKs that must remain behind
/// infrastructure adapters or application-owned ports.
///
/// This file contains governance metadata only.
enum InfrastructureTechnology {
  firebaseCore,
  firebaseAuth,
  firestore,
  firebaseMessaging,
  firebaseStorage,
  agora,
  webrtc,
  livekit,
  psp,
}

final class InfrastructureBoundary {
  const InfrastructureBoundary({
    required this.technology,
    required this.packagePrefixes,
    required this.allowedRootPrefixes,
  });

  final InfrastructureTechnology technology;

  /// Package import prefixes associated with this technology.
  final Set<String> packagePrefixes;

  /// Source roots where concrete SDK imports are allowed.
  ///
  /// These are paths relative to lib/.
  final Set<String> allowedRootPrefixes;
}

const List<InfrastructureBoundary> infrastructureBoundaryRegistry = [
  InfrastructureBoundary(
    technology: InfrastructureTechnology.firebaseCore,
    packagePrefixes: {'package:firebase_core/'},
    allowedRootPrefixes: {'infrastructure/', 'core/bootstrap/'},
  ),

  InfrastructureBoundary(
    technology: InfrastructureTechnology.firebaseAuth,
    packagePrefixes: {'package:firebase_auth/'},
    allowedRootPrefixes: {
      'infrastructure/',
      'core/identity/infrastructure/',
      'core/bootstrap/',
    },
  ),

  InfrastructureBoundary(
    technology: InfrastructureTechnology.firestore,
    packagePrefixes: {'package:cloud_firestore/'},
    allowedRootPrefixes: {
      'infrastructure/',
      'core/financial/infrastructure/',
      'features/enterprise/data/',
    },
  ),

  InfrastructureBoundary(
    technology: InfrastructureTechnology.firebaseMessaging,
    packagePrefixes: {'package:firebase_messaging/'},
    allowedRootPrefixes: {
      'infrastructure/',
      'core/notification/infrastructure/',
    },
  ),

  InfrastructureBoundary(
    technology: InfrastructureTechnology.firebaseStorage,
    packagePrefixes: {'package:firebase_storage/'},
    allowedRootPrefixes: {'infrastructure/'},
  ),

  InfrastructureBoundary(
    technology: InfrastructureTechnology.agora,
    packagePrefixes: {'package:agora_rtc_engine/'},
    allowedRootPrefixes: {'infrastructure/', 'core/meeting/infrastructure/'},
  ),

  InfrastructureBoundary(
    technology: InfrastructureTechnology.webrtc,
    packagePrefixes: {'package:flutter_webrtc/'},
    allowedRootPrefixes: {'infrastructure/', 'core/meeting/infrastructure/'},
  ),

  InfrastructureBoundary(
    technology: InfrastructureTechnology.livekit,
    packagePrefixes: {'package:livekit_client/'},
    allowedRootPrefixes: {'infrastructure/'},
  ),

  InfrastructureBoundary(
    technology: InfrastructureTechnology.psp,
    packagePrefixes: {
      'package:flutter_stripe/',
      'package:stripe/',
      'package:paydunya/',
      'package:cinetpay/',
      'package:flutterwave/',
      'package:paystack/',
    },
    allowedRootPrefixes: {
      'infrastructure/payment_providers/',
      'core/financial/infrastructure/',
    },
  ),
];
