class BugHandler {
  static String bugString(int error) {
    return switch (error) {
      101 => "Phòng không tồn tại",
      102 => "Phòng đã có người khác đặt trước",
      -101 =>
        "Lỗi chưa xác định. Check FireStoreHandler.roomOrderAndCreateHistory(...)",
      201 => "Tối đa đặt-sử dụng 3 phòng",
      202 => "Lịch sử không tồn tại",
      -201 =>
        "Lỗi chưa xác định. Check HistoriesManagement.getUserHistories(...)",
      -202 => "Lỗi chưa xác định. Check HistoriesManagement.createHistory(...)",
      -203 =>
        "Lỗi chưa xác định. Check FireStoreHandler.roomOrderAndCreateHistory(...)",
      -204 =>
        "Lỗi chưa xác định. Check HistoriesManagement.userDeleteHistory(...)",
      -205 =>
        "Lỗi chưa xác định. Check HistoriesManagement.userCancelHistory(...)",
      int() => throw UnimplementedError(),
    };
  }
}
