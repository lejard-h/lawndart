//Copyright 2012 Google
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

part of lawndart;

/**
 * Wraps the local storage API and exposes it as a [Store].
 * Local storage is a synchronous API, and generally not recommended
 * unless all other storage mechanisms are unavailable.
 */
class LocalStorageStore extends _MapStore {
  LocalStorageStore._() : super._();

  static Future<LocalStorageStore> open() async {
    var store = new LocalStorageStore._();
    await store._open();
    return store;
  }

  @override
  Map<String, String> _generateMap() => window.localStorage;
}
