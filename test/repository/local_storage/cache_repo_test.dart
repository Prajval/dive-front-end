import 'package:dive/repository/local_storage/cache_data.dart';
import 'package:dive/repository/local_storage/cache_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mockito/mockito.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

void main() {
  final localStorage = MockLocalStorage();

  setUpAll(() {
    GetIt.instance.allowReassignment = true;

    GetIt.instance.registerSingleton<LocalStorage>((localStorage));
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  group('get cache ready', () {
    test('should return true', () async {
      when(localStorage.ready).thenAnswer((_) => Future.value(true));

      CacheRepo().isCacheReady().then((value) {
        expect(value, true);

        verify(localStorage.ready).called(1);
        verifyNoMoreInteractions(localStorage);
      });
    });

    test('should return false', () async {
      when(localStorage.ready).thenAnswer((_) => Future.value(false));

      CacheRepo().isCacheReady().then((value) {
        expect(value, false);

        verify(localStorage.ready).called(1);
        verifyNoMoreInteractions(localStorage);
      });
    });
  });

  group('put data', () {
    test('should error out without throwing an error', () async {
      String key = "key";
      String data = "data";
      CacheData capturedCacheData;

      when(localStorage.setItem(key, any)).thenAnswer((invocation) {
        capturedCacheData = invocation.positionalArguments[1];
        return Future.error("error");
      });

      CacheRepo().putData(key: key, data: data);

      expect(capturedCacheData.data, data);
      expect(capturedCacheData.key, key);
      expect(capturedCacheData.shouldEraseOnSignout,
          CacheRepo.DEFAULT_SHOULD_ERASE_ON_SIGNOUT);
      expect(
          capturedCacheData.expiryInHours, CacheRepo.DEFAULT_EXPIRY_IN_HOURS);

      verify(localStorage.setItem(key, any)).called(1);
      verifyNoMoreInteractions(localStorage);
    });

    test(
        'should put data with default expiry and shouldEraseOnSignout set to false',
        () async {
      String key = "key";
      String data = "data";
      CacheData capturedCacheData;

      when(localStorage.setItem(key, any)).thenAnswer((invocation) {
        capturedCacheData = invocation.positionalArguments[1];
        return Future.value();
      });

      CacheRepo().putData(key: key, data: data);

      expect(capturedCacheData.data, data);
      expect(capturedCacheData.key, key);
      expect(capturedCacheData.shouldEraseOnSignout,
          CacheRepo.DEFAULT_SHOULD_ERASE_ON_SIGNOUT);
      expect(
          capturedCacheData.expiryInHours, CacheRepo.DEFAULT_EXPIRY_IN_HOURS);

      verify(localStorage.setItem(key, any)).called(1);
      verifyNoMoreInteractions(localStorage);
    });

    test('should put data with default expiry', () async {
      String key = "key";
      String data = "data";
      bool shouldEraseOnSignout = true;
      CacheData capturedCacheData;

      when(localStorage.setItem(key, any)).thenAnswer((invocation) {
        capturedCacheData = invocation.positionalArguments[1];
        return Future.value();
      });

      CacheRepo().putData(
          key: key, data: data, shouldEraseOnSignout: shouldEraseOnSignout);

      expect(capturedCacheData.data, data);
      expect(capturedCacheData.key, key);
      expect(capturedCacheData.shouldEraseOnSignout, shouldEraseOnSignout);
      expect(
          capturedCacheData.expiryInHours, CacheRepo.DEFAULT_EXPIRY_IN_HOURS);

      verify(localStorage.setItem(key, any)).called(1);
      verifyNoMoreInteractions(localStorage);
    });

    test('should put data with default should erase on signout flag', () async {
      String key = "key";
      String data = "data";
      int expiry = 6;
      CacheData capturedCacheData;

      when(localStorage.setItem(key, any)).thenAnswer((invocation) {
        capturedCacheData = invocation.positionalArguments[1];
        return Future.value();
      });

      CacheRepo().putData(key: key, data: data, expiryInHours: expiry);

      expect(capturedCacheData.data, data);
      expect(capturedCacheData.key, key);
      expect(capturedCacheData.shouldEraseOnSignout,
          CacheRepo.DEFAULT_SHOULD_ERASE_ON_SIGNOUT);
      expect(capturedCacheData.expiryInHours, expiry);

      verify(localStorage.setItem(key, any)).called(1);
      verifyNoMoreInteractions(localStorage);
    });

    test('should put data with user provided values', () async {
      String key = "key";
      String data = "data";
      int expiry = 6;
      bool shouldEraseOnSignout = true;
      CacheData capturedCacheData;

      when(localStorage.setItem(key, any)).thenAnswer((invocation) {
        capturedCacheData = invocation.positionalArguments[1];
        return Future.value();
      });

      CacheRepo().putData(
        key: key,
        data: data,
        expiryInHours: expiry,
        shouldEraseOnSignout: shouldEraseOnSignout,
      );

      expect(capturedCacheData.data, data);
      expect(capturedCacheData.key, key);
      expect(capturedCacheData.shouldEraseOnSignout, shouldEraseOnSignout);
      expect(capturedCacheData.expiryInHours, expiry);

      verify(localStorage.setItem(key, any)).called(1);
      verifyNoMoreInteractions(localStorage);
    });

    test('should update key if it already exists', () async {
      String key = "key";
      String data = "data";
      String data2 = "data2";
      int expiry = 6;
      bool shouldEraseOnSignout = true;
      CacheData capturedCacheData;

      when(localStorage.setItem(key, any)).thenAnswer((invocation) {
        capturedCacheData = invocation.positionalArguments[1];
        return Future.value();
      });

      CacheRepo().putData(
        key: key,
        data: data,
      );

      expect(capturedCacheData.data, data);
      expect(capturedCacheData.key, key);
      expect(capturedCacheData.shouldEraseOnSignout,
          CacheRepo.DEFAULT_SHOULD_ERASE_ON_SIGNOUT);
      expect(
          capturedCacheData.expiryInHours, CacheRepo.DEFAULT_EXPIRY_IN_HOURS);

      CacheRepo().putData(
        key: key,
        data: data2,
        expiryInHours: expiry,
        shouldEraseOnSignout: shouldEraseOnSignout,
      );

      expect(capturedCacheData.data, data2);
      expect(capturedCacheData.key, key);
      expect(capturedCacheData.shouldEraseOnSignout, shouldEraseOnSignout);
      expect(capturedCacheData.expiryInHours, expiry);

      verify(localStorage.setItem(key, any)).called(2);
      verifyNoMoreInteractions(localStorage);
    });
  });

  group('get data', () {
    test('should return null if data doesnt exist', () async {
      String key = "key";

      when(localStorage.getItem(key)).thenReturn(null);

      expect(CacheRepo().getData(key), null);

      verify(localStorage.getItem(key)).called(1);
      verifyNoMoreInteractions(localStorage);
    });

    test('should return null if data is expired', () async {
      String key = "key";
      String data = "data";
      int expiry = -1;
      Map<String, dynamic> cacheData = Map<String, dynamic>();
      cacheData = {
        "key": key,
        "data": data,
        "shouldEraseOnSignout": CacheRepo.DEFAULT_SHOULD_ERASE_ON_SIGNOUT,
        "expiryInHours": expiry,
        "timeOfEntry": DateTime.now().toString(),
      };

      when(localStorage.setItem(key, any)).thenAnswer((invocation) {
        return Future.value();
      });
      when(localStorage.getItem(key)).thenReturn(cacheData);
      when(localStorage.deleteItem(key)).thenAnswer((_) => Future.value());

      CacheRepo().putData(key: key, data: data, expiryInHours: expiry);

      expect(CacheRepo().getData(key), null);

      verify(localStorage.setItem(key, any)).called(1);
      verify(localStorage.getItem(key)).called(1);
      verify(localStorage.deleteItem(key)).called(1);
      verifyNoMoreInteractions(localStorage);
    });

    test('should return data if data is not expired', () async {
      String key = "key";
      String data = "data";
      int expiry = 2;
      Map<String, dynamic> cacheData = Map<String, dynamic>();
      cacheData = {
        "key": key,
        "data": data,
        "shouldEraseOnSignout": CacheRepo.DEFAULT_SHOULD_ERASE_ON_SIGNOUT,
        "expiryInHours": expiry,
        "timeOfEntry": DateTime.now().toString(),
      };

      when(localStorage.setItem(key, any)).thenAnswer((invocation) {
        return Future.value();
      });
      when(localStorage.getItem(key)).thenReturn(cacheData);

      CacheRepo().putData(key: key, data: data, expiryInHours: expiry);

      expect(CacheRepo().getData(key), data);

      verify(localStorage.setItem(key, any)).called(1);
      verify(localStorage.getItem(key)).called(1);
      verifyNoMoreInteractions(localStorage);
    });
  });

  group('delete', () {
    test('should delete item when key doesnt exist', () async {
      String key = "key";

      when(localStorage.deleteItem(key)).thenAnswer((_) => Future.value());

      CacheRepo().delete(key);

      verify(localStorage.deleteItem(key)).called(1);
      verifyNoMoreInteractions(localStorage);
    });

    test('should delete item when key exists', () async {
      String key = "key";
      String data = "data";

      when(localStorage.setItem(key, any)).thenAnswer((_) => Future.value());
      when(localStorage.deleteItem(key)).thenAnswer((_) => Future.value());

      CacheRepo().putData(key: key, data: data);
      CacheRepo().delete(key);

      verify(localStorage.deleteItem(key)).called(1);
      verify(localStorage.setItem(key, any)).called(1);
      verifyNoMoreInteractions(localStorage);
    });

    test('should not throw error when key deletion fails', () async {
      String key = "key";
      String data = "data";

      when(localStorage.setItem(key, any)).thenAnswer((_) => Future.value());
      when(localStorage.deleteItem(key))
          .thenAnswer((_) => Future.error("error"));

      CacheRepo().putData(key: key, data: data);
      CacheRepo().delete(key);

      verify(localStorage.deleteItem(key)).called(1);
      verify(localStorage.setItem(key, any)).called(1);
      verifyNoMoreInteractions(localStorage);
    });
  });

  group('on sign out', () {
    test(
        'should only delete keys with should erase on sign out flag set to false',
        () async {
      String key1 = "keyShouldNotDeleteOnSignout1";
      String key2 = "keyShouldDeleteOnSignout1";
      String key3 = "keyShouldNotDeleteOnSignout2";
      String key4 = "keyShouldDeleteOnSignout2";
      String data1 = "dataShouldNotDeleteOnSignout1";
      String data2 = "dataShouldDeleteOnSignout1";
      String data3 = "dataShouldNotDeleteOnSignout2";
      String data4 = "dataShouldDeleteOnSignout2";

      Map<String, dynamic> cacheData1 = Map<String, dynamic>();
      cacheData1 = {
        "key": key1,
        "data": data1,
        "shouldEraseOnSignout": CacheRepo.DEFAULT_SHOULD_ERASE_ON_SIGNOUT,
        "expiryInHours": 48,
        "timeOfEntry": DateTime.now().toString(),
      };
      Map<String, dynamic> cacheData3 = Map<String, dynamic>();
      cacheData3 = {
        "key": key3,
        "data": data3,
        "shouldEraseOnSignout": CacheRepo.DEFAULT_SHOULD_ERASE_ON_SIGNOUT,
        "expiryInHours": 48,
        "timeOfEntry": DateTime.now().subtract(Duration(days: 1)).toString(),
      };

      when(localStorage.setItem(any, any)).thenAnswer((_) => Future.value());
      when(localStorage.deleteItem(any)).thenAnswer((_) => Future.value());
      when(localStorage.getItem(key1)).thenReturn(cacheData1);
      when(localStorage.getItem(key2)).thenReturn(null);
      when(localStorage.getItem(key3)).thenReturn(cacheData3);
      when(localStorage.getItem(key4)).thenReturn(null);

      CacheRepo cacheRepo = CacheRepo();
      cacheRepo.putData(key: key1, data: data1);
      cacheRepo.putData(key: key2, data: data2, shouldEraseOnSignout: true);
      cacheRepo.putData(key: key3, data: data3);
      cacheRepo.putData(key: key4, data: data4, shouldEraseOnSignout: true);

      cacheRepo.onSignOut();

      expect(cacheRepo.getData(key1), data1);
      expect(cacheRepo.getData(key2), null);
      expect(cacheRepo.getData(key3), data3);
      expect(cacheRepo.getData(key4), null);

      verify(localStorage.getItem(any)).called(4);
      verify(localStorage.setItem(any, any)).called(4);
      verify(localStorage.deleteItem(any)).called(2);
      verify(localStorage.dispose()).called(1);
      verifyNoMoreInteractions(localStorage);
    });
  });
}
