class BusinessProcessResult<T> {
  final T? data;
  final String? message;
  final bool success;

  const BusinessProcessResult.success({this.data, this.message})
    : success = true;

  const BusinessProcessResult.failure({this.message})
    : data = null,
      success = false;
}
