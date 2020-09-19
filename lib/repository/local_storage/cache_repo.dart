import 'package:dive/repository/local_storage/cache_data.dart';
import 'package:dive/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:localstorage/localstorage.dart';

class CacheRepo {
  final LocalStorage localStorage = GetIt.instance<LocalStorage>();

  static const int DEFAULT_EXPIRY_IN_HOURS = 24;
  static const bool DEFAULT_SHOULD_ERASE_ON_SIGNOUT = false;

  Map<String, CacheData> _cacheKeys = Map<String, CacheData>();

  Future<bool> isCacheReady() {
    return localStorage.ready;
  }

  void putData(
      {@required String key,
      @required dynamic data,
      bool shouldEraseOnSignout = DEFAULT_SHOULD_ERASE_ON_SIGNOUT,
      int expiryInHours = DEFAULT_EXPIRY_IN_HOURS}) {
    CacheData currentData = CacheData(
      key: key,
      data: data,
      shouldEraseOnSignout: shouldEraseOnSignout,
      timeOfEntry: DateTime.now(),
      expiryInHours: expiryInHours,
    );

    if (_cacheKeys.containsKey(key)) {
      _cacheKeys.remove(key);
    }
    _cacheKeys[key] = currentData;

    localStorage.setItem(key, currentData).then((_) {
      getLogger().i(dataPushedToLocalStorage);
    }).catchError((error) {
      getLogger().e(failedPushingDataToLocalStorage + error.toString());
    });
  }

  dynamic getData(String key) {
    var dataFromCache = localStorage.getItem(key);
    if (dataFromCache == null) return dataFromCache;

    CacheData cacheData = CacheData.fromJson(dataFromCache);
    if (cacheData == null ||
        DateTime.now().difference(cacheData.timeOfEntry).inHours >=
            cacheData.expiryInHours) {
      return null;
    } else {
      return cacheData.data;
    }
  }

  void delete(String key) {
    if (_cacheKeys.containsKey(key)) {
      _cacheKeys.remove(key);
    }
    localStorage.deleteItem(key).then((value) {
      getLogger().i(dataDeletedFromStorage);
    }).catchError((error) {
      getLogger().e(failedToDeleteDataFromStorage + error.toString());
    });
  }

  void onSignOut() {
    _disposeLocalStorageController();

    List<String> cacheKeysForDeletion = List<String>();

    _cacheKeys.forEach((key, value) {
      if (value.shouldEraseOnSignout) {
        cacheKeysForDeletion.add(key);
      }
    });

    for (var i = 0; i < cacheKeysForDeletion.length; i++) {
      delete(cacheKeysForDeletion[i]);
    }
  }

  void _disposeLocalStorageController() {
    localStorage.dispose();
  }
}
