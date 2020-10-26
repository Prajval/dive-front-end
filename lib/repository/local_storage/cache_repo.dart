import 'package:dive/repository/local_storage/cache_data.dart';
import 'package:dive/repository/local_storage/cache_keys.dart';
import 'package:dive/repository/local_storage/keys_to_delete.dart';
import 'package:dive/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:localstorage/localstorage.dart';

class CacheRepo {
  final LocalStorage localStorage = GetIt.instance<LocalStorage>();

  static const int DEFAULT_EXPIRY_IN_HOURS = 24;
  static const bool DEFAULT_SHOULD_ERASE_ON_SIGNOUT = false;

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

    if (localStorage.getItem(key) != null) {
      localStorage.deleteItem(key);
    }

    // store all the set of keys to delete in a separate cache-entry
    if (shouldEraseOnSignout) {
      var keysToDeleteFromCache = getData(CacheKeys.keysToDeleteOnSignout);
      Set<String> keysToDeleteOnSignout = (keysToDeleteFromCache == null)
          ? (Set<String>())
          : (KeysToDeleteOnSignout.fromJson(keysToDeleteFromCache).keys);

      if (!keysToDeleteOnSignout.contains(key)) {
        keysToDeleteOnSignout.add(key);
      }
      putData(
          key: CacheKeys.keysToDeleteOnSignout,
          data: KeysToDeleteOnSignout(keys: keysToDeleteOnSignout),
          expiryInHours: 8760);
    }

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
    if (cacheData == null) {
      return null;
    } else if (DateTime.now().difference(cacheData.timeOfEntry).inHours >=
        cacheData.expiryInHours) {
      delete(key);
      return null;
    } else {
      return cacheData.data;
    }
  }

  void delete(String key) {
    localStorage.deleteItem(key).then((value) {
      getLogger().i(dataDeletedFromStorage);
    }).catchError((error) {
      getLogger().e(failedToDeleteDataFromStorage + error.toString());
    });
  }

  void onSignOut() {
    var keysToDeleteFromCache = getData(CacheKeys.keysToDeleteOnSignout);
    Set<String> keysToDeleteOnSignout = (keysToDeleteFromCache == null)
        ? (null)
        : (KeysToDeleteOnSignout.fromJson(keysToDeleteFromCache).keys);

    if (keysToDeleteOnSignout != null) {
      keysToDeleteOnSignout.forEach((key) {
        delete(key);
      });
    }
  }
}
