import 'domain_ownership_registry.dart';

/// Compile-time dependency policy between Mentora ownership domains.
///
/// Sprint -1.2 / Lot D.
///
/// This is NOT the product journey.
///
/// Reverse business facts should use events, gateways or dependency inversion,
/// not symmetric compile-time dependencies.
abstract final class DependencyDirectionMatrix {
  static const Map<MentoraDomain, Set<MentoraDomain>> allowed = {
    MentoraDomain.identity: <MentoraDomain>{},

    MentoraDomain.expert: <MentoraDomain>{MentoraDomain.identity},

    MentoraDomain.discovery: <MentoraDomain>{
      MentoraDomain.identity,
      MentoraDomain.expert,
      MentoraDomain.scheduling,
      MentoraDomain.review,
    },

    MentoraDomain.scheduling: <MentoraDomain>{
      MentoraDomain.identity,
      MentoraDomain.expert,
    },

    MentoraDomain.booking: <MentoraDomain>{
      MentoraDomain.identity,
      MentoraDomain.expert,
      MentoraDomain.scheduling,
      MentoraDomain.payment,
    },

    MentoraDomain.payment: <MentoraDomain>{
      MentoraDomain.identity,
      MentoraDomain.financial,
    },

    MentoraDomain.consultation: <MentoraDomain>{
      MentoraDomain.identity,
      MentoraDomain.expert,
      MentoraDomain.booking,
      MentoraDomain.meeting,
    },

    MentoraDomain.review: <MentoraDomain>{
      MentoraDomain.identity,
      MentoraDomain.expert,
      MentoraDomain.booking,
      MentoraDomain.consultation,
    },

    MentoraDomain.financial: <MentoraDomain>{},

    MentoraDomain.automation: <MentoraDomain>{},

    MentoraDomain.meeting: <MentoraDomain>{MentoraDomain.identity},

    MentoraDomain.notification: <MentoraDomain>{
      MentoraDomain.identity,
      MentoraDomain.automation,
    },
  };

  static bool isAllowed({
    required MentoraDomain source,
    required MentoraDomain target,
  }) {
    if (source == target) {
      return true;
    }

    return allowed[source]?.contains(target) ?? false;
  }

  static Set<MentoraDomain> allowedTargetsFor(MentoraDomain source) {
    return allowed[source] ?? const <MentoraDomain>{};
  }
}
