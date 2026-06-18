import 'dart:io' show Platform;

class WvBlob {
  static const String _android =
      'Qd7Tn2pLm4Vx8Rk0Bs6FzWcAj1HuYe9Np3Gt5Md7Qa2Lc4Vx8Rk0Bs6FzWcAj1Hu';
  static const String _ios =
      'Zp9Kx2Mv6Tn4Rk0Bs8FzWcAj1HuYe5Np7Gt3Md1Qa9Lc7Vx5Rk3Bs1FzWcAj7Hu';

  static String forPlatform() => Platform.isIOS ? _ios : _android;
}
