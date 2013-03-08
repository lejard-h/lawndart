library models;

import 'package:web_ui/web_ui.dart';
import 'package:web_ui/observe/observable.dart' as __observe;

@observable
class TodoItem  implements Observable{
  String __$actionItem;
  String get actionItem {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'actionItem');
    }
    return __$actionItem;
  }
  set actionItem(String value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'actionItem',
          __$actionItem, value);
    }
    __$actionItem = value;
  }
  bool __$complete = false;
  bool get complete {
    if (__observe.observeReads) {
      __observe.notifyRead(this, __observe.ChangeRecord.FIELD, 'complete');
    }
    return __$complete;
  }
  set complete(bool value) {
    if (__observe.hasObservers(this)) {
      __observe.notifyChange(this, __observe.ChangeRecord.FIELD, 'complete',
          __$complete, value);
    }
    __$complete = value;
  }
  
  TodoItem(actionItem) : __$actionItem = actionItem;
  
  TodoItem.fromMap(Map data) {
    actionItem = data['actionItem'];
    complete = data['complete'];
  }
  
  toggle() => complete = !complete;
  
  Map toJson() {
    return {"actionItem": actionItem, "complete": complete};
  }
final int hashCode = ++__observe.Observable.$_nextHashCode;
  var $_observers;
  List $_changes;
  }
//@ sourceMappingURL=models.dart.map