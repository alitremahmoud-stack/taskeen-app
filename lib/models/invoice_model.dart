class Invoice {
  final int? id;
  final int userId;
  final int projectId;
  final double amount;
  final String date;
  final String status;
  final String description;

  Invoice({
    this.id,
    required this.userId,
    required this.projectId,
    required this.amount,
    required this.date,
    required this.status,
    required this.description,
  });

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      userId: map['user_id'],
      projectId: map['project_id'],
      amount: map['amount'],
      date: map['date'],
      status: map['status'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'project_id': projectId,
      'amount': amount,
      'date': date,
      'status': status,
      'description': description,
    };
  }
}
