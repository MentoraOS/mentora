import 'financial_allocation.dart';
import 'financial_allocation_request.dart';
import 'financial_allocation_result.dart';

/// Predicate operating on an allocation request.
typedef AllocationRequestPredicate<T> =
    bool Function(FinancialAllocationRequest<T> request);

/// Mapper operating on an allocation request.
typedef AllocationRequestMapper<T, R> =
    R Function(FinancialAllocationRequest<T> request);

/// Predicate operating on an allocation.
typedef AllocationPredicate<T> =
    bool Function(FinancialAllocation<T> allocation);

/// Mapper operating on an allocation.
typedef AllocationMapper<T, R> = R Function(FinancialAllocation<T> allocation);

/// Predicate operating on an allocation result.
typedef AllocationResultPredicate<T> =
    bool Function(FinancialAllocationResult<T> result);

/// Mapper operating on an allocation result.
typedef AllocationResultMapper<T, R> =
    R Function(FinancialAllocationResult<T> result);
