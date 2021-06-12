library firebase_remote_config_hybrid_web;

import 'package:firebase/firebase.dart' as core;
import 'package:firebase_remote_config_hybrid_platform_interface/firebase_remote_config_hybrid_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'dart:async';

class FirebaseRemoteConfigWeb extends FirebaseRemoteConfigPlatformInterface {
  core.RemoteConfig _instance;
  FirebaseRemoteConfigWeb._(core.RemoteConfig instance) : _instance = instance;

  static void registerWith(Registrar registrar) {
    FirebaseRemoteConfigPlatformInterface.instance =
        FirebaseRemoteConfigWeb._(core.remoteConfig());
  }

  @override
  Map<String, PlatformRemoteConfigValue> getAll() {
    Map<String, core.RemoteConfigValue> coreResult = _instance?.getAll();
    if (coreResult == null) return null;
    Map<String, PlatformRemoteConfigValue> pluginResult = {};
    for (String key in coreResult.keys) {
      pluginResult[key] = _coreConfigValueToPlugin(coreResult[key]);
    }
    return pluginResult;
  }

  @override
  bool getBool(String key) {
    return _instance?.getBoolean(key);
  }

  @override
  double getDouble(String key) {
    return _instance?.getNumber(key)?.toDouble();
  }

  @override
  int getInt(String key) {
    return _instance?.getNumber(key)?.toInt();
  }

  @override
  String getString(String key) {
    return _instance?.getString(key);
  }

  @override
  PlatformRemoteConfigValue getValue(String key) {
    return _coreConfigValueToPlugin(_instance?.getValue(key));
  }

  @override
  Future<bool> activateFetched() async {
    return await _instance?.activate();
  }

  @override
  Future<void> fetch({Duration expiration: const Duration(hours: 12)}) async {
    _instance?.settings?.minimumFetchInterval = expiration;
    await _instance?.fetch();
  }

  @override
  DateTime get lastFetchTime => _instance?.fetchTime;

  @override
  LastFetchStatus get lastFetchStatus =>
      _statusFromCore(_instance?.lastFetchStatus);

  PlatformRemoteConfigValue _coreConfigValueToPlugin(
      core.RemoteConfigValue coreValue) {
    return coreValue == null
        ? null
        : PlatformRemoteConfigValue(
            asBool: coreValue.asBoolean,
            asDouble: () => coreValue.asNumber().toDouble(),
            asInt: () => coreValue.asNumber().toInt(),
            asString: coreValue.asString,
            getSource: () => _valueSourceFromCore(coreValue.getSource()),
          );
  }

  LastFetchStatus _statusFromCore(core.RemoteConfigFetchStatus status) {
    switch (status) {
      case core.RemoteConfigFetchStatus.failure:
        return LastFetchStatus.failure;
      case core.RemoteConfigFetchStatus.notFetchedYet:
        return LastFetchStatus.noFetchYet;
      case core.RemoteConfigFetchStatus.success:
        return LastFetchStatus.success;
      case core.RemoteConfigFetchStatus.throttle:
        return LastFetchStatus.throttled;
      default:
        return null;
    }
  }

  ValueSource _valueSourceFromCore(core.RemoteConfigValueSource source) {
    switch (source) {
      case core.RemoteConfigValueSource.defaults:
        return ValueSource.valueDefault;
      case core.RemoteConfigValueSource.remote:
        return ValueSource.valueRemote;
      case core.RemoteConfigValueSource.static:
        return ValueSource.valueStatic;
      default:
        return null;
    }
  }
}
