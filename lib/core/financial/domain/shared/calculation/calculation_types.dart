/// Signature used for financial calculations returning a monetary value.
typedef MoneyCalculation<T> = T Function();

/// Signature used for integer-based financial calculations.
typedef IntegerCalculation = int Function();

/// Signature used for percentage-based calculations.
typedef PercentageCalculation<T> = T Function();
