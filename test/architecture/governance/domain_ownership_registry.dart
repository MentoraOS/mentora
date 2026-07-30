/// Machine-readable registry of Mentora architectural ownership.
///
/// Sprint -1.2 / Lot D
///
/// This registry follows the approved Mentora Architecture Handbook.
/// It describes canonical source ownership; it contains no business logic.
enum MentoraDomain {
  identity,
  expert,
  discovery,
  scheduling,
  booking,
  payment,
  consultation,
  review,
  financial,
  automation,
  meeting,
  notification,
}

final class DomainOwnership {
  const DomainOwnership({
    required this.domain,
    required this.root,
    required this.publicFacade,
  });

  final MentoraDomain domain;
  final String root;
  final String publicFacade;
}

const List<DomainOwnership> domainOwnershipRegistry = <DomainOwnership>[
  DomainOwnership(
    domain: MentoraDomain.identity,
    root: 'identity',
    publicFacade: 'identity/identity.dart',
  ),
  DomainOwnership(
    domain: MentoraDomain.expert,
    root: 'expert',
    publicFacade: 'expert/expert.dart',
  ),
  DomainOwnership(
    domain: MentoraDomain.discovery,
    root: 'discovery',
    publicFacade: 'discovery/discovery.dart',
  ),
  DomainOwnership(
    domain: MentoraDomain.scheduling,
    root: 'scheduling',
    publicFacade: 'scheduling/scheduling.dart',
  ),
  DomainOwnership(
    domain: MentoraDomain.booking,
    root: 'booking',
    publicFacade: 'booking/booking.dart',
  ),
  DomainOwnership(
    domain: MentoraDomain.payment,
    root: 'payment',
    publicFacade: 'payment/payment.dart',
  ),
  DomainOwnership(
    domain: MentoraDomain.consultation,
    root: 'consultation',
    publicFacade: 'consultation/consultation.dart',
  ),
  DomainOwnership(
    domain: MentoraDomain.review,
    root: 'review',
    publicFacade: 'review/review.dart',
  ),
  DomainOwnership(
    domain: MentoraDomain.financial,
    root: 'financial',
    publicFacade: 'financial/financial.dart',
  ),
  DomainOwnership(
    domain: MentoraDomain.automation,
    root: 'automation',
    publicFacade: 'automation/automation.dart',
  ),
  DomainOwnership(
    domain: MentoraDomain.meeting,
    root: 'meeting',
    publicFacade: 'meeting/meeting.dart',
  ),
  DomainOwnership(
    domain: MentoraDomain.notification,
    root: 'notification',
    publicFacade: 'notification/notification.dart',
  ),
];

DomainOwnership? ownershipForRoot(String root) {
  for (final ownership in domainOwnershipRegistry) {
    if (ownership.root == root) {
      return ownership;
    }
  }
  return null;
}
