import 'token_provider.dart';
import 'token_registry.dart';

/// One domain line of the coverage report.
final class DomainCoverage {
  final String label;
  final String namePrefix;
  final int expected;

  const DomainCoverage({
    required this.label,
    required this.namePrefix,
    required this.expected,
  });
}

/// The official Phase 1 coverage specification (71 tokens).
const List<DomainCoverage> phase1Coverage = [
  DomainCoverage(label: 'Color', namePrefix: 'color.', expected: 27),
  DomainCoverage(label: 'Typography', namePrefix: 'typography.', expected: 27),
  DomainCoverage(label: 'Spacing', namePrefix: 'spacing.', expected: 8),
  DomainCoverage(label: 'Surface', namePrefix: 'surface.', expected: 5),
  DomainCoverage(label: 'Elevation', namePrefix: 'elevation.', expected: 4),
];

/// The automatic coverage report of the binding state.
final class BindingIntegrityReport {
  final Map<String, ({int expected, int registered, int bound})> perDomain;
  final List<String> orphanTokens;
  final List<String> deprecatedTokens;
  final int hardcodedValues;

  const BindingIntegrityReport({
    required this.perDomain,
    required this.orphanTokens,
    required this.deprecatedTokens,
    required this.hardcodedValues,
  });

  int get expectedTotal =>
      perDomain.values.fold(0, (sum, d) => sum + d.expected);

  int get boundTotal => perDomain.values.fold(0, (sum, d) => sum + d.bound);

  bool get isComplete =>
      boundTotal == expectedTotal &&
      perDomain.values.every((d) => d.registered == d.expected) &&
      orphanTokens.isEmpty &&
      deprecatedTokens.isEmpty &&
      hardcodedValues == 0;

  /// The official report format.
  String get formatted {
    final buffer = StringBuffer();
    for (final entry in perDomain.entries) {
      buffer.writeln('${entry.key} :');
      buffer.writeln('${entry.value.bound} / ${entry.value.expected}');
      buffer.writeln();
    }
    buffer.writeln('Coverage :');
    buffer.writeln('$boundTotal / $expectedTotal');
    buffer.writeln();
    buffer.writeln('Hardcoded Values :');
    buffer.writeln('$hardcodedValues');
    buffer.writeln();
    buffer.writeln('Deprecated Tokens :');
    buffer.writeln('${deprecatedTokens.length}');
    buffer.writeln();
    buffer.writeln('Orphan Tokens :');
    buffer.writeln('${orphanTokens.length}');
    return buffer.toString();
  }
}

/// Raised when the binding state violates the coverage contract —
/// fail closed: an incomplete or polluted state never ships.
final class BindingIntegrityFailure implements Exception {
  final BindingIntegrityReport report;

  const BindingIntegrityFailure(this.report);

  @override
  String toString() => 'BindingIntegrityFailure:\n${report.formatted}';
}

/// The Binding Integrity Engine — produces the automatic coverage
/// report and refuses any violation.
///
/// `hardcodedValues` is fed by the source-scan tooling (the executable
/// governance scans shipped with the code): the engine consolidates,
/// the scans detect.
final class BindingIntegrityEngine {
  const BindingIntegrityEngine();

  BindingIntegrityReport report({
    required DesignTokenRegistry registry,
    required DesignTokenProvider provider,
    List<DomainCoverage> coverage = phase1Coverage,
    int hardcodedValues = 0,
  }) {
    final perDomain = <String, ({int expected, int registered, int bound})>{};
    for (final domain in coverage) {
      var registered = 0;
      var bound = 0;
      for (final identity in registry.identities) {
        if (!identity.name.startsWith(domain.namePrefix)) continue;
        registered++;
        if (provider.isBound(identity.name)) bound++;
      }
      perDomain[domain.label] = (
        expected: domain.expected,
        registered: registered,
        bound: bound,
      );
    }

    final orphans = <String>[];
    final deprecated = <String>[];
    for (final identity in registry.identities) {
      if (!identity.isConsumable) {
        if (provider.isBound(identity.name)) deprecated.add(identity.name);
        continue;
      }
      if (!provider.isBound(identity.name)) orphans.add(identity.name);
    }

    return BindingIntegrityReport(
      perDomain: perDomain,
      orphanTokens: orphans,
      deprecatedTokens: deprecated,
      hardcodedValues: hardcodedValues,
    );
  }

  /// Fail closed: throws [BindingIntegrityFailure] on any violation.
  BindingIntegrityReport verify({
    required DesignTokenRegistry registry,
    required DesignTokenProvider provider,
    List<DomainCoverage> coverage = phase1Coverage,
    int hardcodedValues = 0,
  }) {
    final result = report(
      registry: registry,
      provider: provider,
      coverage: coverage,
      hardcodedValues: hardcodedValues,
    );
    if (!result.isComplete) {
      throw BindingIntegrityFailure(result);
    }
    return result;
  }
}
