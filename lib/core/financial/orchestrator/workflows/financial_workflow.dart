abstract interface class FinancialWorkflow<TContext, TResult> {
  String get key;

  Future<TResult> execute(TContext context);
}
