/// Runtime placeholder governance registry.
///
/// Sprint -1.2 / Lot E.4.
///
/// Only high-confidence placeholder patterns are enforced here.
///
/// We intentionally DO NOT globally flag:
///
/// - return false;
/// - return [];
/// - return {};
/// - return null;
/// - return 0;
///
/// Those constructs may be legitimate business behavior.
///
/// This registry focuses on explicit technical signals that usually indicate
/// unfinished, fake, demo or unsupported runtime behavior.
enum RuntimePlaceholderKind {
  unimplementedError,
  unsupportedError,
  todo,
  fixme,
  hack,
  mockRuntime,
  fakeRuntime,
  demoRuntime,
  stubRuntime,
}

final class RuntimePlaceholderRule {
  const RuntimePlaceholderRule({
    required this.kind,
    required this.pattern,
    required this.description,
  });

  final RuntimePlaceholderKind kind;

  /// Regex source.
  final String pattern;

  final String description;
}

const List<RuntimePlaceholderRule> runtimePlaceholderRegistry = [
  RuntimePlaceholderRule(
    kind: RuntimePlaceholderKind.unimplementedError,
    pattern: r'\bUnimplementedError\s*\(',
    description: 'Explicit UnimplementedError in runtime source.',
  ),

  RuntimePlaceholderRule(
    kind: RuntimePlaceholderKind.unsupportedError,
    pattern: r'\bUnsupportedError\s*\(',
    description: 'Explicit UnsupportedError in runtime source.',
  ),

  RuntimePlaceholderRule(
    kind: RuntimePlaceholderKind.todo,
    pattern: r'//\s*TODO\b|/\*\s*TODO\b',
    description: 'TODO marker in runtime source.',
  ),

  RuntimePlaceholderRule(
    kind: RuntimePlaceholderKind.fixme,
    pattern: r'//\s*FIXME\b|/\*\s*FIXME\b',
    description: 'FIXME marker in runtime source.',
  ),

  RuntimePlaceholderRule(
    kind: RuntimePlaceholderKind.hack,
    pattern: r'//\s*HACK\b|/\*\s*HACK\b',
    description: 'HACK marker in runtime source.',
  ),

  RuntimePlaceholderRule(
    kind: RuntimePlaceholderKind.mockRuntime,
    pattern: r'\bclass\s+Mock[A-Z]\w*',
    description: 'Mock implementation declared in runtime source.',
  ),

  RuntimePlaceholderRule(
    kind: RuntimePlaceholderKind.fakeRuntime,
    pattern: r'\bclass\s+Fake[A-Z]\w*',
    description: 'Fake implementation declared in runtime source.',
  ),

  RuntimePlaceholderRule(
    kind: RuntimePlaceholderKind.demoRuntime,
    pattern: r'\bclass\s+Demo[A-Z]\w*|\bmentora_demo\b',
    description: 'Demo implementation or mentora_demo runtime data.',
  ),

  RuntimePlaceholderRule(
    kind: RuntimePlaceholderKind.stubRuntime,
    pattern: r'\bclass\s+Stub[A-Z]\w*',
    description: 'Stub implementation declared in runtime source.',
  ),
];
