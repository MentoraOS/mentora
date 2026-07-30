class EnterpriseInvitation {
  final String id;

  final String workspaceId;
  final String workspaceName;

  final String senderId;
  final String receiverEmail;
  final String? receiverUserId;

  final String role;
  final String department;

  final String status;

  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? expiresAt;

  const EnterpriseInvitation({
    required this.id,
    required this.workspaceId,
    required this.workspaceName,
    required this.senderId,
    required this.receiverEmail,
    this.receiverUserId,
    required this.role,
    required this.department,
    required this.status,
    this.createdAt,
    this.acceptedAt,
    this.rejectedAt,
    this.expiresAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isExpired => status == 'expired';

  bool get hasReceiverUser =>
      receiverUserId != null && receiverUserId!.isNotEmpty;
}
