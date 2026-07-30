/// Base class for financial domain aggregates that record domain events.
///
/// Events remain internal until they are pulled by the application layer.
/// Pulling events clears the pending collection to prevent duplicate
/// publication.
abstract class AggregateRoot<TEvent extends Object> {
  AggregateRoot({int version = 0}) : _version = version {
    if (version < 0) {
      throw ArgumentError.value(
        version,
        'version',
        'Aggregate version cannot be negative.',
      );
    }
  }

  final List<TEvent> _domainEvents = <TEvent>[];

  int _version;

  /// Current aggregate version.
  ///
  /// The repository will later use this value for optimistic concurrency.
  int get version => _version;

  /// Pending domain events that have not yet been published.
  List<TEvent> get domainEvents => List<TEvent>.unmodifiable(_domainEvents);

  /// Returns true when the aggregate has pending domain events.
  bool get hasDomainEvents => _domainEvents.isNotEmpty;

  /// Number of pending domain events.
  int get domainEventCount => _domainEvents.length;

  /// Records a new domain event and increments the aggregate version.
  void recordDomainEvent(TEvent event) {
    _domainEvents.add(event);
    _version++;
  }

  /// Returns all pending events and clears the internal collection.
  List<TEvent> pullDomainEvents() {
    if (_domainEvents.isEmpty) {
      return <TEvent>[];
    }

    final events = List<TEvent>.unmodifiable(_domainEvents);

    _domainEvents.clear();

    return events;
  }

  /// Clears pending events without returning them.
  ///
  /// This should mainly be used when rehydrating an aggregate from storage.
  void clearDomainEvents() {
    _domainEvents.clear();
  }
}
