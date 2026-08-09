/// What the application ANNOUNCES to a working context: the place the
/// person is in, already resolved.
///
/// This file imports NOTHING — an echo carries one identity, and an
/// identity needs nothing to be true.
///
/// It is an IDENTITY — never a position, never an address, never a
/// route. It is not the truth of navigation and never claims to be:
/// the truth lives with the official navigation state, and a context
/// is handed an echo of it — this announcement — so that a structure
/// can mark the place without ever knowing the topology.
library;

final class MentoraNavigationAnnouncement {
  final String destinationId;

  const MentoraNavigationAnnouncement({required this.destinationId});
}
