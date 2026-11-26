enum OpportunityStatus { saved, applied, interviewing, archived }

extension OpportunityStatusLabel on OpportunityStatus {
  String get label {
    switch (this) {
      case OpportunityStatus.saved:
        return 'Saved';
      case OpportunityStatus.applied:
        return 'Applied';
      case OpportunityStatus.interviewing:
        return 'Interviewing';
      case OpportunityStatus.archived:
        return 'Archived';
    }
  }
}

class Opportunity {
  const Opportunity({
    required this.id,
    required this.title,
    required this.platform,
    required this.createdAt,
    this.budget = '',
    this.url = '',
    this.notes = '',
    this.status = OpportunityStatus.saved,
  });

  final String id;
  final String title;
  final String platform;
  final DateTime createdAt;
  final String budget;
  final String url;
  final String notes;
  final OpportunityStatus status;

  Opportunity copyWith({
    String? title,
    String? platform,
    DateTime? createdAt,
    String? budget,
    String? url,
    String? notes,
    OpportunityStatus? status,
  }) {
    return Opportunity(
      id: id,
      title: title ?? this.title,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
      budget: budget ?? this.budget,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'platform': platform,
        'createdAt': createdAt.toIso8601String(),
        'budget': budget,
        'url': url,
        'notes': notes,
        'status': status.name,
      };

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    final statusName = json['status'] as String? ?? 'saved';
    final status = OpportunityStatus.values.firstWhere(
      (value) => value.name == statusName,
      orElse: () => OpportunityStatus.saved,
    );
    return Opportunity(
      id: json['id'] as String,
      title: json['title'] as String,
      platform: json['platform'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      budget: json['budget'] as String? ?? '',
      url: json['url'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      status: status,
    );
  }
}

