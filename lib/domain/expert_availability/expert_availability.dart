import 'dart:collection';

final class ExpertAvailability {
  ExpertAvailability({
    required Map<String, List<String>> slotsByDay,
    this.revision,
  }) : slotsByDay = _immutableSlots(slotsByDay);

  final Map<String, List<String>> slotsByDay;
  final String? revision;

  static Map<String, List<String>> _immutableSlots(
    Map<String, List<String>> slotsByDay,
  ) {
    return UnmodifiableMapView(<String, List<String>>{
      for (final entry in slotsByDay.entries)
        entry.key: List<String>.unmodifiable(entry.value),
    });
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ExpertAvailability ||
        revision != other.revision ||
        slotsByDay.length != other.slotsByDay.length) {
      return false;
    }

    for (final entry in slotsByDay.entries) {
      final otherSlots = other.slotsByDay[entry.key];
      if (otherSlots == null || !_sameList(entry.value, otherSlots)) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode {
    final keys = slotsByDay.keys.toList(growable: false)..sort();
    return Object.hash(
      revision,
      Object.hashAll(
        keys.map((key) => Object.hash(key, Object.hashAll(slotsByDay[key]!))),
      ),
    );
  }

  static bool _sameList(List<String> left, List<String> right) {
    if (left.length != right.length) return false;

    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }

    return true;
  }
}
