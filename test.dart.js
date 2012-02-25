//  ********** Library dart:core **************
//  ********** Natives dart:core **************
function $defProp(obj, prop, value) {
  Object.defineProperty(obj, prop,
      {value: value, enumerable: false, writable: true, configurable: true});
}
function $throw(e) {
  // If e is not a value, we can use V8's captureStackTrace utility method.
  // TODO(jmesserly): capture the stack trace on other JS engines.
  if (e && (typeof e == 'object') && Error.captureStackTrace) {
    // TODO(jmesserly): this will clobber the e.stack property
    Error.captureStackTrace(e, $throw);
  }
  throw e;
}
$defProp(Object.prototype, '$index', function(i) {
  $throw(new NoSuchMethodException(this, "operator []", [i]));
});
$defProp(Array.prototype, '$index', function(index) {
  var i = index | 0;
  if (i !== index) {
    throw new IllegalArgumentException('index is not int');
  } else if (i < 0 || i >= this.length) {
    throw new IndexOutOfRangeException(index);
  }
  return this[i];
});
$defProp(String.prototype, '$index', function(i) {
  return this[i];
});
function $wrap_call$1(fn) { return fn; }
function $$add$complex(x, y) {
  if (typeof(x) == 'number') {
    $throw(new IllegalArgumentException(y));
  } else if (typeof(x) == 'string') {
    var str = (y == null) ? 'null' : y.toString();
    if (typeof(str) != 'string') {
      throw new Error("calling toString() on right hand operand of operator " +
      "+ did not return a String");
    }
    return x + str;
  } else if (typeof(x) == 'object') {
    return x.$add(y);
  } else {
    $throw(new NoSuchMethodException(x, "operator +", [y]));
  }
}

function $$add(x, y) {
  if (typeof(x) == 'number' && typeof(y) == 'number') return x + y;
  return $$add$complex(x, y);
}
function $$eq(x, y) {
  if (x == null) return y == null;
  return (typeof(x) != 'object') ? x === y : x.$eq(y);
}
// TODO(jimhug): Should this or should it not match equals?
$defProp(Object.prototype, '$eq', function(other) {
  return this === other;
});
$defProp(Object.prototype, '$typeNameOf', function() {
  var constructor = this.constructor;
  if (typeof(constructor) == 'function') {
    // The constructor isn't null or undefined at this point. Try
    // to grab hold of its name.
    var name = constructor.name;
    // If the name is a non-empty string, we use that as the type
    // name of this object. On Firefox, we often get 'Object' as
    // the constructor name even for more specialized objects so
    // we have to fall through to the toString() based implementation
    // below in that case.
    if (name && typeof(name) == 'string' && name != 'Object') return name;
  }
  var string = Object.prototype.toString.call(this);
  var name = string.substring(8, string.length - 1);
  if (name == 'Window') {
    name = 'DOMWindow';
  } else if (name == 'Document') {
    name = 'HTMLDocument';
  }
  return name;
});
$defProp(Object.prototype, "get$typeName", Object.prototype.$typeNameOf);
// ********** Code for Object **************
$defProp(Object.prototype, "noSuchMethod", function(name, args) {
  $throw(new NoSuchMethodException(this, name, args));
});
$defProp(Object.prototype, "complete$1", function($0) {
  return this.noSuchMethod("complete", [$0]);
});
$defProp(Object.prototype, "is$Collection", function() {
  return false;
});
$defProp(Object.prototype, "is$List", function() {
  return false;
});
$defProp(Object.prototype, "is$Map", function() {
  return false;
});
$defProp(Object.prototype, "open$0", function() {
  return this.noSuchMethod("open", []);
});
$defProp(Object.prototype, "save$2", function($0, $1) {
  return this.noSuchMethod("save", [$0, $1]);
});
// ********** Code for IndexOutOfRangeException **************
function IndexOutOfRangeException(_index) {
  this._index = _index;
}
IndexOutOfRangeException.prototype.is$IndexOutOfRangeException = function(){return true};
IndexOutOfRangeException.prototype.toString = function() {
  return ("IndexOutOfRangeException: " + this._index);
}
// ********** Code for NoSuchMethodException **************
function NoSuchMethodException(_receiver, _functionName, _arguments, _existingArgumentNames) {
  this._receiver = _receiver;
  this._functionName = _functionName;
  this._arguments = _arguments;
  this._existingArgumentNames = _existingArgumentNames;
}
NoSuchMethodException.prototype.is$NoSuchMethodException = function(){return true};
NoSuchMethodException.prototype.toString = function() {
  var sb = new StringBufferImpl("");
  for (var i = (0);
   i < this._arguments.get$length(); i++) {
    if (i > (0)) {
      sb.add(", ");
    }
    sb.add(this._arguments.$index(i));
  }
  if (null == this._existingArgumentNames) {
    return $$add($$add(("NoSuchMethodException : method not found: '" + this._functionName + "'\n"), ("Receiver: " + this._receiver + "\n")), ("Arguments: [" + sb + "]"));
  }
  else {
    var actualParameters = sb.toString();
    sb = new StringBufferImpl("");
    for (var i = (0);
     i < this._existingArgumentNames.get$length(); i++) {
      if (i > (0)) {
        sb.add(", ");
      }
      sb.add(this._existingArgumentNames.$index(i));
    }
    var formalParameters = sb.toString();
    return $$add($$add($$add("NoSuchMethodException: incorrect number of arguments passed to ", ("method named '" + this._functionName + "'\nReceiver: " + this._receiver + "\n")), ("Tried calling: " + this._functionName + "(" + actualParameters + ")\n")), ("Found: " + this._functionName + "(" + formalParameters + ")"));
  }
}
// ********** Code for ClosureArgumentMismatchException **************
function ClosureArgumentMismatchException() {

}
ClosureArgumentMismatchException.prototype.toString = function() {
  return "Closure argument mismatch";
}
// ********** Code for ObjectNotClosureException **************
function ObjectNotClosureException() {

}
ObjectNotClosureException.prototype.toString = function() {
  return "Object is not closure";
}
// ********** Code for IllegalArgumentException **************
function IllegalArgumentException(arg) {
  this._arg = arg;
}
IllegalArgumentException.prototype.is$IllegalArgumentException = function(){return true};
IllegalArgumentException.prototype.toString = function() {
  return ("Illegal argument(s): " + this._arg);
}
// ********** Code for StackOverflowException **************
function StackOverflowException() {

}
StackOverflowException.prototype.toString = function() {
  return "Stack Overflow";
}
// ********** Code for NullPointerException **************
function NullPointerException() {

}
NullPointerException.prototype.toString = function() {
  return "NullPointerException";
}
// ********** Code for NoMoreElementsException **************
function NoMoreElementsException() {

}
NoMoreElementsException.prototype.toString = function() {
  return "NoMoreElementsException";
}
// ********** Code for UnsupportedOperationException **************
function UnsupportedOperationException(_message) {
  this._message = _message;
}
UnsupportedOperationException.prototype.toString = function() {
  return ("UnsupportedOperationException: " + this._message);
}
// ********** Code for dart_core_Function **************
Function.prototype.to$call$0 = function() {
  this.call$0 = this._genStub(0);
  this.to$call$0 = function() { return this.call$0; };
  return this.call$0;
};
Function.prototype.call$0 = function() {
  return this.to$call$0()();
};
function to$call$0(f) { return f && f.to$call$0(); }
Function.prototype.to$call$1 = function() {
  this.call$1 = this._genStub(1);
  this.to$call$1 = function() { return this.call$1; };
  return this.call$1;
};
Function.prototype.call$1 = function($0) {
  return this.to$call$1()($0);
};
function to$call$1(f) { return f && f.to$call$1(); }
Function.prototype.to$call$2 = function() {
  this.call$2 = this._genStub(2);
  this.to$call$2 = function() { return this.call$2; };
  return this.call$2;
};
Function.prototype.call$2 = function($0, $1) {
  return this.to$call$2()($0, $1);
};
function to$call$2(f) { return f && f.to$call$2(); }
// ********** Code for top level **************
function dart_core_print(obj) {
  return _print(obj);
}
function _print(obj) {
  if (typeof console == 'object') {
    if (obj) obj = obj.toString();
    console.log(obj);
  } else if (typeof write === 'function') {
    write(obj);
    write('\n');
  }
}
function _toDartException(e) {
  function attachStack(dartEx) {
    // TODO(jmesserly): setting the stack property is not a long term solution.
    var stack = e.stack;
    // The stack contains the error message, and the stack is all that is
    // printed (the exception's toString() is never called).  Make the Dart
    // exception's toString() be the dominant message.
    if (typeof stack == 'string') {
      var message = dartEx.toString();
      if (/^(Type|Range)Error:/.test(stack)) {
        // Indent JS message (it can be helpful) so new message stands out.
        stack = '    (' + stack.substring(0, stack.indexOf('\n')) + ')\n' +
                stack.substring(stack.indexOf('\n') + 1);
      }
      stack = message + '\n' + stack;
    }
    dartEx.stack = stack;
    return dartEx;
  }

  if (e instanceof TypeError) {
    switch(e.type) {
      case 'property_not_function':
      case 'called_non_callable':
        if (e.arguments[0] == null) {
          return attachStack(new NullPointerException());
        } else {
          return attachStack(new ObjectNotClosureException());
        }
        break;
      case 'non_object_property_call':
      case 'non_object_property_load':
        return attachStack(new NullPointerException());
        break;
      case 'undefined_method':
        var mname = e.arguments[0];
        if (typeof(mname) == 'string' && (mname.indexOf('call$') == 0
            || mname == 'call' || mname == 'apply')) {
          return attachStack(new ObjectNotClosureException());
        } else {
          // TODO(jmesserly): fix noSuchMethod on operators so we don't hit this
          return attachStack(new NoSuchMethodException('', e.arguments[0], []));
        }
        break;
    }
  } else if (e instanceof RangeError) {
    if (e.message.indexOf('call stack') >= 0) {
      return attachStack(new StackOverflowException());
    }
  }
  return e;
}
//  ********** Library dart:coreimpl **************
// ********** Code for ListFactory **************
ListFactory = Array;
$defProp(ListFactory.prototype, "is$List", function(){return true});
$defProp(ListFactory.prototype, "is$Collection", function(){return true});
$defProp(ListFactory.prototype, "get$length", function() { return this.length; });
$defProp(ListFactory.prototype, "set$length", function(value) { return this.length = value; });
$defProp(ListFactory.prototype, "add", function(value) {
  this.push(value);
});
$defProp(ListFactory.prototype, "clear", function() {
  this.set$length((0));
});
$defProp(ListFactory.prototype, "removeLast", function() {
  return this.pop();
});
$defProp(ListFactory.prototype, "iterator", function() {
  return new ListIterator(this);
});
$defProp(ListFactory.prototype, "toString", function() {
  return Collections.collectionToString(this);
});
// ********** Code for ListIterator **************
function ListIterator(array) {
  this._array = array;
  this._pos = (0);
}
ListIterator.prototype.hasNext = function() {
  return this._array.get$length() > this._pos;
}
ListIterator.prototype.next = function() {
  if (!this.hasNext()) {
    $throw(const$0001);
  }
  return this._array.$index(this._pos++);
}
// ********** Code for NumImplementation **************
NumImplementation = Number;
// ********** Code for Collections **************
function Collections() {}
Collections.collectionToString = function(c) {
  var result = new StringBufferImpl("");
  Collections._emitCollection(c, result, new Array());
  return result.toString();
}
Collections._emitCollection = function(c, result, visiting) {
  visiting.add(c);
  var isList = !!(c && c.is$List());
  result.add(isList ? "[" : "{");
  var first = true;
  for (var $$i = c.iterator(); $$i.hasNext(); ) {
    var e = $$i.next();
    if (!first) {
      result.add(", ");
    }
    first = false;
    Collections._emitObject(e, result, visiting);
  }
  result.add(isList ? "]" : "}");
  visiting.removeLast();
}
Collections._emitObject = function(o, result, visiting) {
  if (!!(o && o.is$Collection())) {
    if (Collections._containsRef(visiting, o)) {
      result.add(!!(o && o.is$List()) ? "[...]" : "{...}");
    }
    else {
      Collections._emitCollection(o, result, visiting);
    }
  }
  else if (!!(o && o.is$Map())) {
    if (Collections._containsRef(visiting, o)) {
      result.add("{...}");
    }
    else {
      Maps._emitMap(o, result, visiting);
    }
  }
  else {
    result.add($$eq(o) ? "null" : o);
  }
}
Collections._containsRef = function(c, ref) {
  for (var $$i = c.iterator(); $$i.hasNext(); ) {
    var e = $$i.next();
    if ((null == e ? null == (ref) : e === ref)) return true;
  }
  return false;
}
// ********** Code for FutureNotCompleteException **************
function FutureNotCompleteException() {

}
FutureNotCompleteException.prototype.toString = function() {
  return "Exception: future has not been completed";
}
// ********** Code for FutureAlreadyCompleteException **************
function FutureAlreadyCompleteException() {

}
FutureAlreadyCompleteException.prototype.toString = function() {
  return "Exception: future already completed";
}
// ********** Code for FutureImpl **************
function FutureImpl() {
  this._listeners = new Array();
  this._exceptionHandlers = new Array();
  this._isComplete = false;
  this._exceptionHandled = false;
}
FutureImpl.prototype.get$value = function() {
  if (!this.get$isComplete()) {
    $throw(new FutureNotCompleteException());
  }
  if (null != this._exception) {
    $throw(this._exception);
  }
  return this._value;
}
FutureImpl.prototype.get$isComplete = function() {
  return this._isComplete;
}
FutureImpl.prototype.get$hasValue = function() {
  return this.get$isComplete() && null == this._exception;
}
FutureImpl.prototype.then = function(onComplete) {
  if (this.get$hasValue()) {
    onComplete(this.get$value());
  }
  else if (!this.get$isComplete()) {
    this._listeners.add(onComplete);
  }
  else if (!this._exceptionHandled) {
    $throw(this._exception);
  }
}
FutureImpl.prototype.handleException = function(onException) {
  this._exceptionHandlers.add(onException);
}
FutureImpl.prototype._complete = function() {
  this._isComplete = true;
  if (null != this._exception) {
    var $$list = this._exceptionHandlers;
    for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
      var handler = $$i.next();
      if (handler.call$1(this._exception)) {
        this._exceptionHandled = true;
        break;
      }
    }
  }
  if (this.get$hasValue()) {
    var $$list = this._listeners;
    for (var $$i = $$list.iterator(); $$i.hasNext(); ) {
      var listener = $$i.next();
      listener.call$1(this.get$value());
    }
  }
  else {
    if (!this._exceptionHandled && this._listeners.get$length() > (0)) {
      $throw(this._exception);
    }
  }
}
FutureImpl.prototype._setValue = function(value) {
  if (this._isComplete) {
    $throw(new FutureAlreadyCompleteException());
  }
  this._value = value;
  this._complete();
}
FutureImpl.prototype._setException = function(exception) {
  if (null == exception) {
    $throw(new IllegalArgumentException(null));
  }
  if (this._isComplete) {
    $throw(new FutureAlreadyCompleteException());
  }
  this._exception = exception;
  this._complete();
}
FutureImpl.prototype.chain = function(transformation) {
  var completer = new CompleterImpl();
  this.handleException((function (e) {
    completer.completeException(e);
    return true;
  })
  );
  this.then((function (v) {
    var future = null;
    try {
      future = transformation.call$1(v);
    } catch (e) {
      e = _toDartException(e);
      completer.completeException(e);
      return;
    }
    future.handleException((function (e) {
      completer.completeException(e);
      return true;
    })
    );
    future.then((function (b) {
      return completer.complete$1(b);
    })
    );
  })
  );
  return completer.get$future();
}
// ********** Code for CompleterImpl **************
function CompleterImpl() {
  this._futureImpl = new FutureImpl();
}
CompleterImpl.prototype.get$future = function() {
  return this._futureImpl;
}
CompleterImpl.prototype.complete = function(value) {
  this._futureImpl._setValue(value);
}
CompleterImpl.prototype.completeException = function(exception) {
  this._futureImpl._setException(exception);
}
CompleterImpl.prototype.complete$1 = CompleterImpl.prototype.complete;
// ********** Code for CompleterImpl_bool **************
/** Implements extends for Dart classes on JavaScript prototypes. */
function $inherits(child, parent) {
  if (child.prototype.__proto__) {
    child.prototype.__proto__ = parent.prototype;
  } else {
    function tmp() {};
    tmp.prototype = parent.prototype;
    child.prototype = new tmp();
    child.prototype.constructor = child;
  }
}
$inherits(CompleterImpl_bool, CompleterImpl);
function CompleterImpl_bool() {
  this._futureImpl = new FutureImpl();
}
CompleterImpl_bool.prototype.complete$1 = CompleterImpl_bool.prototype.complete;
// ********** Code for HashMapImplementation **************
function HashMapImplementation() {}
HashMapImplementation.prototype.is$Map = function(){return true};
HashMapImplementation.prototype.forEach = function(f) {
  var length = this._keys.get$length();
  for (var i = (0);
   i < length; i++) {
    var key = this._keys.$index(i);
    if ((null != key) && ((null == key ? null != (const$0000) : key !== const$0000))) {
      f(key, this._values.$index(i));
    }
  }
}
HashMapImplementation.prototype.toString = function() {
  return Maps.mapToString(this);
}
// ********** Code for HashSetImplementation **************
function HashSetImplementation() {}
HashSetImplementation.prototype.is$Collection = function(){return true};
HashSetImplementation.prototype.iterator = function() {
  return new HashSetIterator(this);
}
HashSetImplementation.prototype.toString = function() {
  return Collections.collectionToString(this);
}
// ********** Code for HashSetIterator **************
function HashSetIterator(set_) {
  this._entries = set_._backingMap._keys;
  this._nextValidIndex = (-1);
  this._advance();
}
HashSetIterator.prototype.hasNext = function() {
  var $0;
  if (this._nextValidIndex >= this._entries.get$length()) return false;
  if ((($0 = this._entries.$index(this._nextValidIndex)) == null ? null == (const$0000) : $0 === const$0000)) {
    this._advance();
  }
  return this._nextValidIndex < this._entries.get$length();
}
HashSetIterator.prototype.next = function() {
  if (!this.hasNext()) {
    $throw(const$0001);
  }
  var res = this._entries.$index(this._nextValidIndex);
  this._advance();
  return res;
}
HashSetIterator.prototype._advance = function() {
  var length = this._entries.get$length();
  var entry;
  var deletedKey = const$0000;
  do {
    if (++this._nextValidIndex >= length) break;
    entry = this._entries.$index(this._nextValidIndex);
  }
  while ((null == entry) || ((null == entry ? null == (deletedKey) : entry === deletedKey)))
}
// ********** Code for _DeletedKeySentinel **************
function _DeletedKeySentinel() {

}
// ********** Code for Maps **************
function Maps() {}
Maps.mapToString = function(m) {
  var result = new StringBufferImpl("");
  Maps._emitMap(m, result, new Array());
  return result.toString();
}
Maps._emitMap = function(m, result, visiting) {
  visiting.add(m);
  result.add("{");
  var first = true;
  m.forEach((function (k, v) {
    if (!first) {
      result.add(", ");
    }
    first = false;
    Collections._emitObject(k, result, visiting);
    result.add(": ");
    Collections._emitObject(v, result, visiting);
  })
  );
  result.add("}");
  visiting.removeLast();
}
// ********** Code for DoubleLinkedQueue **************
function DoubleLinkedQueue() {}
DoubleLinkedQueue.prototype.is$Collection = function(){return true};
DoubleLinkedQueue.prototype.iterator = function() {
  return new _DoubleLinkedQueueIterator(this._sentinel);
}
DoubleLinkedQueue.prototype.toString = function() {
  return Collections.collectionToString(this);
}
// ********** Code for _DoubleLinkedQueueIterator **************
function _DoubleLinkedQueueIterator(_sentinel) {
  this._sentinel = _sentinel;
  this._currentEntry = this._sentinel;
}
_DoubleLinkedQueueIterator.prototype.hasNext = function() {
  var $0;
  return (($0 = this._currentEntry._next) == null ? null != (this._sentinel) : $0 !== this._sentinel);
}
_DoubleLinkedQueueIterator.prototype.next = function() {
  if (!this.hasNext()) {
    $throw(const$0001);
  }
  this._currentEntry = this._currentEntry._next;
  return this._currentEntry.get$element();
}
// ********** Code for StringBufferImpl **************
function StringBufferImpl(content) {
  this.clear();
  this.add(content);
}
StringBufferImpl.prototype.add = function(obj) {
  var str = obj.toString();
  if (null == str || str.isEmpty()) return this;
  this._buffer.add(str);
  this._length = this._length + str.length;
  return this;
}
StringBufferImpl.prototype.clear = function() {
  this._buffer = new Array();
  this._length = (0);
  return this;
}
StringBufferImpl.prototype.toString = function() {
  if (this._buffer.get$length() == (0)) return "";
  if (this._buffer.get$length() == (1)) return this._buffer.$index((0));
  var result = StringBase.concatAll(this._buffer);
  this._buffer.clear();
  this._buffer.add(result);
  return result;
}
// ********** Code for StringBase **************
function StringBase() {}
StringBase.join = function(strings, separator) {
  if (strings.get$length() == (0)) return "";
  var s = strings.$index((0));
  for (var i = (1);
   i < strings.get$length(); i++) {
    s = $$add($$add(s, separator), strings.$index(i));
  }
  return s;
}
StringBase.concatAll = function(strings) {
  return StringBase.join(strings, "");
}
// ********** Code for StringImplementation **************
StringImplementation = String;
StringImplementation.prototype.isEmpty = function() {
  return this.length == (0);
}
// ********** Code for _Worker **************
// ********** Code for _ArgumentMismatchException **************
$inherits(_ArgumentMismatchException, ClosureArgumentMismatchException);
function _ArgumentMismatchException(_message) {
  this._dart_coreimpl_message = _message;
  ClosureArgumentMismatchException.call(this);
}
_ArgumentMismatchException.prototype.toString = function() {
  return ("Closure argument mismatch: " + this._dart_coreimpl_message);
}
// ********** Code for _FunctionImplementation **************
_FunctionImplementation = Function;
_FunctionImplementation.prototype._genStub = function(argsLength, names) {
      // Fast path #1: if no named arguments and arg count matches
      if (this.length == argsLength && !names) {
        return this;
      }

      var paramsNamed = this.$optional ? (this.$optional.length / 2) : 0;
      var paramsBare = this.length - paramsNamed;
      var argsNamed = names ? names.length : 0;
      var argsBare = argsLength - argsNamed;

      // Check we got the right number of arguments
      if (argsBare < paramsBare || argsLength > this.length ||
          argsNamed > paramsNamed) {
        return function() {
          $throw(new _ArgumentMismatchException(
            'Wrong number of arguments to function. Expected ' + paramsBare +
            ' positional arguments and at most ' + paramsNamed +
            ' named arguments, but got ' + argsBare +
            ' positional arguments and ' + argsNamed + ' named arguments.'));
        };
      }

      // First, fill in all of the default values
      var p = new Array(paramsBare);
      if (paramsNamed) {
        p = p.concat(this.$optional.slice(paramsNamed));
      }
      // Fill in positional args
      var a = new Array(argsLength);
      for (var i = 0; i < argsBare; i++) {
        p[i] = a[i] = '$' + i;
      }
      // Then overwrite with supplied values for optional args
      var lastParameterIndex;
      var namesInOrder = true;
      for (var i = 0; i < argsNamed; i++) {
        var name = names[i];
        a[i + argsBare] = name;
        var j = this.$optional.indexOf(name);
        if (j < 0 || j >= paramsNamed) {
          return function() {
            $throw(new _ArgumentMismatchException(
              'Named argument "' + name + '" was not expected by function.' +
              ' Did you forget to mark the function parameter [optional]?'));
          };
        } else if (lastParameterIndex && lastParameterIndex > j) {
          namesInOrder = false;
        }
        p[j + paramsBare] = name;
        lastParameterIndex = j;
      }

      if (this.length == argsLength && namesInOrder) {
        // Fast path #2: named arguments, but they're in order and all supplied.
        return this;
      }

      // Note: using Function instead of 'eval' to get a clean scope.
      // TODO(jmesserly): evaluate the performance of these stubs.
      var f = 'function(' + a.join(',') + '){return $f(' + p.join(',') + ');}';
      return new Function('$f', 'return ' + f + '').call(null, this);
    
}
// ********** Code for top level **************
//  ********** Library dom **************
// ********** Code for _DOMTypeJs **************
// ********** Code for _EventTargetJs **************
// ********** Code for _AbstractWorkerJs **************
// ********** Code for _ArrayBufferJs **************
// ********** Code for _ArrayBufferViewJs **************
// ********** Code for _NodeJs **************
// ********** Code for _AttrJs **************
// ********** Code for _AudioBufferJs **************
// ********** Code for _AudioNodeJs **************
// ********** Code for _AudioSourceNodeJs **************
// ********** Code for _AudioBufferSourceNodeJs **************
// ********** Code for _AudioChannelMergerJs **************
// ********** Code for _AudioChannelSplitterJs **************
// ********** Code for _AudioContextJs **************
// ********** Code for _AudioDestinationNodeJs **************
// ********** Code for _AudioParamJs **************
// ********** Code for _AudioGainJs **************
// ********** Code for _AudioGainNodeJs **************
// ********** Code for _AudioListenerJs **************
// ********** Code for _AudioPannerNodeJs **************
// ********** Code for _EventJs **************
function $dynamic(name) {
  var f = Object.prototype[name];
  if (f && f.methods) return f.methods;

  var methods = {};
  if (f) methods.Object = f;
  function $dynamicBind() {
    // Find the target method
    var obj = this;
    var tag = obj.$typeNameOf();
    var method = methods[tag];
    if (!method) {
      var table = $dynamicMetadata;
      for (var i = 0; i < table.length; i++) {
        var entry = table[i];
        if (entry.map.hasOwnProperty(tag)) {
          method = methods[entry.tag];
          if (method) break;
        }
      }
    }
    method = method || methods.Object;
    var proto = Object.getPrototypeOf(obj);
    if (!proto.hasOwnProperty(name)) {
      $defProp(proto, name, method);
    }

    return method.apply(this, Array.prototype.slice.call(arguments));
  };
  $dynamicBind.methods = methods;
  $defProp(Object.prototype, name, $dynamicBind);
  return methods;
}
if (typeof $dynamicMetadata == 'undefined') $dynamicMetadata = [];
$dynamic("get$target").Event = function() { return this.target; };
// ********** Code for _AudioProcessingEventJs **************
// ********** Code for _BarInfoJs **************
// ********** Code for _BeforeLoadEventJs **************
// ********** Code for _BiquadFilterNodeJs **************
// ********** Code for _BlobJs **************
// ********** Code for _CharacterDataJs **************
// ********** Code for _TextJs **************
// ********** Code for _CDATASectionJs **************
// ********** Code for _CSSRuleJs **************
// ********** Code for _CSSCharsetRuleJs **************
// ********** Code for _CSSFontFaceRuleJs **************
// ********** Code for _CSSImportRuleJs **************
// ********** Code for _CSSMediaRuleJs **************
// ********** Code for _CSSPageRuleJs **************
// ********** Code for _CSSValueJs **************
// ********** Code for _CSSPrimitiveValueJs **************
// ********** Code for _CSSRuleListJs **************
// ********** Code for _CSSStyleDeclarationJs **************
// ********** Code for _CSSStyleRuleJs **************
// ********** Code for _StyleSheetJs **************
// ********** Code for _CSSStyleSheetJs **************
// ********** Code for _CSSUnknownRuleJs **************
// ********** Code for _CSSValueListJs **************
// ********** Code for _CanvasGradientJs **************
// ********** Code for _CanvasPatternJs **************
// ********** Code for _CanvasPixelArrayJs **************
$dynamic("is$List").CanvasPixelArray = function(){return true};
$dynamic("is$Collection").CanvasPixelArray = function(){return true};
$dynamic("get$length").CanvasPixelArray = function() { return this.length; };
$dynamic("$index").CanvasPixelArray = function(index) {
  return this[index];
}
$dynamic("iterator").CanvasPixelArray = function() {
  return new _FixedSizeListIterator_int(this);
}
$dynamic("add").CanvasPixelArray = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
// ********** Code for _CanvasRenderingContextJs **************
// ********** Code for _CanvasRenderingContext2DJs **************
// ********** Code for _ClientRectJs **************
// ********** Code for _ClientRectListJs **************
// ********** Code for _ClipboardJs **************
// ********** Code for _CloseEventJs **************
// ********** Code for _CommentJs **************
// ********** Code for _UIEventJs **************
// ********** Code for _CompositionEventJs **************
// ********** Code for _ConsoleJs **************
_ConsoleJs = (typeof console == 'undefined' ? {} : console);
_ConsoleJs.get$error = function() {
  return this.error.bind(this);
}
Function.prototype.bind = Function.prototype.bind ||
  function(thisObj) {
    var func = this;
    if (arguments.length > 1) {
      var boundArgs = Array.prototype.slice.call(arguments, 1);
      return function() {
        // Prepend the bound arguments to the current arguments.
        var newArgs = Array.prototype.slice.call(arguments);
        Array.prototype.unshift.apply(newArgs, boundArgs);
        return func.apply(thisObj, newArgs);
      };
    } else {
      return function() {
        return func.apply(thisObj, arguments);
      };
    }
  };
// ********** Code for _ConvolverNodeJs **************
// ********** Code for _CoordinatesJs **************
// ********** Code for _CounterJs **************
// ********** Code for _CryptoJs **************
// ********** Code for _CustomEventJs **************
// ********** Code for _DOMApplicationCacheJs **************
// ********** Code for _DOMExceptionJs **************
// ********** Code for _DOMFileSystemJs **************
// ********** Code for _DOMFileSystemSyncJs **************
// ********** Code for _DOMFormDataJs **************
// ********** Code for _DOMImplementationJs **************
// ********** Code for _DOMMimeTypeJs **************
// ********** Code for _DOMMimeTypeArrayJs **************
// ********** Code for _DOMParserJs **************
// ********** Code for _DOMPluginJs **************
// ********** Code for _DOMPluginArrayJs **************
// ********** Code for _DOMSelectionJs **************
// ********** Code for _DOMTokenListJs **************
// ********** Code for _DOMSettableTokenListJs **************
// ********** Code for _DOMURLJs **************
// ********** Code for _DOMWindowJs **************
// ********** Code for _DataTransferItemJs **************
// ********** Code for _DataTransferItemListJs **************
// ********** Code for _DataViewJs **************
// ********** Code for _DatabaseJs **************
// ********** Code for _DatabaseSyncJs **************
// ********** Code for _WorkerContextJs **************
// ********** Code for _DedicatedWorkerContextJs **************
// ********** Code for _DelayNodeJs **************
// ********** Code for _DeviceMotionEventJs **************
// ********** Code for _DeviceOrientationEventJs **************
// ********** Code for _EntryJs **************
// ********** Code for _DirectoryEntryJs **************
// ********** Code for _EntrySyncJs **************
// ********** Code for _DirectoryEntrySyncJs **************
// ********** Code for _DirectoryReaderJs **************
// ********** Code for _DirectoryReaderSyncJs **************
// ********** Code for _DocumentJs **************
// ********** Code for _DocumentFragmentJs **************
// ********** Code for _DocumentTypeJs **************
// ********** Code for _DynamicsCompressorNodeJs **************
// ********** Code for _ElementJs **************
// ********** Code for _ElementTimeControlJs **************
// ********** Code for _ElementTraversalJs **************
// ********** Code for _EntityJs **************
// ********** Code for _EntityReferenceJs **************
// ********** Code for _EntryArrayJs **************
// ********** Code for _EntryArraySyncJs **************
// ********** Code for _ErrorEventJs **************
// ********** Code for _EventExceptionJs **************
// ********** Code for _EventSourceJs **************
// ********** Code for _FileJs **************
// ********** Code for _FileEntryJs **************
// ********** Code for _FileEntrySyncJs **************
// ********** Code for _FileErrorJs **************
// ********** Code for _FileExceptionJs **************
// ********** Code for _FileListJs **************
// ********** Code for _FileReaderJs **************
$dynamic("get$error").FileReader = function() { return this.error; };
$dynamic("get$result").FileReader = function() { return this.result; };
// ********** Code for _FileReaderSyncJs **************
// ********** Code for _FileWriterJs **************
$dynamic("get$error").FileWriter = function() { return this.error; };
// ********** Code for _FileWriterSyncJs **************
// ********** Code for _Float32ArrayJs **************
var _Float32ArrayJs = {};
$dynamic("is$List").Float32Array = function(){return true};
$dynamic("is$Collection").Float32Array = function(){return true};
$dynamic("get$length").Float32Array = function() { return this.length; };
$dynamic("$index").Float32Array = function(index) {
  return this[index];
}
$dynamic("iterator").Float32Array = function() {
  return new _FixedSizeListIterator_num(this);
}
$dynamic("add").Float32Array = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
// ********** Code for _Float64ArrayJs **************
var _Float64ArrayJs = {};
$dynamic("is$List").Float64Array = function(){return true};
$dynamic("is$Collection").Float64Array = function(){return true};
$dynamic("get$length").Float64Array = function() { return this.length; };
$dynamic("$index").Float64Array = function(index) {
  return this[index];
}
$dynamic("iterator").Float64Array = function() {
  return new _FixedSizeListIterator_num(this);
}
$dynamic("add").Float64Array = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
// ********** Code for _GeolocationJs **************
// ********** Code for _GeopositionJs **************
// ********** Code for _HTMLAllCollectionJs **************
// ********** Code for _HTMLElementJs **************
// ********** Code for _HTMLAnchorElementJs **************
$dynamic("get$target").HTMLAnchorElement = function() { return this.target; };
// ********** Code for _HTMLAppletElementJs **************
// ********** Code for _HTMLAreaElementJs **************
$dynamic("get$target").HTMLAreaElement = function() { return this.target; };
// ********** Code for _HTMLMediaElementJs **************
$dynamic("get$error").HTMLMediaElement = function() { return this.error; };
// ********** Code for _HTMLAudioElementJs **************
// ********** Code for _HTMLBRElementJs **************
// ********** Code for _HTMLBaseElementJs **************
$dynamic("get$target").HTMLBaseElement = function() { return this.target; };
// ********** Code for _HTMLBaseFontElementJs **************
// ********** Code for _HTMLBodyElementJs **************
// ********** Code for _HTMLButtonElementJs **************
// ********** Code for _HTMLCanvasElementJs **************
// ********** Code for _HTMLCollectionJs **************
$dynamic("is$List").HTMLCollection = function(){return true};
$dynamic("is$Collection").HTMLCollection = function(){return true};
$dynamic("get$length").HTMLCollection = function() { return this.length; };
$dynamic("$index").HTMLCollection = function(index) {
  return this[index];
}
$dynamic("iterator").HTMLCollection = function() {
  return new _FixedSizeListIterator_dom_Node(this);
}
$dynamic("add").HTMLCollection = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
// ********** Code for _HTMLContentElementJs **************
// ********** Code for _HTMLDListElementJs **************
// ********** Code for _HTMLDetailsElementJs **************
// ********** Code for _HTMLDirectoryElementJs **************
// ********** Code for _HTMLDivElementJs **************
// ********** Code for _HTMLDocumentJs **************
$dynamic("open$0").HTMLDocument = function() {
  return this.open();
};
// ********** Code for _HTMLEmbedElementJs **************
// ********** Code for _HTMLFieldSetElementJs **************
// ********** Code for _HTMLFontElementJs **************
// ********** Code for _HTMLFormElementJs **************
$dynamic("get$target").HTMLFormElement = function() { return this.target; };
// ********** Code for _HTMLFrameElementJs **************
// ********** Code for _HTMLFrameSetElementJs **************
// ********** Code for _HTMLHRElementJs **************
// ********** Code for _HTMLHeadElementJs **************
// ********** Code for _HTMLHeadingElementJs **************
// ********** Code for _HTMLHtmlElementJs **************
// ********** Code for _HTMLIFrameElementJs **************
// ********** Code for _HTMLImageElementJs **************
// ********** Code for _HTMLInputElementJs **************
// ********** Code for _HTMLKeygenElementJs **************
// ********** Code for _HTMLLIElementJs **************
// ********** Code for _HTMLLabelElementJs **************
// ********** Code for _HTMLLegendElementJs **************
// ********** Code for _HTMLLinkElementJs **************
$dynamic("get$target").HTMLLinkElement = function() { return this.target; };
// ********** Code for _HTMLMapElementJs **************
// ********** Code for _HTMLMarqueeElementJs **************
// ********** Code for _HTMLMenuElementJs **************
// ********** Code for _HTMLMetaElementJs **************
// ********** Code for _HTMLMeterElementJs **************
// ********** Code for _HTMLModElementJs **************
// ********** Code for _HTMLOListElementJs **************
// ********** Code for _HTMLObjectElementJs **************
// ********** Code for _HTMLOptGroupElementJs **************
// ********** Code for _HTMLOptionElementJs **************
// ********** Code for _HTMLOptionsCollectionJs **************
$dynamic("is$List").HTMLOptionsCollection = function(){return true};
$dynamic("is$Collection").HTMLOptionsCollection = function(){return true};
$dynamic("get$length").HTMLOptionsCollection = function() {
  return this.length;
}
// ********** Code for _HTMLOutputElementJs **************
// ********** Code for _HTMLParagraphElementJs **************
// ********** Code for _HTMLParamElementJs **************
// ********** Code for _HTMLPreElementJs **************
// ********** Code for _HTMLProgressElementJs **************
// ********** Code for _HTMLQuoteElementJs **************
// ********** Code for _HTMLScriptElementJs **************
// ********** Code for _HTMLSelectElementJs **************
// ********** Code for _HTMLShadowElementJs **************
// ********** Code for _HTMLSourceElementJs **************
// ********** Code for _HTMLSpanElementJs **************
// ********** Code for _HTMLStyleElementJs **************
// ********** Code for _HTMLTableCaptionElementJs **************
// ********** Code for _HTMLTableCellElementJs **************
// ********** Code for _HTMLTableColElementJs **************
// ********** Code for _HTMLTableElementJs **************
// ********** Code for _HTMLTableRowElementJs **************
// ********** Code for _HTMLTableSectionElementJs **************
// ********** Code for _HTMLTextAreaElementJs **************
// ********** Code for _HTMLTitleElementJs **************
// ********** Code for _HTMLTrackElementJs **************
// ********** Code for _HTMLUListElementJs **************
// ********** Code for _HTMLUnknownElementJs **************
// ********** Code for _HTMLVideoElementJs **************
// ********** Code for _HashChangeEventJs **************
// ********** Code for _HighPass2FilterNodeJs **************
// ********** Code for _HistoryJs **************
// ********** Code for _IDBAnyJs **************
// ********** Code for _IDBCursorJs **************
// ********** Code for _IDBCursorWithValueJs **************
// ********** Code for _IDBDatabaseJs **************
// ********** Code for _IDBDatabaseErrorJs **************
// ********** Code for _IDBDatabaseExceptionJs **************
// ********** Code for _IDBFactoryJs **************
// ********** Code for _IDBIndexJs **************
// ********** Code for _IDBKeyJs **************
// ********** Code for _IDBKeyRangeJs **************
// ********** Code for _IDBObjectStoreJs **************
$dynamic("getObject").IDBObjectStore = function(key) {
  return this.get(key);
}
// ********** Code for _IDBRequestJs **************
$dynamic("get$result").IDBRequest = function() { return this.result; };
// ********** Code for _IDBTransactionJs **************
// ********** Code for _IDBVersionChangeEventJs **************
// ********** Code for _IDBVersionChangeRequestJs **************
// ********** Code for _ImageDataJs **************
// ********** Code for _Int16ArrayJs **************
var _Int16ArrayJs = {};
$dynamic("is$List").Int16Array = function(){return true};
$dynamic("is$Collection").Int16Array = function(){return true};
$dynamic("get$length").Int16Array = function() { return this.length; };
$dynamic("$index").Int16Array = function(index) {
  return this[index];
}
$dynamic("iterator").Int16Array = function() {
  return new _FixedSizeListIterator_int(this);
}
$dynamic("add").Int16Array = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
// ********** Code for _Int32ArrayJs **************
var _Int32ArrayJs = {};
$dynamic("is$List").Int32Array = function(){return true};
$dynamic("is$Collection").Int32Array = function(){return true};
$dynamic("get$length").Int32Array = function() { return this.length; };
$dynamic("$index").Int32Array = function(index) {
  return this[index];
}
$dynamic("iterator").Int32Array = function() {
  return new _FixedSizeListIterator_int(this);
}
$dynamic("add").Int32Array = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
// ********** Code for _Int8ArrayJs **************
var _Int8ArrayJs = {};
$dynamic("is$List").Int8Array = function(){return true};
$dynamic("is$Collection").Int8Array = function(){return true};
$dynamic("get$length").Int8Array = function() { return this.length; };
$dynamic("$index").Int8Array = function(index) {
  return this[index];
}
$dynamic("iterator").Int8Array = function() {
  return new _FixedSizeListIterator_int(this);
}
$dynamic("add").Int8Array = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
// ********** Code for _JavaScriptAudioNodeJs **************
// ********** Code for _JavaScriptCallFrameJs **************
// ********** Code for _KeyboardEventJs **************
// ********** Code for _MediaStreamJs **************
// ********** Code for _LocalMediaStreamJs **************
// ********** Code for _LocationJs **************
// ********** Code for _LowPass2FilterNodeJs **************
// ********** Code for _MediaControllerJs **************
// ********** Code for _MediaElementAudioSourceNodeJs **************
// ********** Code for _MediaErrorJs **************
// ********** Code for _MediaListJs **************
$dynamic("is$List").MediaList = function(){return true};
$dynamic("is$Collection").MediaList = function(){return true};
$dynamic("get$length").MediaList = function() { return this.length; };
$dynamic("$index").MediaList = function(index) {
  return this[index];
}
$dynamic("iterator").MediaList = function() {
  return new _FixedSizeListIterator_dart_core_String(this);
}
$dynamic("add").MediaList = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
// ********** Code for _MediaQueryListJs **************
// ********** Code for _MediaQueryListListenerJs **************
// ********** Code for _MediaStreamEventJs **************
// ********** Code for _MediaStreamListJs **************
// ********** Code for _MediaStreamTrackJs **************
// ********** Code for _MediaStreamTrackListJs **************
// ********** Code for _MemoryInfoJs **************
// ********** Code for _MessageChannelJs **************
// ********** Code for _MessageEventJs **************
// ********** Code for _MessagePortJs **************
// ********** Code for _MetadataJs **************
// ********** Code for _MouseEventJs **************
// ********** Code for _MutationEventJs **************
// ********** Code for _NamedNodeMapJs **************
$dynamic("is$List").NamedNodeMap = function(){return true};
$dynamic("is$Collection").NamedNodeMap = function(){return true};
$dynamic("get$length").NamedNodeMap = function() { return this.length; };
$dynamic("$index").NamedNodeMap = function(index) {
  return this[index];
}
$dynamic("iterator").NamedNodeMap = function() {
  return new _FixedSizeListIterator_dom_Node(this);
}
$dynamic("add").NamedNodeMap = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
// ********** Code for _NavigatorJs **************
// ********** Code for _NavigatorUserMediaErrorJs **************
// ********** Code for _NodeFilterJs **************
// ********** Code for _NodeIteratorJs **************
// ********** Code for _NodeListJs **************
$dynamic("is$List").NodeList = function(){return true};
$dynamic("is$Collection").NodeList = function(){return true};
$dynamic("get$length").NodeList = function() { return this.length; };
$dynamic("$index").NodeList = function(index) {
  return this[index];
}
$dynamic("iterator").NodeList = function() {
  return new _FixedSizeListIterator_dom_Node(this);
}
$dynamic("add").NodeList = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
// ********** Code for _NodeSelectorJs **************
// ********** Code for _NotationJs **************
// ********** Code for _NotificationJs **************
// ********** Code for _NotificationCenterJs **************
// ********** Code for _OESStandardDerivativesJs **************
// ********** Code for _OESTextureFloatJs **************
// ********** Code for _OESVertexArrayObjectJs **************
// ********** Code for _OfflineAudioCompletionEventJs **************
// ********** Code for _OperationNotAllowedExceptionJs **************
// ********** Code for _OverflowEventJs **************
// ********** Code for _PageTransitionEventJs **************
// ********** Code for _PeerConnectionJs **************
// ********** Code for _PerformanceJs **************
// ********** Code for _PerformanceNavigationJs **************
// ********** Code for _PerformanceTimingJs **************
// ********** Code for _PopStateEventJs **************
// ********** Code for _PositionErrorJs **************
// ********** Code for _ProcessingInstructionJs **************
$dynamic("get$target").ProcessingInstruction = function() { return this.target; };
// ********** Code for _ProgressEventJs **************
// ********** Code for _RGBColorJs **************
// ********** Code for _RangeJs **************
// ********** Code for _RangeExceptionJs **************
// ********** Code for _RealtimeAnalyserNodeJs **************
// ********** Code for _RectJs **************
// ********** Code for _SQLErrorJs **************
// ********** Code for _SQLExceptionJs **************
// ********** Code for _SQLResultSetJs **************
// ********** Code for _SQLResultSetRowListJs **************
// ********** Code for _SQLTransactionJs **************
// ********** Code for _SQLTransactionSyncJs **************
// ********** Code for _SVGElementJs **************
// ********** Code for _SVGAElementJs **************
$dynamic("get$target").SVGAElement = function() { return this.target; };
// ********** Code for _SVGAltGlyphDefElementJs **************
// ********** Code for _SVGTextContentElementJs **************
// ********** Code for _SVGTextPositioningElementJs **************
// ********** Code for _SVGAltGlyphElementJs **************
// ********** Code for _SVGAltGlyphItemElementJs **************
// ********** Code for _SVGAngleJs **************
// ********** Code for _SVGAnimationElementJs **************
// ********** Code for _SVGAnimateColorElementJs **************
// ********** Code for _SVGAnimateElementJs **************
// ********** Code for _SVGAnimateMotionElementJs **************
// ********** Code for _SVGAnimateTransformElementJs **************
// ********** Code for _SVGAnimatedAngleJs **************
// ********** Code for _SVGAnimatedBooleanJs **************
// ********** Code for _SVGAnimatedEnumerationJs **************
// ********** Code for _SVGAnimatedIntegerJs **************
// ********** Code for _SVGAnimatedLengthJs **************
// ********** Code for _SVGAnimatedLengthListJs **************
// ********** Code for _SVGAnimatedNumberJs **************
// ********** Code for _SVGAnimatedNumberListJs **************
// ********** Code for _SVGAnimatedPreserveAspectRatioJs **************
// ********** Code for _SVGAnimatedRectJs **************
// ********** Code for _SVGAnimatedStringJs **************
// ********** Code for _SVGAnimatedTransformListJs **************
// ********** Code for _SVGCircleElementJs **************
// ********** Code for _SVGClipPathElementJs **************
// ********** Code for _SVGColorJs **************
// ********** Code for _SVGComponentTransferFunctionElementJs **************
// ********** Code for _SVGCursorElementJs **************
// ********** Code for _SVGDefsElementJs **************
// ********** Code for _SVGDescElementJs **************
// ********** Code for _SVGDocumentJs **************
// ********** Code for _SVGElementInstanceJs **************
// ********** Code for _SVGElementInstanceListJs **************
// ********** Code for _SVGEllipseElementJs **************
// ********** Code for _SVGExceptionJs **************
// ********** Code for _SVGExternalResourcesRequiredJs **************
// ********** Code for _SVGFEBlendElementJs **************
$dynamic("get$result").SVGFEBlendElement = function() { return this.result; };
// ********** Code for _SVGFEColorMatrixElementJs **************
$dynamic("get$result").SVGFEColorMatrixElement = function() { return this.result; };
// ********** Code for _SVGFEComponentTransferElementJs **************
$dynamic("get$result").SVGFEComponentTransferElement = function() { return this.result; };
// ********** Code for _SVGFECompositeElementJs **************
$dynamic("get$result").SVGFECompositeElement = function() { return this.result; };
// ********** Code for _SVGFEConvolveMatrixElementJs **************
$dynamic("get$result").SVGFEConvolveMatrixElement = function() { return this.result; };
// ********** Code for _SVGFEDiffuseLightingElementJs **************
$dynamic("get$result").SVGFEDiffuseLightingElement = function() { return this.result; };
// ********** Code for _SVGFEDisplacementMapElementJs **************
$dynamic("get$result").SVGFEDisplacementMapElement = function() { return this.result; };
// ********** Code for _SVGFEDistantLightElementJs **************
// ********** Code for _SVGFEDropShadowElementJs **************
$dynamic("get$result").SVGFEDropShadowElement = function() { return this.result; };
// ********** Code for _SVGFEFloodElementJs **************
$dynamic("get$result").SVGFEFloodElement = function() { return this.result; };
// ********** Code for _SVGFEFuncAElementJs **************
// ********** Code for _SVGFEFuncBElementJs **************
// ********** Code for _SVGFEFuncGElementJs **************
// ********** Code for _SVGFEFuncRElementJs **************
// ********** Code for _SVGFEGaussianBlurElementJs **************
$dynamic("get$result").SVGFEGaussianBlurElement = function() { return this.result; };
// ********** Code for _SVGFEImageElementJs **************
$dynamic("get$result").SVGFEImageElement = function() { return this.result; };
// ********** Code for _SVGFEMergeElementJs **************
$dynamic("get$result").SVGFEMergeElement = function() { return this.result; };
// ********** Code for _SVGFEMergeNodeElementJs **************
// ********** Code for _SVGFEMorphologyElementJs **************
$dynamic("get$result").SVGFEMorphologyElement = function() { return this.result; };
// ********** Code for _SVGFEOffsetElementJs **************
$dynamic("get$result").SVGFEOffsetElement = function() { return this.result; };
// ********** Code for _SVGFEPointLightElementJs **************
// ********** Code for _SVGFESpecularLightingElementJs **************
$dynamic("get$result").SVGFESpecularLightingElement = function() { return this.result; };
// ********** Code for _SVGFESpotLightElementJs **************
// ********** Code for _SVGFETileElementJs **************
$dynamic("get$result").SVGFETileElement = function() { return this.result; };
// ********** Code for _SVGFETurbulenceElementJs **************
$dynamic("get$result").SVGFETurbulenceElement = function() { return this.result; };
// ********** Code for _SVGFilterElementJs **************
// ********** Code for _SVGStylableJs **************
// ********** Code for _SVGFilterPrimitiveStandardAttributesJs **************
$dynamic("get$result").SVGFilterPrimitiveStandardAttributes = function() { return this.result; };
// ********** Code for _SVGFitToViewBoxJs **************
// ********** Code for _SVGFontElementJs **************
// ********** Code for _SVGFontFaceElementJs **************
// ********** Code for _SVGFontFaceFormatElementJs **************
// ********** Code for _SVGFontFaceNameElementJs **************
// ********** Code for _SVGFontFaceSrcElementJs **************
// ********** Code for _SVGFontFaceUriElementJs **************
// ********** Code for _SVGForeignObjectElementJs **************
// ********** Code for _SVGGElementJs **************
// ********** Code for _SVGGlyphElementJs **************
// ********** Code for _SVGGlyphRefElementJs **************
// ********** Code for _SVGGradientElementJs **************
// ********** Code for _SVGHKernElementJs **************
// ********** Code for _SVGImageElementJs **************
// ********** Code for _SVGLangSpaceJs **************
// ********** Code for _SVGLengthJs **************
// ********** Code for _SVGLengthListJs **************
// ********** Code for _SVGLineElementJs **************
// ********** Code for _SVGLinearGradientElementJs **************
// ********** Code for _SVGLocatableJs **************
// ********** Code for _SVGMPathElementJs **************
// ********** Code for _SVGMarkerElementJs **************
// ********** Code for _SVGMaskElementJs **************
// ********** Code for _SVGMatrixJs **************
// ********** Code for _SVGMetadataElementJs **************
// ********** Code for _SVGMissingGlyphElementJs **************
// ********** Code for _SVGNumberJs **************
// ********** Code for _SVGNumberListJs **************
// ********** Code for _SVGPaintJs **************
// ********** Code for _SVGPathElementJs **************
// ********** Code for _SVGPathSegJs **************
// ********** Code for _SVGPathSegArcAbsJs **************
// ********** Code for _SVGPathSegArcRelJs **************
// ********** Code for _SVGPathSegClosePathJs **************
// ********** Code for _SVGPathSegCurvetoCubicAbsJs **************
// ********** Code for _SVGPathSegCurvetoCubicRelJs **************
// ********** Code for _SVGPathSegCurvetoCubicSmoothAbsJs **************
// ********** Code for _SVGPathSegCurvetoCubicSmoothRelJs **************
// ********** Code for _SVGPathSegCurvetoQuadraticAbsJs **************
// ********** Code for _SVGPathSegCurvetoQuadraticRelJs **************
// ********** Code for _SVGPathSegCurvetoQuadraticSmoothAbsJs **************
// ********** Code for _SVGPathSegCurvetoQuadraticSmoothRelJs **************
// ********** Code for _SVGPathSegLinetoAbsJs **************
// ********** Code for _SVGPathSegLinetoHorizontalAbsJs **************
// ********** Code for _SVGPathSegLinetoHorizontalRelJs **************
// ********** Code for _SVGPathSegLinetoRelJs **************
// ********** Code for _SVGPathSegLinetoVerticalAbsJs **************
// ********** Code for _SVGPathSegLinetoVerticalRelJs **************
// ********** Code for _SVGPathSegListJs **************
// ********** Code for _SVGPathSegMovetoAbsJs **************
// ********** Code for _SVGPathSegMovetoRelJs **************
// ********** Code for _SVGPatternElementJs **************
// ********** Code for _SVGPointJs **************
// ********** Code for _SVGPointListJs **************
// ********** Code for _SVGPolygonElementJs **************
// ********** Code for _SVGPolylineElementJs **************
// ********** Code for _SVGPreserveAspectRatioJs **************
// ********** Code for _SVGRadialGradientElementJs **************
// ********** Code for _SVGRectJs **************
// ********** Code for _SVGRectElementJs **************
// ********** Code for _SVGRenderingIntentJs **************
// ********** Code for _SVGSVGElementJs **************
// ********** Code for _SVGScriptElementJs **************
// ********** Code for _SVGSetElementJs **************
// ********** Code for _SVGStopElementJs **************
// ********** Code for _SVGStringListJs **************
// ********** Code for _SVGStyleElementJs **************
// ********** Code for _SVGSwitchElementJs **************
// ********** Code for _SVGSymbolElementJs **************
// ********** Code for _SVGTRefElementJs **************
// ********** Code for _SVGTSpanElementJs **************
// ********** Code for _SVGTestsJs **************
// ********** Code for _SVGTextElementJs **************
// ********** Code for _SVGTextPathElementJs **************
// ********** Code for _SVGTitleElementJs **************
// ********** Code for _SVGTransformJs **************
// ********** Code for _SVGTransformListJs **************
// ********** Code for _SVGTransformableJs **************
// ********** Code for _SVGURIReferenceJs **************
// ********** Code for _SVGUnitTypesJs **************
// ********** Code for _SVGUseElementJs **************
// ********** Code for _SVGVKernElementJs **************
// ********** Code for _SVGViewElementJs **************
// ********** Code for _SVGZoomAndPanJs **************
// ********** Code for _SVGViewSpecJs **************
// ********** Code for _SVGZoomEventJs **************
// ********** Code for _ScreenJs **************
// ********** Code for _ScriptProfileJs **************
// ********** Code for _ScriptProfileNodeJs **************
// ********** Code for _ShadowRootJs **************
// ********** Code for _SharedWorkerJs **************
// ********** Code for _SharedWorkerContextJs **************
// ********** Code for _SpeechInputEventJs **************
// ********** Code for _SpeechInputResultJs **************
// ********** Code for _SpeechInputResultListJs **************
// ********** Code for _StorageJs **************
// ********** Code for _StorageEventJs **************
// ********** Code for _StorageInfoJs **************
// ********** Code for _StyleMediaJs **************
// ********** Code for _StyleSheetListJs **************
$dynamic("is$List").StyleSheetList = function(){return true};
$dynamic("is$Collection").StyleSheetList = function(){return true};
$dynamic("get$length").StyleSheetList = function() { return this.length; };
$dynamic("$index").StyleSheetList = function(index) {
  return this[index];
}
$dynamic("iterator").StyleSheetList = function() {
  return new _FixedSizeListIterator_dom_StyleSheet(this);
}
$dynamic("add").StyleSheetList = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
// ********** Code for _TextEventJs **************
// ********** Code for _TextMetricsJs **************
// ********** Code for _TextTrackJs **************
// ********** Code for _TextTrackCueJs **************
// ********** Code for _TextTrackCueListJs **************
// ********** Code for _TextTrackListJs **************
// ********** Code for _TimeRangesJs **************
// ********** Code for _TouchJs **************
$dynamic("get$target").Touch = function() { return this.target; };
// ********** Code for _TouchEventJs **************
// ********** Code for _TouchListJs **************
$dynamic("is$List").TouchList = function(){return true};
$dynamic("is$Collection").TouchList = function(){return true};
$dynamic("get$length").TouchList = function() { return this.length; };
$dynamic("$index").TouchList = function(index) {
  return this[index];
}
$dynamic("iterator").TouchList = function() {
  return new _FixedSizeListIterator_dom_Touch(this);
}
$dynamic("add").TouchList = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
// ********** Code for _TrackEventJs **************
// ********** Code for _TreeWalkerJs **************
// ********** Code for _Uint16ArrayJs **************
var _Uint16ArrayJs = {};
$dynamic("is$List").Uint16Array = function(){return true};
$dynamic("is$Collection").Uint16Array = function(){return true};
$dynamic("get$length").Uint16Array = function() { return this.length; };
$dynamic("$index").Uint16Array = function(index) {
  return this[index];
}
$dynamic("iterator").Uint16Array = function() {
  return new _FixedSizeListIterator_int(this);
}
$dynamic("add").Uint16Array = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
// ********** Code for _Uint32ArrayJs **************
var _Uint32ArrayJs = {};
$dynamic("is$List").Uint32Array = function(){return true};
$dynamic("is$Collection").Uint32Array = function(){return true};
$dynamic("get$length").Uint32Array = function() { return this.length; };
$dynamic("$index").Uint32Array = function(index) {
  return this[index];
}
$dynamic("iterator").Uint32Array = function() {
  return new _FixedSizeListIterator_int(this);
}
$dynamic("add").Uint32Array = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
// ********** Code for _Uint8ArrayJs **************
var _Uint8ArrayJs = {};
$dynamic("is$List").Uint8Array = function(){return true};
$dynamic("is$Collection").Uint8Array = function(){return true};
$dynamic("get$length").Uint8Array = function() { return this.length; };
$dynamic("$index").Uint8Array = function(index) {
  return this[index];
}
$dynamic("iterator").Uint8Array = function() {
  return new _FixedSizeListIterator_int(this);
}
$dynamic("add").Uint8Array = function(value) {
  $throw(new UnsupportedOperationException("Cannot add to immutable List."));
}
// ********** Code for _Uint8ClampedArrayJs **************
var _Uint8ClampedArrayJs = {};
$dynamic("is$List").Uint8ClampedArray = function(){return true};
$dynamic("is$Collection").Uint8ClampedArray = function(){return true};
// ********** Code for _ValidityStateJs **************
// ********** Code for _WaveShaperNodeJs **************
// ********** Code for _WebGLActiveInfoJs **************
// ********** Code for _WebGLBufferJs **************
// ********** Code for _WebGLCompressedTextureS3TCJs **************
// ********** Code for _WebGLContextAttributesJs **************
// ********** Code for _WebGLContextEventJs **************
// ********** Code for _WebGLDebugRendererInfoJs **************
// ********** Code for _WebGLDebugShadersJs **************
// ********** Code for _WebGLFramebufferJs **************
// ********** Code for _WebGLLoseContextJs **************
// ********** Code for _WebGLProgramJs **************
// ********** Code for _WebGLRenderbufferJs **************
// ********** Code for _WebGLRenderingContextJs **************
// ********** Code for _WebGLShaderJs **************
// ********** Code for _WebGLTextureJs **************
// ********** Code for _WebGLUniformLocationJs **************
// ********** Code for _WebGLVertexArrayObjectOESJs **************
// ********** Code for _WebKitAnimationJs **************
// ********** Code for _WebKitAnimationEventJs **************
// ********** Code for _WebKitAnimationListJs **************
// ********** Code for _WebKitBlobBuilderJs **************
// ********** Code for _WebKitCSSKeyframeRuleJs **************
// ********** Code for _WebKitCSSKeyframesRuleJs **************
// ********** Code for _WebKitCSSMatrixJs **************
// ********** Code for _WebKitCSSRegionRuleJs **************
// ********** Code for _WebKitCSSTransformValueJs **************
// ********** Code for _WebKitNamedFlowJs **************
// ********** Code for _WebKitPointJs **************
// ********** Code for _WebKitTransitionEventJs **************
// ********** Code for _WebSocketJs **************
// ********** Code for _WheelEventJs **************
// ********** Code for _WorkerJs **************
// ********** Code for _WorkerLocationJs **************
// ********** Code for _WorkerNavigatorJs **************
// ********** Code for _XMLHttpRequestJs **************
// ********** Code for _XMLHttpRequestExceptionJs **************
// ********** Code for _XMLHttpRequestProgressEventJs **************
// ********** Code for _XMLHttpRequestUploadJs **************
// ********** Code for _XMLSerializerJs **************
// ********** Code for _XPathEvaluatorJs **************
// ********** Code for _XPathExceptionJs **************
// ********** Code for _XPathExpressionJs **************
// ********** Code for _XPathNSResolverJs **************
// ********** Code for _XPathResultJs **************
// ********** Code for _XSLTProcessorJs **************
// ********** Code for _DOMParserFactoryProvider **************
function _DOMParserFactoryProvider() {}
// ********** Code for _DOMURLFactoryProvider **************
function _DOMURLFactoryProvider() {}
// ********** Code for _EventSourceFactoryProvider **************
function _EventSourceFactoryProvider() {}
// ********** Code for _FileReaderFactoryProvider **************
function _FileReaderFactoryProvider() {}
// ********** Code for _FileReaderSyncFactoryProvider **************
function _FileReaderSyncFactoryProvider() {}
// ********** Code for _HTMLAudioElementFactoryProvider **************
function _HTMLAudioElementFactoryProvider() {}
// ********** Code for _HTMLOptionElementFactoryProvider **************
function _HTMLOptionElementFactoryProvider() {}
// ********** Code for _MediaControllerFactoryProvider **************
function _MediaControllerFactoryProvider() {}
// ********** Code for _MediaStreamFactoryProvider **************
function _MediaStreamFactoryProvider() {}
// ********** Code for _MessageChannelFactoryProvider **************
function _MessageChannelFactoryProvider() {}
// ********** Code for _PeerConnectionFactoryProvider **************
function _PeerConnectionFactoryProvider() {}
// ********** Code for _ShadowRootFactoryProvider **************
function _ShadowRootFactoryProvider() {}
// ********** Code for _SharedWorkerFactoryProvider **************
function _SharedWorkerFactoryProvider() {}
// ********** Code for _TextTrackCueFactoryProvider **************
function _TextTrackCueFactoryProvider() {}
// ********** Code for _WebKitBlobBuilderFactoryProvider **************
function _WebKitBlobBuilderFactoryProvider() {}
// ********** Code for _WebKitCSSMatrixFactoryProvider **************
function _WebKitCSSMatrixFactoryProvider() {}
// ********** Code for _WorkerFactoryProvider **************
function _WorkerFactoryProvider() {}
// ********** Code for _XMLHttpRequestFactoryProvider **************
function _XMLHttpRequestFactoryProvider() {}
// ********** Code for _XMLSerializerFactoryProvider **************
function _XMLSerializerFactoryProvider() {}
// ********** Code for _XPathEvaluatorFactoryProvider **************
function _XPathEvaluatorFactoryProvider() {}
// ********** Code for _XSLTProcessorFactoryProvider **************
function _XSLTProcessorFactoryProvider() {}
// ********** Code for _Collections **************
function _Collections() {}
// ********** Code for _AudioContextFactoryProvider **************
function _AudioContextFactoryProvider() {}
// ********** Code for _TypedArrayFactoryProvider **************
function _TypedArrayFactoryProvider() {}
// ********** Code for _WebKitPointFactoryProvider **************
function _WebKitPointFactoryProvider() {}
// ********** Code for _WebSocketFactoryProvider **************
function _WebSocketFactoryProvider() {}
// ********** Code for _VariableSizeListIterator **************
function _VariableSizeListIterator() {}
_VariableSizeListIterator.prototype.hasNext = function() {
  return this._dom_array.get$length() > this._dom_pos;
}
_VariableSizeListIterator.prototype.next = function() {
  if (!this.hasNext()) {
    $throw(const$0001);
  }
  return this._dom_array.$index(this._dom_pos++);
}
// ********** Code for _FixedSizeListIterator **************
$inherits(_FixedSizeListIterator, _VariableSizeListIterator);
function _FixedSizeListIterator() {}
_FixedSizeListIterator.prototype.hasNext = function() {
  return this._dom_length > this._dom_pos;
}
// ********** Code for _VariableSizeListIterator_dart_core_String **************
$inherits(_VariableSizeListIterator_dart_core_String, _VariableSizeListIterator);
function _VariableSizeListIterator_dart_core_String(array) {
  this._dom_array = array;
  this._dom_pos = (0);
}
// ********** Code for _FixedSizeListIterator_dart_core_String **************
$inherits(_FixedSizeListIterator_dart_core_String, _FixedSizeListIterator);
function _FixedSizeListIterator_dart_core_String(array) {
  this._dom_length = array.get$length();
  _VariableSizeListIterator_dart_core_String.call(this, array);
}
// ********** Code for _VariableSizeListIterator_int **************
$inherits(_VariableSizeListIterator_int, _VariableSizeListIterator);
function _VariableSizeListIterator_int(array) {
  this._dom_array = array;
  this._dom_pos = (0);
}
// ********** Code for _FixedSizeListIterator_int **************
$inherits(_FixedSizeListIterator_int, _FixedSizeListIterator);
function _FixedSizeListIterator_int(array) {
  this._dom_length = array.get$length();
  _VariableSizeListIterator_int.call(this, array);
}
// ********** Code for _VariableSizeListIterator_num **************
$inherits(_VariableSizeListIterator_num, _VariableSizeListIterator);
function _VariableSizeListIterator_num(array) {
  this._dom_array = array;
  this._dom_pos = (0);
}
// ********** Code for _FixedSizeListIterator_num **************
$inherits(_FixedSizeListIterator_num, _FixedSizeListIterator);
function _FixedSizeListIterator_num(array) {
  this._dom_length = array.get$length();
  _VariableSizeListIterator_num.call(this, array);
}
// ********** Code for _VariableSizeListIterator_dom_Node **************
$inherits(_VariableSizeListIterator_dom_Node, _VariableSizeListIterator);
function _VariableSizeListIterator_dom_Node(array) {
  this._dom_array = array;
  this._dom_pos = (0);
}
// ********** Code for _FixedSizeListIterator_dom_Node **************
$inherits(_FixedSizeListIterator_dom_Node, _FixedSizeListIterator);
function _FixedSizeListIterator_dom_Node(array) {
  this._dom_length = array.get$length();
  _VariableSizeListIterator_dom_Node.call(this, array);
}
// ********** Code for _VariableSizeListIterator_dom_StyleSheet **************
$inherits(_VariableSizeListIterator_dom_StyleSheet, _VariableSizeListIterator);
function _VariableSizeListIterator_dom_StyleSheet(array) {
  this._dom_array = array;
  this._dom_pos = (0);
}
// ********** Code for _FixedSizeListIterator_dom_StyleSheet **************
$inherits(_FixedSizeListIterator_dom_StyleSheet, _FixedSizeListIterator);
function _FixedSizeListIterator_dom_StyleSheet(array) {
  this._dom_length = array.get$length();
  _VariableSizeListIterator_dom_StyleSheet.call(this, array);
}
// ********** Code for _VariableSizeListIterator_dom_Touch **************
$inherits(_VariableSizeListIterator_dom_Touch, _VariableSizeListIterator);
function _VariableSizeListIterator_dom_Touch(array) {
  this._dom_array = array;
  this._dom_pos = (0);
}
// ********** Code for _FixedSizeListIterator_dom_Touch **************
$inherits(_FixedSizeListIterator_dom_Touch, _FixedSizeListIterator);
function _FixedSizeListIterator_dom_Touch(array) {
  this._dom_length = array.get$length();
  _VariableSizeListIterator_dom_Touch.call(this, array);
}
// ********** Code for _Lists **************
function _Lists() {}
// ********** Code for top level **************
function get$window() {
  return window;
}
//  ********** Library htmlimpl **************
// ********** Code for _ListWrapper **************
function _ListWrapper() {}
_ListWrapper.prototype.is$List = function(){return true};
_ListWrapper.prototype.is$Collection = function(){return true};
_ListWrapper.prototype.iterator = function() {
  return this._list.iterator();
}
_ListWrapper.prototype.get$length = function() {
  return this._list.get$length();
}
_ListWrapper.prototype.$index = function(index) {
  return this._list.$index(index);
}
_ListWrapper.prototype.add = function(value) {
  return this._list.add(value);
}
_ListWrapper.prototype.clear = function() {
  return this._list.clear();
}
_ListWrapper.prototype.removeLast = function() {
  return this._list.removeLast();
}
// ********** Code for top level **************
var _pendingRequests;
var _pendingMeasurementFrameCallbacks;
//  ********** Library html **************
// ********** Code for top level **************
var secretWindow;
var secretDocument;
//  ********** Library json **************
// ********** Code for top level **************
//  ********** Library lawndart **************
// ********** Code for IndexedDbAdapter **************
function IndexedDbAdapter(dbName, storeName) {
  this.dbName = dbName;
  this.storeName = storeName;
  this.isReady = false;
}
IndexedDbAdapter.prototype.open = function() {
  var $this = this; // closure support
  var completer = new CompleterImpl();
  var request = get$window().webkitIndexedDB.open(this.dbName);
  dart_core_print("requested open");
  request.addEventListener("success", $wrap_call$1((function (e) {
    dart_core_print("success");
    $this._db = e.get$target().get$result();
    $this._initDb(completer);
  })
  ));
  request.addEventListener("error", $wrap_call$1((function (e) {
    dart_core_print("error");
    completer.completeException(e.get$target().get$error());
  })
  ));
  return completer.get$future();
}
IndexedDbAdapter.prototype._initDb = function(completer) {
  var $this = this; // closure support
  if ("1" != this._db.version) {
    var versionChange = this._db.setVersion("1");
    versionChange.addEventListener("success", $wrap_call$1((function (e) {
      $this._db.createObjectStore($this.storeName);
      $this.isReady = true;
      completer.complete(true);
    })
    ));
    versionChange.addEventListener("error", $wrap_call$1((function (e) {
      completer.completeException(e);
    })
    ));
  }
  else {
    this.isReady = true;
    completer.complete(true);
  }
}
IndexedDbAdapter.prototype.save = function(obj, key) {
  if (!this.isReady) $throw("Database not opened");
  var completer = new CompleterImpl();
  var txn = this._db.transaction(this.storeName, (1));
  var objectStore = txn.objectStore(this.storeName);
  key = $$eq(key) ? _uuid() : key;
  var addRequest = objectStore.put(obj, key);
  addRequest.addEventListener("success", $wrap_call$1((function (e) {
    completer.complete(key);
  })
  ));
  addRequest.addEventListener("error", $wrap_call$1((function (e) {
    return completer.completeException(e.get$target().get$error());
  })
  ));
  return completer.get$future();
}
IndexedDbAdapter.prototype.getByKey = function(key) {
  if (!this.isReady) $throw("Database not opened");
  var completer = new CompleterImpl();
  var txn = this._db.transaction(this.storeName, (0));
  var objectStore = txn.objectStore(this.storeName);
  var getRequest = objectStore.getObject(key);
  getRequest.addEventListener("success", $wrap_call$1((function (e) {
    completer.complete(e.get$target().get$result());
  })
  ));
  getRequest.addEventListener("error", $wrap_call$1((function (e) {
    return completer.completeException(e.get$target().get$error());
  })
  ));
  return completer.get$future();
}
IndexedDbAdapter.prototype.nuke = function() {
  if (!this.isReady) $throw("Database not opened");
  var completer = new CompleterImpl_bool();
  var txn = this._db.transaction(this.storeName, (1));
  var objectStore = txn.objectStore(this.storeName);
  var getRequest = objectStore.clear();
  getRequest.addEventListener("success", $wrap_call$1((function (e) {
    completer.complete(true);
  })
  ));
  getRequest.addEventListener("error", $wrap_call$1((function (e) {
    return completer.completeException(e.get$target().get$error());
  })
  ));
  return completer.get$future();
}
IndexedDbAdapter.prototype.open$0 = IndexedDbAdapter.prototype.open;
IndexedDbAdapter.prototype.save$2 = IndexedDbAdapter.prototype.save;
// ********** Code for top level **************
function _uuid() {
  return "RANDOM STRING";
}
//  ********** Library test **************
// ********** Code for top level **************
function main() {
  var idb = new IndexedDbAdapter("test", "test");
  idb.open$0().chain((function (v) {
    dart_core_print("Database opened");
    return idb.nuke();
  })
  ).chain((function (v) {
    dart_core_print("Nuked!");
    return idb.save$2("hello, world", "key");
  })
  ).chain((function (v) {
    dart_core_print("Added!");
    return idb.getByKey("key");
  })
  ).then((function (v) {
    dart_core_print(("Valye is " + v));
  })
  );
}
// 50 dynamic types.
// 85 types
// 7 !leaf
function $dynamicSetMetadata(inputTable) {
  // TODO: Deal with light isolates.
  var table = [];
  for (var i = 0; i < inputTable.length; i++) {
    var tag = inputTable[i][0];
    var tags = inputTable[i][1];
    var map = {};
    var tagNames = tags.split('|');
    for (var j = 0; j < tagNames.length; j++) {
      map[tagNames[j]] = true;
    }
    table.push({tag: tag, tags: tags, map: map});
  }
  $dynamicMetadata = table;
}
(function(){
  var table = [
    // [dynamic-dispatch-tag, tags of classes implementing dynamic-dispatch-tag]
    ['Event', 'Event|AudioProcessingEvent|BeforeLoadEvent|CloseEvent|CustomEvent|DeviceMotionEvent|DeviceOrientationEvent|ErrorEvent|HashChangeEvent|IDBVersionChangeEvent|MediaStreamEvent|MessageEvent|MutationEvent|OfflineAudioCompletionEvent|OverflowEvent|PageTransitionEvent|PopStateEvent|ProgressEvent|XMLHttpRequestProgressEvent|SpeechInputEvent|StorageEvent|TrackEvent|UIEvent|CompositionEvent|KeyboardEvent|MouseEvent|SVGZoomEvent|TextEvent|TouchEvent|WheelEvent|WebGLContextEvent|WebKitAnimationEvent|WebKitTransitionEvent']
    , ['HTMLCollection', 'HTMLCollection|HTMLOptionsCollection']
    , ['HTMLMediaElement', 'HTMLMediaElement|HTMLAudioElement|HTMLVideoElement']
    , ['IDBRequest', 'IDBRequest|IDBVersionChangeRequest']
    , ['Uint8Array', 'Uint8Array|Uint8ClampedArray']
  ];
  $dynamicSetMetadata(table);
})();
//  ********** Globals **************
function $static_init(){
}
var const$0000 = Object.create(_DeletedKeySentinel.prototype, {});
var const$0001 = Object.create(NoMoreElementsException.prototype, {});
$static_init();
main();
