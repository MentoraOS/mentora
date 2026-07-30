import '../models/device.dart';

class DeviceDomain {
  Device? _currentDevice;

  Device? get currentDevice => _currentDevice;

  bool get hasDevice => _currentDevice != null;

  void register(Device device) {
    _currentDevice = device;
  }

  void updatePushToken(String pushToken) {
    final device = _currentDevice;

    if (device == null) return;

    _currentDevice = Device(
      id: device.id,
      name: device.name,
      platform: device.platform,
      osVersion: device.osVersion,
      appVersion: device.appVersion,
      pushToken: pushToken,
      trusted: device.trusted,
      lastActiveAt: DateTime.now(),
    );
  }

  void markTrusted() {
    final device = _currentDevice;

    if (device == null) return;

    _currentDevice = Device(
      id: device.id,
      name: device.name,
      platform: device.platform,
      osVersion: device.osVersion,
      appVersion: device.appVersion,
      pushToken: device.pushToken,
      trusted: true,
      lastActiveAt: DateTime.now(),
    );
  }

  void clear() {
    _currentDevice = null;
  }
}
