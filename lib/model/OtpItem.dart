class OtpItem {
  int id;
  String secret;
  String issuer;
  String account;
  bool timeBased;
  int digits;
  String otpCode;

  OtpItem(
      {this.id,
      this.secret,
      this.issuer,
      this.account,
      this.timeBased = true,
      this.digits = 6});

  factory OtpItem.fromMap(Map<String, dynamic> json) => new OtpItem(
        id: json['id'],
        secret: json['secret'],
        issuer: json['issuer'],
        account: json['label'],
        timeBased: json['time_based'] == 1,
        digits: json['length'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'secret': secret,
        'issuer': issuer,
        'account': account,
        'time_based': timeBased,
        'length': digits,
      };
}
