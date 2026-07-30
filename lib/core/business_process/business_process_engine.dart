import 'business_process.dart';
import 'business_process_result.dart';

class BusinessProcessEngine {
  BusinessProcessEngine._();

  static Future<BusinessProcessResult<T>> execute<T>(
    BusinessProcess<BusinessProcessResult<T>> process,
  ) async {
    try {
      return await process.run();
    } catch (error) {
      return BusinessProcessResult.failure(message: error.toString());
    }
  }
}
