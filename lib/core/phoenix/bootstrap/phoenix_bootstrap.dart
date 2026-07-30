import '../../events/engine/phoenix_event_bus.dart';

import '../../notification/domains/notification_domain.dart';
import '../../notification/engine/notification_engine.dart';
import '../../notification/factories/notification_factory.dart';
import '../../notification/listeners/booking_notification_listener.dart';
import '../../notification/registry/notification_strategy_registry.dart';
import '../../notification/repositories/memory_notification_repository.dart';
import '../../notification/strategies/booking_confirmed_strategy.dart';
import '../../notification/templates/booking_confirmed_template.dart';
import '../../notification/templates/notification_template_registry.dart';

import '../../payment/domains/payment_domain.dart';
import '../../payment/engine/payment_engine.dart';
import '../../payment/repositories/memory_payment_repository.dart';

import '../../pricing/domains/pricing_domain.dart';
import '../../pricing/engine/pricing_engine.dart';

import '../orchestrator/engine/phoenix_orchestrator.dart';
import '../orchestrator/listeners/phoenix_orchestrator_listener.dart';
import '../orchestrator/pipelines/booking_pipeline_builder.dart';
import '../orchestrator/registry/orchestration_rule_registry.dart';
import '../orchestrator/registry/pipeline_registry.dart';
import '../orchestrator/rules/booking_confirmed_rule.dart';
import '../orchestrator/services/booking_orchestration_service.dart';

import 'package:mentora/core/financial/bootstrap/financial_module.dart';

import 'package:mentora/core/financial/orchestrator/'
    'financial_orchestrator.dart';
import 'package:mentora/core/financial/orchestrator/registry/'
    'financial_workflow_registry.dart';

import 'package:mentora/core/financial/ledger/balance/'
    'balance_engine.dart';

import 'package:mentora/core/financial/ledger/chart/'
    'account_registry.dart';
import 'package:mentora/core/financial/ledger/chart/'
    'chart_of_accounts.dart';

import 'package:mentora/core/financial/ledger/engine/'
    'ledger_engine.dart';

import 'package:mentora/core/financial/ledger/posting/builders/'
    'ledger_posting_builder.dart';
import 'package:mentora/core/financial/ledger/posting/engine/'
    'posting_engine.dart';
import 'package:mentora/core/financial/ledger/posting/templates/'
    'payment_posting_templates.dart';

import 'package:mentora/core/financial/ledger/repositories/'
    'memory_ledger_repository.dart';

import 'package:mentora/core/financial/ledger/journal/repository/'
    'memory_ledger_journal_repository.dart';

import 'package:mentora/core/financial/ledger/journal/reporting/'
    'ledger_general_ledger_engine.dart';
import 'package:mentora/core/financial/ledger/journal/reporting/'
    'ledger_journal_reporting_engine.dart';
import 'package:mentora/core/financial/ledger/journal/reporting/'
    'ledger_trial_balance_engine.dart';

import 'package:mentora/core/financial/ledger/validation/ledger_journal_validator.dart';

import 'package:mentora/core/financial/ledger/journal/reversal/service/ledger_journal_reversal_service.dart';

import 'package:mentora/core/financial/ledger/journal/reversal/ledger_journal_reversal_builder.dart';

import 'package:mentora/core/financial/ledger/journal/engine/ledger_journal_engine.dart';

import 'package:mentora/core/financial/ledger/journal/posting/ledger_journal_factory.dart';

import 'package:mentora/core/financial/ledger/journal/posting/ledger_journal_posting_bridge.dart';

import 'package:mentora/core/financial/pipeline/recovery/engine/financial_recovery_engine.dart';

import 'package:mentora/core/financial/pipeline/recovery/strategies/financial_recovery_strategy_registry.dart';

import 'package:mentora/core/financial/pipeline/recovery/strategies/recover_ledger_journal_posting_strategy.dart';

class PhoenixBootstrap {
  PhoenixBootstrap._();

  static bool _initialized = false;

  // ---------------------------------------------------------------------------
  // Core ledger infrastructure
  // ---------------------------------------------------------------------------

  static late AccountRegistry accountRegistry;
  static late ChartOfAccounts chartOfAccounts;

  /// Transaction-oriented ledger repository used by LedgerEngine.
  static late MemoryLedgerRepository ledgerRepository;

  static late LedgerEngine ledgerEngine;
  static late BalanceEngine balanceEngine;

  static late LedgerPostingBuilder ledgerPostingBuilder;
  static late PostingEngine postingEngine;

  static late MemoryLedgerJournalRepository journalRepository;

  static late LedgerJournalValidator journalValidator;

  static late LedgerJournalReversalBuilder reversalBuilder;

  static late LedgerJournalReversalService reversalService;

  static late LedgerJournalEngine journalEngine;

  static late LedgerJournalFactory journalFactory;

  static late LedgerJournalPostingBridge journalPostingBridge;

  // ---------------------------------------------------------------------------
  // Journal reporting infrastructure
  // ---------------------------------------------------------------------------

  /// Journal-oriented repository used by reporting projections.

  static late LedgerTrialBalanceEngine ledgerTrialBalanceEngine;

  static late LedgerGeneralLedgerEngine ledgerGeneralLedgerEngine;

  static late LedgerJournalReportingEngine ledgerJournalReportingEngine;

  // ---------------------------------------------------------------------------
  // Financial module
  // ---------------------------------------------------------------------------

  static late FinancialModule financialModule;

  // ---------------------------------------------------------------------------
  // Notification infrastructure
  // ---------------------------------------------------------------------------

  static late NotificationEngine notificationEngine;

  static late NotificationStrategyRegistry notificationStrategyRegistry;

  static late NotificationTemplateRegistry notificationTemplateRegistry;

  static late NotificationFactory notificationFactory;

  // ---------------------------------------------------------------------------
  // Phoenix orchestration
  // ---------------------------------------------------------------------------

  // These fields must not be final because reset() allows reinitialization.
  static late PhoenixOrchestrator orchestrator;

  static late OrchestrationRuleRegistry orchestrationRuleRegistry;

  // ---------------------------------------------------------------------------
  // Public lifecycle
  // ---------------------------------------------------------------------------

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    PhoenixEventBus.clear();

    _initializeOrchestrator();
    _initializeNotification();

    _initializeFinancialInfrastructure();
    _initializeFinancial();

    _initialized = true;
  }

  static bool get isInitialized => _initialized;

  // ---------------------------------------------------------------------------
  // Financial infrastructure
  // ---------------------------------------------------------------------------

  static void _initializeFinancialInfrastructure() {
    /*
   * Shared account infrastructure.
   *
   * Every Ledger and Journal component receives the same
   * ChartOfAccounts instance.
   */
    final initializedAccountRegistry = AccountRegistry();

    final initializedChartOfAccounts = ChartOfAccounts(
      registry: initializedAccountRegistry,
    );

    initializedChartOfAccounts.initializeCurrency('XOF');

    /*
   * Transaction-oriented Ledger infrastructure.
   */
    final initializedLedgerRepository = MemoryLedgerRepository();

    final initializedPaymentTemplates = PaymentPostingTemplates(
      chartOfAccounts: initializedChartOfAccounts,
    );

    final initializedLedgerEngine = LedgerEngine(
      chartOfAccounts: initializedChartOfAccounts,
      repository: initializedLedgerRepository,
    );

    final initializedBalanceEngine = BalanceEngine(
      chartOfAccounts: initializedChartOfAccounts,
      repository: initializedLedgerRepository,
    );

    final initializedLedgerPostingBuilder = LedgerPostingBuilder(
      paymentTemplates: initializedPaymentTemplates,
    );

    final initializedPostingEngine = PostingEngine(
      builder: initializedLedgerPostingBuilder,
      ledgerEngine: initializedLedgerEngine,
      balanceEngine: initializedBalanceEngine,
    );

    /*
   * Single Journal source of truth.
   *
   * This exact repository instance is shared by:
   * - LedgerJournalEngine;
   * - LedgerJournalValidator;
   * - LedgerJournalReversalService;
   * - LedgerJournalPostingBridge;
   * - LedgerTrialBalanceEngine;
   * - LedgerGeneralLedgerEngine;
   * - LedgerJournalReportingEngine.
   */
    final initializedJournalRepository = MemoryLedgerJournalRepository();

    final initializedJournalValidator = LedgerJournalValidator(
      chartOfAccounts: initializedChartOfAccounts,
      repository: initializedJournalRepository,
    );

    const initializedReversalBuilder = LedgerJournalReversalBuilder();

    final initializedReversalService = LedgerJournalReversalService(
      repository: initializedJournalRepository,
      validator: initializedJournalValidator,
      builder: initializedReversalBuilder,
    );

    final initializedJournalEngine = LedgerJournalEngine(
      repository: initializedJournalRepository,
      validator: initializedJournalValidator,
      reversalService: initializedReversalService,
    );

    const initializedJournalFactory = LedgerJournalFactory();

    final initializedJournalPostingBridge = LedgerJournalPostingBridge(
      postingEngine: initializedPostingEngine,
      journalFactory: initializedJournalFactory,
      journalEngine: initializedJournalEngine,
    );

    /*
   * Reporting projections read from the same repository
   * written by LedgerJournalPostingBridge.
   */
    final initializedTrialBalanceEngine = LedgerTrialBalanceEngine(
      repository: initializedJournalRepository,
    );

    final initializedGeneralLedgerEngine = LedgerGeneralLedgerEngine(
      repository: initializedJournalRepository,
      chartOfAccounts: initializedChartOfAccounts,
    );

    final initializedReportingEngine = LedgerJournalReportingEngine(
      repository: initializedJournalRepository,
      trialBalanceEngine: initializedTrialBalanceEngine,
      generalLedgerEngine: initializedGeneralLedgerEngine,
    );

    /*
   * Publish the complete infrastructure only after every
   * dependency has been assembled successfully.
   */
    accountRegistry = initializedAccountRegistry;

    chartOfAccounts = initializedChartOfAccounts;

    ledgerRepository = initializedLedgerRepository;

    ledgerEngine = initializedLedgerEngine;

    balanceEngine = initializedBalanceEngine;

    ledgerPostingBuilder = initializedLedgerPostingBuilder;

    postingEngine = initializedPostingEngine;

    journalRepository = initializedJournalRepository;

    journalValidator = initializedJournalValidator;

    reversalBuilder = initializedReversalBuilder;

    reversalService = initializedReversalService;

    journalEngine = initializedJournalEngine;

    journalFactory = initializedJournalFactory;

    journalPostingBridge = initializedJournalPostingBridge;

    ledgerTrialBalanceEngine = initializedTrialBalanceEngine;

    ledgerGeneralLedgerEngine = initializedGeneralLedgerEngine;

    ledgerJournalReportingEngine = initializedReportingEngine;
  }

  static void _initializeFinancial() {
    financialModule = FinancialModule.initialize(
      journalPostingBridge: journalPostingBridge,
      reportingEngine: ledgerJournalReportingEngine,
      ledgerRepository: ledgerRepository,
      journalEngine: journalEngine,
      journalFactory: journalFactory,
      executionIdFactory: (context) {
        return 'execution-${context.operationId}';
      },
      correlationIdFactory: (context) {
        return context.operationId;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Financial public accessors
  // ---------------------------------------------------------------------------

  static FinancialOrchestrator get financialOrchestrator {
    return financialModule.orchestrator;
  }

  static FinancialWorkflowRegistry get financialWorkflowRegistry {
    return financialModule.workflowRegistry;
  }

  static FinancialRecoveryEngine get financialRecoveryEngine {
    return financialModule.recoveryEngine;
  }

  static FinancialRecoveryStrategyRegistry
  get financialRecoveryStrategyRegistry {
    return financialModule.recoveryStrategyRegistry;
  }

  static RecoverLedgerJournalPostingStrategy
  get ledgerJournalPostingRecoveryStrategy {
    final strategy = financialModule.recoverLedgerJournalPostingStrategy;

    if (strategy == null) {
      throw StateError(
        'Ledger journal posting recovery '
        'strategy is not initialized.',
      );
    }

    return strategy;
  }

  static LedgerJournalReportingEngine get financialReportingEngine {
    return ledgerJournalReportingEngine;
  }

  // ---------------------------------------------------------------------------
  // Notification infrastructure
  // ---------------------------------------------------------------------------

  static void _initializeNotification() {
    final repository = MemoryNotificationRepository();

    final domain = NotificationDomain(repository: repository);

    notificationEngine = NotificationEngine(domain: domain);

    notificationStrategyRegistry = NotificationStrategyRegistry();

    notificationStrategyRegistry.register(
      'booking.confirmed',
      const BookingConfirmedStrategy(),
    );

    notificationTemplateRegistry = NotificationTemplateRegistry();

    notificationTemplateRegistry.registerTemplate(
      const BookingConfirmedTemplate(),
    );

    notificationFactory = NotificationFactory(
      templateRegistry: notificationTemplateRegistry,
    );

    PhoenixEventBus.register(
      BookingNotificationListener(
        engine: notificationEngine,
        factory: notificationFactory,
        registry: notificationStrategyRegistry,
      ),
    );

    PhoenixEventBus.register(
      PhoenixOrchestratorListener(orchestrator: orchestrator),
    );
  }

  // ---------------------------------------------------------------------------
  // Phoenix orchestration infrastructure
  // ---------------------------------------------------------------------------

  static void _initializeOrchestrator() {
    orchestrationRuleRegistry = OrchestrationRuleRegistry();

    final pricingDomain = PricingDomain();

    final paymentRepository = MemoryPaymentRepository();

    final paymentDomain = PaymentDomain(repository: paymentRepository);

    final paymentEngine = PaymentEngine(domain: paymentDomain);

    final pricingEngine = PricingEngine(domain: pricingDomain);

    final pipelineRegistry = PipelineRegistry();

    final bookingPipeline = BookingPipelineBuilder(
      pricingEngine: pricingEngine,
      paymentEngine: paymentEngine,
    ).build();

    pipelineRegistry.registerPipeline('booking.confirmed', bookingPipeline);

    final service = BookingOrchestrationService(
      pipelineRegistry: pipelineRegistry,
    );

    orchestrationRuleRegistry.registerRule(
      'booking.confirmed',
      BookingConfirmedRule(service: service),
    );

    orchestrator = PhoenixOrchestrator(registry: orchestrationRuleRegistry);
  }

  // ---------------------------------------------------------------------------
  // Reset
  // ---------------------------------------------------------------------------

  static void reset() {
    PhoenixEventBus.clear();
    _initialized = false;
  }
}
