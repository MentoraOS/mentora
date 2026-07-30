class FinancialPipelineState<TInput> {
  final String operationId;
  final TInput input;

  final DateTime startedAt;

  final Map<String, dynamic> metadata;
  final Map<String, dynamic> artifacts;

  final List<String> completedStepKeys;

  const FinancialPipelineState({
    required this.operationId,
    required this.input,
    required this.startedAt,
    this.metadata = const {},
    this.artifacts = const {},
    this.completedStepKeys = const [],
  });

  bool hasArtifact(String key) {
    return artifacts.containsKey(_normalizeKey(key));
  }

  T artifact<T>(String key) {
    final normalizedKey = _normalizeKey(key);

    if (!artifacts.containsKey(normalizedKey)) {
      throw StateError(
        'Financial pipeline artifact "$normalizedKey" was not found',
      );
    }

    final value = artifacts[normalizedKey];

    if (value is! T) {
      throw StateError(
        'Financial pipeline artifact "$normalizedKey" '
        'has type ${value.runtimeType}, expected $T',
      );
    }

    return value;
  }

  FinancialPipelineState<TInput> putArtifact({
    required String key,
    required dynamic value,
  }) {
    final normalizedKey = _normalizeKey(key);

    return copyWith(artifacts: {...artifacts, normalizedKey: value});
  }

  FinancialPipelineState<TInput> markStepCompleted(String stepKey) {
    final normalizedKey = _normalizeKey(stepKey);

    if (completedStepKeys.contains(normalizedKey)) {
      throw StateError(
        'Financial pipeline step "$normalizedKey" '
        'was already completed',
      );
    }

    return copyWith(completedStepKeys: [...completedStepKeys, normalizedKey]);
  }

  FinancialPipelineState<TInput> copyWith({
    String? operationId,
    TInput? input,
    DateTime? startedAt,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? artifacts,
    List<String>? completedStepKeys,
  }) {
    return FinancialPipelineState<TInput>(
      operationId: operationId ?? this.operationId,
      input: input ?? this.input,
      startedAt: startedAt ?? this.startedAt,
      metadata: Map<String, dynamic>.unmodifiable(metadata ?? this.metadata),
      artifacts: Map<String, dynamic>.unmodifiable(artifacts ?? this.artifacts),
      completedStepKeys: List<String>.unmodifiable(
        completedStepKeys ?? this.completedStepKeys,
      ),
    );
  }

  static String _normalizeKey(String key) {
    final normalized = key.trim().toLowerCase();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        key,
        'key',
        'Financial pipeline key cannot be empty',
      );
    }

    return normalized;
  }
}
