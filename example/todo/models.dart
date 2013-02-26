library models;

import 'package:web_ui/web_ui.dart';

@observable
class TodoItem {
  String actionItem;
  bool complete = false;
  
  TodoItem(this.actionItem);
  
  TodoItem.fromMap(Map data) {
    actionItem = data['actionItem'];
    complete = data['complete'];
  }
  
  toggle() => complete = !complete;
  
  Map toJson() {
    return {"actionItem": actionItem, "complete": complete};
  }
}