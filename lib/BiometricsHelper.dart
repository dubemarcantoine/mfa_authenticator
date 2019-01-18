import 'package:local_auth/local_auth.dart';

class BiometricsHelper {
  static final BiometricsHelper instance = new BiometricsHelper._internal();
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  factory BiometricsHelper() {
    return instance;
  }

  BiometricsHelper._internal();

  Future<bool> hasBiometrics() async {
    return await this.canCheckBiometrics() &&
        (await this.getAvailableBiometrics()).length > 0;
  }

  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuthentication.canCheckBiometrics;
    } on Exception catch (_) {
      return Future.value(false);
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuthentication.getAvailableBiometrics();
    } on Exception catch (_) {
      return Future.value(null);
    }
  }
}
