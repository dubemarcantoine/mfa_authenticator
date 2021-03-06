import 'package:authenticator/data/DbProvider.dart';
import 'package:authenticator/model/OtpItem.dart';

class OtpItemDataMapper {
  static final String otpItemTableName = 'otp_item';

  static Future<int> newOtpItem(OtpItem otpItem) async {
    final db = await DbProvider.db.database;
    return await db.insert(otpItemTableName, otpItem.toMap());
  }

  static Future<List<OtpItem>> getOtpItems() async {
    final db = await DbProvider.db.database;
    var res = await db.query(otpItemTableName);
    List<OtpItem> list =
        res.isNotEmpty ? res.map((c) => OtpItem.fromMap(c)).toList() : [];
    return list;
  }

  static void delete(int id) async {
    final db = await DbProvider.db.database;
    db.delete(otpItemTableName, where: "id = ?", whereArgs: [id]);
  }
}
