import 'package:mentora/core/workflow/registry/workflow_registry.dart';

import '../models/department.dart';
import '../models/employee.dart';
import '../models/organization.dart';
import '../models/team.dart';
import '../repository/department_repository.dart';
import '../repository/employee_repository.dart';
import '../repository/organization_repository.dart';
import '../repository/team_repository.dart';
import '../models/organization_hierarchy.dart';
import '../repository/organization_hierarchy_repository.dart';
import '../models/enterprise_membership.dart';
import '../repository/enterprise_membership_repository.dart';
import '../models/enterprise_statistics.dart';
import '../../engines/base_engine.dart';
import '../../di/service_locater.dart';
import '../../services/logger_service.dart';
import '../../events/engine/phoenix_engine.dart';
import '../../events/models/event_type.dart';
import '../../events/services/event_builder.dart';
import '../../events/models/event_context.dart';
import '../models/enterprise_role.dart';
import '../models/enterprise_permission.dart';
import '../repository/enterprise_role_repository.dart';
import '../repository/enterprise_permission_repository.dart';
import '../domains/organization_domain.dart';
import '../domains/employee_domain.dart';
import '../domains/department_domain.dart';
import '../domains/team_domain.dart';
import '../domains/workspace_domain.dart';
import '../models/enterprise_workspace.dart';
import '../repository/enterprise_workspace_repository.dart';
import '../domains/enterprise_domain.dart';
import '../domains/project_domain.dart';
import '../models/enterprise_project.dart';
import '../domains/task_domain.dart';
import '../models/enterprise_task.dart';

import '../../workflow/workflow_context.dart';

class AtlasEngine extends BaseEngine {
  AtlasEngine._();

  static final AtlasEngine _instance = AtlasEngine._();

  static AtlasEngine get instance => _instance;

  bool _initialized = false;

  static Organization? _currentOrganization;
  static Department? _currentDepartment;
  static Team? _currentTeam;
  static Employee? _currentEmployee;

  static EnterpriseWorkspace? _currentEnterpriseWorkspace;

  static EnterpriseWorkspace? get currentEnterpriseWorkspace =>
      _currentEnterpriseWorkspace;

  late final OrganizationDomain organization = OrganizationDomain(this);
  late final EmployeeDomain employee = EmployeeDomain(this);
  late final DepartmentDomain department = DepartmentDomain(this);
  late final TeamDomain team = TeamDomain(this);
  late final WorkspaceDomain workspace = WorkspaceDomain(this);
  late final EnterpriseDomain enterprise = EnterpriseDomain(this);
  late final ProjectDomain project = ProjectDomain(this);
  late final TaskDomain task = TaskDomain(this);

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    final logger = ServiceLocator.get<LoggerService>();

    logger.info('Atlas Enterprise Engine initialized');

    _initialized = true;

    await super.initialize();
  }

  Future<void> onboardEmployee({
    required Employee employee,
    required WorkflowContext context,
  }) async {
    await WorkflowRegistry.employeeOnboarding(
      employee: employee,
      context: context,
    );
  }

  void publishEnterpriseEvent({
    required EventType type,
    required String userId,
    Map<String, dynamic>? metadata,
  }) {
    PhoenixEngine.publish(
      EventBuilder.create(
        type: type,
        source: 'Atlas',
        context: EventContext(
          userId: userId,
          organizationId: _currentOrganization?.id,
        ),
        payload: metadata ?? {},
      ),
    );
  }

  Future<void> projectCreated({
    required EnterpriseProject project,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.projectCreated,
      userId: userId,
      metadata: {
        'projectId': project.id,
        'projectName': project.name,
        'workspaceId': project.workspaceId,
        'organizationId': project.organizationId,
        'departmentId': project.departmentId,
        'ownerId': project.ownerId,
      },
    );

    ServiceLocator.get<LoggerService>().info(
      'Project created: ${project.name}',
    );
  }

  Future<void> projectUpdated({
    required EnterpriseProject project,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.projectUpdated,
      userId: userId,
      metadata: {'projectId': project.id, 'projectName': project.name},
    );

    ServiceLocator.get<LoggerService>().info(
      'Project updated: ${project.name}',
    );
  }

  Future<void> projectArchived({
    required EnterpriseProject project,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.projectArchived,
      userId: userId,
      metadata: {'projectId': project.id, 'projectName': project.name},
    );

    ServiceLocator.get<LoggerService>().warning(
      'Project archived: ${project.name}',
    );
  }

  Future<void> workspaceUpdated({
    required EnterpriseWorkspace workspace,
    required String userId,
  }) async {
    _currentEnterpriseWorkspace = workspace;

    publishEnterpriseEvent(
      type: EventType.workspaceUpdated,
      userId: userId,
      metadata: {
        'workspaceId': workspace.id,
        'workspaceName': workspace.name,
        'plan': workspace.plan,
      },
    );

    ServiceLocator.get<LoggerService>().info(
      'Workspace updated: ${workspace.name}',
    );
  }

  Future<void> workspaceSuspended({
    required EnterpriseWorkspace workspace,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.workspaceSuspended,
      userId: userId,
      metadata: {'workspaceId': workspace.id, 'workspaceName': workspace.name},
    );

    ServiceLocator.get<LoggerService>().warning(
      'Workspace suspended: ${workspace.name}',
    );
  }

  Future<void> workspaceArchived({
    required EnterpriseWorkspace workspace,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.workspaceArchived,
      userId: userId,
      metadata: {'workspaceId': workspace.id, 'workspaceName': workspace.name},
    );

    ServiceLocator.get<LoggerService>().warning(
      'Workspace archived: ${workspace.name}',
    );
  }

  Future<void> workspaceCreated({
    required EnterpriseWorkspace workspace,
    required String userId,
  }) async {
    _currentEnterpriseWorkspace = workspace;

    publishEnterpriseEvent(
      type: EventType.workspaceCreated,
      userId: userId,
      metadata: {
        'workspaceId': workspace.id,
        'workspaceName': workspace.name,
        'ownerId': workspace.ownerId,
        'plan': workspace.plan,
      },
    );

    ServiceLocator.get<LoggerService>().info(
      'Workspace created: ${workspace.name}',
    );
  }

  Future<void> taskCreated({
    required EnterpriseTask task,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.taskCreated,
      userId: userId,
      metadata: {
        'taskId': task.id,
        'taskTitle': task.title,
        'projectId': task.projectId,
        'workspaceId': task.workspaceId,
        'organizationId': task.organizationId,
        'assignedTo': task.assignedToId,
        'priority': task.priority.name,
      },
    );

    ServiceLocator.get<LoggerService>().info('Task created: ${task.title}');
  }

  Future<void> taskUpdated({
    required EnterpriseTask task,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.taskUpdated,
      userId: userId,
      metadata: {'taskId': task.id, 'status': task.status.name},
    );

    ServiceLocator.get<LoggerService>().info('Task updated: ${task.title}');
  }

  Future<void> taskCompleted({
    required EnterpriseTask task,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.taskCompleted,
      userId: userId,
      metadata: {'taskId': task.id, 'projectId': task.projectId},
    );

    ServiceLocator.get<LoggerService>().info('Task completed: ${task.title}');
  }

  Future<void> organizationCreated({
    required Organization organization,
    required String userId,
  }) async {
    _currentOrganization = organization;

    publishEnterpriseEvent(
      type: EventType.organizationCreated,
      userId: userId,
      metadata: {
        'organizationId': organization.id,
        'organizationName': organization.name,
      },
    );

    final logger = ServiceLocator.get<LoggerService>();
    logger.info('Organization created: ${organization.name}');
  }

  Future<void> organizationUpdated({
    required Organization organization,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.organizationUpdated,
      userId: userId,
      metadata: {
        'organizationId': organization.id,
        'organizationName': organization.name,
      },
    );

    ServiceLocator.get<LoggerService>().info(
      'Organization updated: ${organization.name}',
    );
  }

  Future<void> organizationSuspended({
    required Organization organization,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.organizationSuspended,
      userId: userId,
      metadata: {
        'organizationId': organization.id,
        'organizationName': organization.name,
      },
    );

    ServiceLocator.get<LoggerService>().warning(
      'Organization suspended: ${organization.name}',
    );
  }

  Future<void> organizationArchived({
    required Organization organization,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.organizationArchived,
      userId: userId,
      metadata: {
        'organizationId': organization.id,
        'organizationName': organization.name,
      },
    );

    ServiceLocator.get<LoggerService>().warning(
      'Organization archived: ${organization.name}',
    );
  }

  Future<void> updateOrganization({
    required Organization organization,
    required String userId,
  }) async {
    _currentOrganization = organization;

    publishEnterpriseEvent(
      type: EventType.organizationUpdated,
      userId: userId,
      metadata: {
        'organizationId': organization.id,
        'organizationName': organization.name,
      },
    );

    final logger = ServiceLocator.get<LoggerService>();

    logger.info('Organization updated: ${organization.name}');
  }

  Future<void> createDepartment({
    required Department department,
    required String userId,
  }) async {
    _currentDepartment = department;

    publishEnterpriseEvent(
      type: EventType.departmentCreated,
      userId: userId,
      metadata: {
        'organizationId': _currentOrganization?.id,
        'departmentId': department.id,
        'departmentName': department.name,
      },
    );

    final logger = ServiceLocator.get<LoggerService>();

    logger.info('Department created: ${department.name}');
  }

  Future<void> updateDepartment({
    required Department department,
    required String userId,
  }) async {
    _currentDepartment = department;

    publishEnterpriseEvent(
      type: EventType.departmentUpdated,
      userId: userId,
      metadata: {
        'organizationId': _currentOrganization?.id,
        'departmentId': department.id,
        'departmentName': department.name,
      },
    );

    ServiceLocator.get<LoggerService>().info(
      'Department updated: ${department.name}',
    );
  }

  Future<void> archiveDepartment({
    required Department department,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.departmentArchived,
      userId: userId,
      metadata: {'departmentId': department.id},
    );

    ServiceLocator.get<LoggerService>().info(
      'Department archived: ${department.name}',
    );
  }

  Future<void> createTeam({required Team team, required String userId}) async {
    _currentTeam = team;

    publishEnterpriseEvent(
      type: EventType.teamCreated,
      userId: userId,
      metadata: {
        'organizationId': _currentOrganization?.id,
        'departmentId': team.departmentId,
        'teamId': team.id,
        'teamName': team.name,
      },
    );

    ServiceLocator.get<LoggerService>().info('Team created: ${team.name}');
  }

  Future<void> updateTeam({required Team team, required String userId}) async {
    _currentTeam = team;

    publishEnterpriseEvent(
      type: EventType.teamUpdated,
      userId: userId,
      metadata: {
        'organizationId': _currentOrganization?.id,
        'departmentId': team.departmentId,
        'teamId': team.id,
        'teamName': team.name,
      },
    );

    ServiceLocator.get<LoggerService>().info('Team updated: ${team.name}');
  }

  Future<void> archiveTeam({required Team team, required String userId}) async {
    publishEnterpriseEvent(
      type: EventType.teamArchived,
      userId: userId,
      metadata: {
        'organizationId': _currentOrganization?.id,
        'departmentId': team.departmentId,
        'teamId': team.id,
        'teamName': team.name,
      },
    );

    ServiceLocator.get<LoggerService>().info('Team archived: ${team.name}');
  }

  Future<void> inviteEmployee({
    required String email,
    required String departmentId,
    required String teamId,
    required String role,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.employeeInvited,
      userId: userId,
      metadata: {
        'email': email,
        'departmentId': departmentId,
        'teamId': teamId,
        'role': role,
        'organizationId': _currentOrganization?.id,
      },
    );

    ServiceLocator.get<LoggerService>().info('Employee invited: $email');
  }

  Future<void> suspendEmployee({
    required Employee employee,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.employeeSuspended,
      userId: userId,
      metadata: {
        'employeeId': employee.id,
        'employeeName': employee.fullName,
        'organizationId': employee.organizationId,
        'departmentId': employee.departmentId,
        'teamId': employee.teamId,
      },
    );

    ServiceLocator.get<LoggerService>().warning(
      'Employee suspended: ${employee.fullName}',
    );
  }

  Future<void> transferEmployee({
    required Employee employee,
    required String newDepartmentId,
    required String newTeamId,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.employeeTransferred,
      userId: userId,
      metadata: {
        'employeeId': employee.id,
        'employeeName': employee.fullName,
        'fromDepartmentId': employee.departmentId,
        'fromTeamId': employee.teamId,
        'toDepartmentId': newDepartmentId,
        'toTeamId': newTeamId,
        'organizationId': employee.organizationId,
      },
    );

    ServiceLocator.get<LoggerService>().info(
      'Employee transferred: ${employee.fullName}',
    );
  }

  Future<void> changeEmployeeRole({
    required Employee employee,
    required String newRole,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.employeeRoleChanged,
      userId: userId,
      metadata: {
        'employeeId': employee.id,
        'employeeName': employee.fullName,
        'newRole': newRole,
        'organizationId': employee.organizationId,
        'departmentId': employee.departmentId,
        'teamId': employee.teamId,
      },
    );

    ServiceLocator.get<LoggerService>().info(
      'Employee role changed: ${employee.fullName} → $newRole',
    );
  }

  Future<void> removeEmployee({
    required Employee employee,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.employeeRemoved,
      userId: userId,
      metadata: {
        'employeeId': employee.id,
        'employeeName': employee.fullName,
        'organizationId': employee.organizationId,
        'departmentId': employee.departmentId,
        'teamId': employee.teamId,
      },
    );

    ServiceLocator.get<LoggerService>().warning(
      'Employee removed: ${employee.fullName}',
    );
  }

  Future<void> assignRole({
    required Employee employee,
    required String role,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.roleAssigned,
      userId: userId,
      metadata: {
        'employeeId': employee.id,
        'employeeName': employee.fullName,
        'role': role,
        'organizationId': employee.organizationId,
        'departmentId': employee.departmentId,
        'teamId': employee.teamId,
      },
    );

    ServiceLocator.get<LoggerService>().info(
      'Role assigned: ${employee.fullName} → $role',
    );
  }

  Future<void> grantPermission({
    required Employee employee,
    required String permission,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.permissionGranted,
      userId: userId,
      metadata: {
        'employeeId': employee.id,
        'employeeName': employee.fullName,
        'permission': permission,
        'organizationId': employee.organizationId,
      },
    );

    ServiceLocator.get<LoggerService>().info(
      'Permission granted: ${employee.fullName} → $permission',
    );
  }

  Future<void> revokePermission({
    required Employee employee,
    required String permission,
    required String userId,
  }) async {
    publishEnterpriseEvent(
      type: EventType.permissionRevoked,
      userId: userId,
      metadata: {
        'employeeId': employee.id,
        'employeeName': employee.fullName,
        'permission': permission,
        'organizationId': employee.organizationId,
      },
    );

    ServiceLocator.get<LoggerService>().warning(
      'Permission revoked: ${employee.fullName} → $permission',
    );
  }

  EnterpriseRole? roleById(String roleId) {
    return EnterpriseRoleRepository.findById(roleId);
  }

  List<EnterpriseRole> roles() {
    return EnterpriseRoleRepository.findAll();
  }

  EnterprisePermission? permissionById(String permissionId) {
    return EnterprisePermissionRepository.findById(permissionId);
  }

  List<EnterprisePermission> permissions() {
    return EnterprisePermissionRepository.findAll();
  }

  List<EnterprisePermission> permissionsByDomain(String domain) {
    return EnterprisePermissionRepository.byDomain(domain);
  }

  bool hasPermission(String permissionId) {
    final membership = currentMembership;

    if (membership == null) {
      return false;
    }

    return membership.permissions.contains(permissionId);
  }

  Future<void> employeeJoined({
    required Employee employee,
    required String userId,
  }) async {
    _currentEmployee = employee;

    publishEnterpriseEvent(
      type: EventType.employeeJoined,
      userId: userId,
      metadata: {
        'employeeId': employee.id,
        'employeeName': employee.fullName,
        'organizationId': _currentOrganization?.id,
        'departmentId': _currentDepartment?.id,
        'teamId': _currentTeam?.id,
      },
    );

    final logger = ServiceLocator.get<LoggerService>();

    logger.info('Employee joined: ${employee.fullName}');
  }

  static Organization? get currentOrganization => _currentOrganization;

  static Department? get currentDepartment => _currentDepartment;

  static Team? get currentTeam => _currentTeam;

  static Employee? get currentEmployee => _currentEmployee;

  static OrganizationHierarchy? _currentHierarchy;

  static OrganizationHierarchy? get currentHierarchy => _currentHierarchy;

  static EnterpriseMembership? _currentMembership;

  static EnterpriseMembership? get currentMembership => _currentMembership;

  static void resolveMembership({
    required String userId,
    required String workspaceId,
  }) {
    _currentMembership = EnterpriseMembershipRepository.findByUserAndWorkspace(
      userId: userId,
      workspaceId: workspaceId,
    );
    _currentEnterpriseWorkspace = EnterpriseWorkspaceRepository.findById(
      _currentMembership!.workspaceId,
    );

    if (_currentMembership == null) {
      return;
    }

    _currentOrganization = OrganizationRepository.findById(
      _currentMembership!.organizationId,
    );

    if (_currentOrganization != null) {
      _currentHierarchy = OrganizationHierarchyRepository.findByOrganization(
        _currentOrganization!.id,
      );
    }

    _currentDepartment =
        DepartmentRepository.byOrganization(
          _currentMembership!.organizationId,
        ).firstWhere(
          (department) => department.id == _currentMembership!.departmentId,
        );

    _currentTeam = TeamRepository.byDepartment(
      _currentMembership!.departmentId,
    ).firstWhere((team) => team.id == _currentMembership!.teamId);

    _currentEmployee = EmployeeRepository.findById(
      _currentMembership!.employeeId,
    );
  }

  static void openOrganization(Organization organization) {
    _currentOrganization = organization;

    _currentHierarchy = OrganizationHierarchyRepository.findByOrganization(
      organization.id,
    );
  }

  static String? managerOf(String employeeId) {
    return _currentHierarchy?.managerOf(employeeId);
  }

  static List<String> directReportsOf(String managerId) {
    return _currentHierarchy?.directReportsOf(managerId) ?? [];
  }

  static void openDepartment(Department department) {
    _currentDepartment = department;
  }

  static void openTeam(Team team) {
    _currentTeam = team;
  }

  static void openEmployee(Employee employee) {
    _currentEmployee = employee;
  }

  static List<Department> departments() {
    if (_currentOrganization == null) {
      return [];
    }

    return DepartmentRepository.byOrganization(_currentOrganization!.id);
  }

  static List<Team> teams() {
    if (_currentDepartment == null) {
      return [];
    }

    return TeamRepository.byDepartment(_currentDepartment!.id);
  }

  static List<Employee> employees() {
    if (_currentDepartment == null) {
      return [];
    }

    return EmployeeRepository.byDepartment(_currentDepartment!.id);
  }

  static EnterpriseStatistics statistics() {
    final organizations = OrganizationRepository.organizations;

    final departments = DepartmentRepository.departments;

    final teams = TeamRepository.teams;

    final employees = EmployeeRepository.employees;

    final activeEmployees = employees
        .where((employee) => employee.active)
        .length;

    final managerIds = employees
        .where((employee) => employee.managerId.isEmpty)
        .length;

    return EnterpriseStatistics(
      totalOrganizations: organizations.length,
      totalDepartments: departments.length,
      totalTeams: teams.length,
      totalEmployees: employees.length,
      activeEmployees: activeEmployees,
      totalManagers: managerIds,
    );
  }

  static void clear() {
    _currentOrganization = null;
    _currentDepartment = null;
    _currentTeam = null;
    _currentEmployee = null;
    _currentHierarchy = null;
    _currentMembership = null;
  }
}
