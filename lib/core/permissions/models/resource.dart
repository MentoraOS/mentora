abstract class Resource {
  String get id;

  String get type;

  String? get ownerId;

  String? get workspaceId;

  String? get organizationId;
}
