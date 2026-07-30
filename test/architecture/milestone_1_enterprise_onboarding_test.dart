import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/business_process/business_process_engine.dart';
import 'package:mentora/core/business_process/processes/enterprise_onboarding_process.dart';
import 'package:mentora/core/enterprise/models/employee.dart';
import 'package:mentora/core/enterprise/models/enterprise_workspace.dart';
import 'package:mentora/core/enterprise/models/organization.dart';
import 'package:mentora/core/events/engine/phoenix_engine.dart';
import 'package:mentora/core/di/service_locater.dart';
import 'package:mentora/core/enterprise/engine/atlas_engine.dart';
import 'package:mentora/core/workflow/workflow_context.dart';

void main() {
  group('Mentora OS Milestone 1 - Enterprise Onboarding', () {
    test(
      'should create workspace, organization, owner and publish events',
      () async {
        ServiceLocator.setupForTests();

        await PhoenixEngine.instance.initialize();
        await AtlasEngine.instance.initialize();

        final workspace = EnterpriseWorkspace(
          id: 'test_workspace',
          name: 'Test Workspace',
          ownerId: 'user_test',
          country: 'Mali',
          currency: 'XOF',
          timezone: 'Africa/Bamako',
          plan: 'enterprise',
          maxOrganizations: 5,
          maxEmployees: 100,
          createdAt: DateTime.now(),
        );

        final organization = Organization(
          id: 'test_org',
          name: 'Test Organization',
          legalName: 'Test Organization SARL',
          logoUrl: '',
          industry: 'Technology',
          country: 'Mali',
          city: 'Bamako',
          timezone: 'Africa/Bamako',
          currency: 'XOF',
          emailDomain: 'test.com',
          employeeCount: 1,
          verified: true,
          createdAt: DateTime.now(),
        );

        final owner = Employee(
          id: 'owner_001',
          organizationId: 'test_org',
          departmentId: '',
          teamId: '',
          managerId: '',
          firstName: 'CEO',
          lastName: 'Mentora',
          email: 'ceo@test.com',
          phone: '+22300000000',
          position: 'Founder',
          photoUrl: '',
          hireDate: DateTime.now(),
        );

        final context = WorkflowContext(
          userId: 'user_test',
          workspaceId: 'test_workspace',
        );

        final result = await BusinessProcessEngine.execute<void>(
          EnterpriseOnboardingProcess(
            workspace: workspace,
            organization: organization,
            owner: owner,
            context: context,
          ),
        );

        expect(result.success, isTrue);

        final events = PhoenixEngine.history();

        expect(events.isNotEmpty, isTrue);
        expect(
          events.any(
            (event) => event.payload['workspaceId'] == 'test_workspace',
          ),
          isTrue,
        );
        expect(
          events.any((event) => event.payload['organizationId'] == 'test_org'),
          isTrue,
        );
      },
    );
  });
}
