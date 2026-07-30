class OrganizationHierarchy {
  final String organizationId;
  final Map<String, String> managerByEmployeeId;

  const OrganizationHierarchy({
    required this.organizationId,
    required this.managerByEmployeeId,
  });

  String? managerOf(String employeeId) {
    return managerByEmployeeId[employeeId];
  }

  List<String> directReportsOf(String managerId) {
    return managerByEmployeeId.entries
        .where((entry) => entry.value == managerId)
        .map((entry) => entry.key)
        .toList();
  }
}
