library models;

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
  
  bool operator ==(TodoItem other) {
    return other.actionItem == actionItem && other.complete == complete;
  }
  
  int get hashCode {
    int result = 17;
    result = result * 37 * actionItem.hashCode;
    result = result * 37 * complete.hashCode;
    return result;
  }
}