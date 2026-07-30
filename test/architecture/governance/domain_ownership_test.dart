import 'package:flutter_test/flutter_test.dart';

import 'domain_ownership_registry.dart';

void main() {
  group('Mentora Domain Ownership — Sprint -1.2 / Lot D', () {
    test('ARC-D01 every registered domain must be unique', () {
      final domains = domainOwnershipRegistry
          .map((ownership) => ownership.domain)
          .toList();

      expect(
        domains.toSet().length,
        domains.length,
        reason: 'A Mentora domain cannot have multiple ownership entries.',
      );
    });

    test('ARC-D02 every ownership root must be unique', () {
      final roots = domainOwnershipRegistry
          .map((ownership) => ownership.root)
          .toList();

      expect(
        roots.toSet().length,
        roots.length,
        reason: 'Two Mentora domains cannot own the same source root.',
      );
    });

    test('ARC-D03 every public facade path must be unique', () {
      final facades = domainOwnershipRegistry
          .map((ownership) => ownership.publicFacade)
          .toList();

      expect(
        facades.toSet().length,
        facades.length,
        reason: 'Two Mentora domains cannot share the same public facade.',
      );
    });

    test('ARC-D04 ownership roots must use canonical names', () {
      final violations = <String>[];

      for (final ownership in domainOwnershipRegistry) {
        final expectedRoot = ownership.domain.name;
        if (ownership.root != expectedRoot) {
          violations.add(
            '${ownership.domain.name}: expected "$expectedRoot", '
            'found "${ownership.root}"',
          );
        }
      }

      expect(violations, isEmpty, reason: _failure('ARC-D04', violations));
    });

    test('ARC-D05 public facade must belong to its domain root', () {
      final violations = <String>[];

      for (final ownership in domainOwnershipRegistry) {
        final expectedFacade = '${ownership.root}/${ownership.root}.dart';
        if (ownership.publicFacade != expectedFacade) {
          violations.add(
            '${ownership.domain.name}: expected "$expectedFacade", '
            'found "${ownership.publicFacade}"',
          );
        }
      }

      expect(violations, isEmpty, reason: _failure('ARC-D05', violations));
    });

    test('ARC-D06 approved Mentora ownership domains must be registered', () {
      const requiredDomains = <MentoraDomain>{
        MentoraDomain.identity,
        MentoraDomain.expert,
        MentoraDomain.discovery,
        MentoraDomain.scheduling,
        MentoraDomain.booking,
        MentoraDomain.payment,
        MentoraDomain.consultation,
        MentoraDomain.review,
        MentoraDomain.financial,
        MentoraDomain.automation,
        MentoraDomain.meeting,
        MentoraDomain.notification,
      };

      final registeredDomains = domainOwnershipRegistry
          .map((ownership) => ownership.domain)
          .toSet();

      final missing = requiredDomains.difference(registeredDomains).toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      expect(
        missing,
        isEmpty,
        reason: _failure(
          'ARC-D06',
          missing.map((domain) => domain.name).toList(),
        ),
      );
    });

    test('ARC-D07 ownershipForRoot resolves every registered root', () {
      final violations = <String>[];

      for (final ownership in domainOwnershipRegistry) {
        final resolved = ownershipForRoot(ownership.root);

        if (resolved == null || resolved.domain != ownership.domain) {
          violations.add(ownership.root);
        }
      }

      expect(violations, isEmpty, reason: _failure('ARC-D07', violations));
    });

    test('ARC-D08 unknown roots must not resolve to a domain', () {
      expect(ownershipForRoot('__unknown_domain__'), isNull);
    });
  });
}

String _failure(String rule, List<String> violations) {
  if (violations.isEmpty) {
    return '';
  }

  final buffer = StringBuffer()
    ..writeln('$rule failed.')
    ..writeln('Violation(s):');

  for (final violation in violations) {
    buffer.writeln(' - $violation');
  }

  return buffer.toString();
}
