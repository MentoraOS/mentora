import '../../pipeline/financial_pipeline_engine.dart';

import '../engine/default_financial_runtime.dart';
import '../engine/financial_runtime.dart';

/// Composition root of the Financial Runtime subsystem.
///
/// This module assembles the Runtime around an existing
/// [FinancialPipelineEngine].
///
/// It contains no financial business logic.
///
/// Future Runtime dependencies such as:
///
/// - transaction managers;
/// - checkpoint stores;
/// - snapshot stores;
/// - recovery engines;
/// - event dispatchers;
/// - metrics;
///
/// may be introduced here without changing Runtime consumers.
final class FinancialRuntimeModule {
  const FinancialRuntimeModule._({
    required this.pipelineEngine,
    required this.runtime,
  });

  /// Existing engine responsible for executing financial pipeline steps.
  final FinancialPipelineEngine pipelineEngine;

  /// Application-level entry point for financial pipeline executions.
  final FinancialRuntime runtime;

  /// Builds the default Financial Runtime infrastructure.
  ///
  /// The exact [pipelineEngine] instance provided by the caller is reused.
  factory FinancialRuntimeModule.initialize({
    required FinancialPipelineEngine pipelineEngine,
    DateTime Function()? clock,
  }) {
    final runtime = DefaultFinancialRuntime(
      pipelineEngine: pipelineEngine,
      clock: clock,
    );

    return FinancialRuntimeModule._(
      pipelineEngine: pipelineEngine,
      runtime: runtime,
    );
  }
}
