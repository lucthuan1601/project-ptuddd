/// Hỗ trợ UC-05: Chuẩn hóa số điện thoại Hotline.
class CallHelper {
  CallHelper._();

  /// Chuẩn hóa chuỗi số điện thoại bằng cách loại bỏ khoảng trắng và ký tự không phải số/+
  static String cleanPhone(String? phone) {
    if (phone == null) return '';
    return phone.replaceAll(RegExp(r'[\s\-\(\)\.]'), '').trim();
  }
}
