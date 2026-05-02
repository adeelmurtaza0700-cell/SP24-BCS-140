class GameResult {
  final int? id;
  final int secretNumber;
  final int guess;
  final String status; // 'correct', 'too_high', 'too_low'
  final int attempts;
  final String timestamp;

  GameResult({
    this.id,
    required this.secretNumber,
    required this.guess,
    required this.status,
    required this.attempts,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'secret_number': secretNumber,
        'guess': guess,
        'status': status,
        'attempts': attempts,
        'timestamp': timestamp,
      };

  factory GameResult.fromMap(Map<String, dynamic> map) => GameResult(
        id: map['id'],
        secretNumber: map['secret_number'],
        guess: map['guess'],
        status: map['status'],
        attempts: map['attempts'],
        timestamp: map['timestamp'],
      );

  String get statusLabel {
    switch (status) {
      case 'correct':
        return '✓ Correct!';
      case 'too_high':
        return '↓ Too High';
      case 'too_low':
        return '↑ Too Low';
      default:
        return status;
    }
  }
}