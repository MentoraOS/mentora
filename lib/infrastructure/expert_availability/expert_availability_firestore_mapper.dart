import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/expert_availability/expert_availability.dart';

final class ExpertAvailabilityFirestoreMapper {
  const ExpertAvailabilityFirestoreMapper();

  ExpertAvailability fromMap(Map<String, dynamic> data) {
    return ExpertAvailability(
      slotsByDay: _slotsFromValue(data['availability']),
      revision: _revisionFromValue(data['availabilityUpdatedAt']),
    );
  }

  Map<String, dynamic> toMap(ExpertAvailability availability) {
    return <String, dynamic>{
      'availability': <String, List<String>>{
        for (final entry in availability.slotsByDay.entries)
          entry.key: List<String>.of(entry.value),
      },
      'availabilityUpdatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, List<String>> _slotsFromValue(Object? value) {
    if (value == null) return const <String, List<String>>{};
    if (value is! Map) {
      throw const FormatException('availability must be a map.');
    }

    final slots = <String, List<String>>{};

    for (final entry in value.entries) {
      final day = entry.key;
      final hours = entry.value;

      if (day is! String) {
        throw const FormatException('availability keys must be strings.');
      }
      if (hours is! List) {
        throw FormatException('availability[$day] must be a list.');
      }
      if (hours.any((hour) => hour is! String)) {
        throw FormatException('availability[$day] members must be strings.');
      }

      slots[day] = hours.cast<String>().toList(growable: false);
    }

    return slots;
  }

  String? _revisionFromValue(Object? value) {
    if (value == null) return null;
    if (value is! Timestamp) {
      throw const FormatException(
        'availabilityUpdatedAt must be a Firestore Timestamp.',
      );
    }

    return '${value.seconds}:${value.nanoseconds}';
  }
}
