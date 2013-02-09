library models;

class TodoItem {
  String actionItem;
  bool complete = false;
  
  TodoItem(this.actionItem);
  
  toggle() => complete = !complete;
  
  Map toJson() {
    return {"actionItem": actionItem, "complete": complete};
  }
}