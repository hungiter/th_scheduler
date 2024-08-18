
class HistoryQR {
  int status;

  HistoryQR({
    required this.status,
  });

  // Convert a HistoryQR object to a map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'status': status,
    };
  }

  // Convert a map from Firebase to a HistoryQR object
  factory HistoryQR.fromMap(Map<String, dynamic> map) {
    return HistoryQR(
      status: map['status'],
    );
  }
}
