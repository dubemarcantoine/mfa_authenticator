import 'package:mfa_authenticator/OtpList.dart';
import 'package:mfa_authenticator/data/DbProvider.dart';

class OtpItemDataMapper {

  static final String otpItemTableName = 'otp_item';

  static Future<int> newOtpItem(OtpItem otpItem) async {
    final db = await DbProvider.db.database;
    var res = await db.insert(otpItemTableName, otpItem.toMap());
    return res;
  }

  static Future<List<OtpItem>> getOtpItems() async {
    print('fetching all items');
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