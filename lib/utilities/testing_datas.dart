import '../data/history.dart';

class TestData {
  TestData();

  List<Histories> initTestHistories() {
    return [
      Histories(
          id: '001-0908670268',
          roomId: '001',
          userId: '0908670268',
          fromDate: DateTime.now(),
          toDate: null,
          status: 0),
      Histories(
          id: '002-0908670268',
          roomId: '002',
          userId: '0908670268',
          fromDate: DateTime.now().subtract(const Duration(days: 1)),
          toDate: null,
          status: 1),
      Histories(
          id: '003-0908670268',
          roomId: '003',
          userId: '0908670268',
          fromDate: DateTime.now().subtract(const Duration(days: 2)),
          toDate: DateTime.now().subtract(const Duration(days: 1)),
          status: 2),
    ];
  }
}
