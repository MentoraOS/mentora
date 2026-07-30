class Certificate {
  final String id;

  final String userId;
  final String courseId;

  final String title;

  final DateTime issuedAt;

  final String verificationCode;

  final String pdfUrl;

  const Certificate({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.title,
    required this.issuedAt,
    required this.verificationCode,
    required this.pdfUrl,
  });
}
