import 'financial_rate.dart';

typedef RatePredicate<T extends FinancialRate> = bool Function(T rate);

typedef RateMapper<T extends FinancialRate, R> = R Function(T rate);
