class OtpItem {
  int id;
  String secret;
  String issuer;
  String label;
  bool timeBased;
  String otpCode;

  OtpItem({this.id, this.secret, this.issuer, this.label, this.timeBased});

  factory OtpItem.fromMap(Map<String, dynamic> json) => new OtpItem(
    id: json['id'],
    secret: json['secret'],
    issuer: json['issuer'],
    label: json['label'],
    timeBased: json['time_based'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'secret': secret,
    'issuer': issuer,
    'label': label,
    'time_based': timeBased,
  };
}