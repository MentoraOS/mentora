class BusinessPipelineResult {
  final bool success;
  final String? message;

  const BusinessPipelineResult.success({this.message}) : success = true;

  const BusinessPipelineResult.failure({this.message}) : success = false;
}
