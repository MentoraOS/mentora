class MentoraContext {
  MentoraContext._();

  static String? currentUserId;
  static String? currentWorkspaceId;
  static String? currentOrganizationId;
  static String? currentEmployeeId;
  static String? currentRole;

  static void setUser(String userId) {
    currentUserId = userId;
  }

  static void setWorkspace(String workspaceId) {
    currentWorkspaceId = workspaceId;
  }

  static void setOrganization(String organizationId) {
    currentOrganizationId = organizationId;
  }

  static void setEmployee(String employeeId) {
    currentEmployeeId = employeeId;
  }

  static void setRole(String role) {
    currentRole = role;
  }

  static void clear() {
    currentUserId = null;
    currentWorkspaceId = null;
    currentOrganizationId = null;
    currentEmployeeId = null;
    currentRole = null;
  }
}
