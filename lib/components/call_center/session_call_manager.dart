class SessionCallManager {
  String id = "";
  String _timerString = "0:00";
  String? _type;
  bool _readyForActive = false;
  bool _readyForAbort = false;
  Function? _acceptCallback;
  Function? _abortCallback;

  bool get readyForActive => this._acceptCallback != null;
  bool get readyForAbort => this._abortCallback != null;
  bool get isNotActive => _readyForActive == false;
  String get timer => _timerString;
  String get type => _type ?? "";

  set readyForActive(value) => _readyForActive = value;
  set readyForAbort(value) => _readyForAbort = value;
  set timer(value) => _timerString = value;

  static Map<String, SessionCallManager?> _cache = {};
  factory SessionCallManager.sessionWithId(String id) {
    if (_cache.containsKey(id)) {
      return _cache[id]!;
    } else {
      final SessionCallManager session = SessionCallManager._internal(id);
      _cache[id] = session;
      return session;
    }
  }
  SessionCallManager withType(String type) {
    this._type = type;
    return this;
  }
  SessionCallManager._internal(this.id);

  void active() {
    this._readyForActive = true;
    if (this._acceptCallback != null) {
      this._acceptCallback!.call(this.id);
      this._acceptCallback = null;
    }
  }

  void abort() {
    this._readyForAbort = true;
    if (this._abortCallback != null) {
      this._abortCallback!.call(this.id);
      this._abortCallback = null;
    }
  }

  void clean() {
    this._abortCallback = null;
    this._acceptCallback = null;
    this.id = "";
  }

  void onAbort(callback) {
    this._abortCallback = callback;
    if (this._readyForAbort) {
      callback.call(this.id);
      this._readyForAbort = false;
    }
  }

  void onAccept(callback) {
    this._acceptCallback = callback;
    if (this._readyForActive) {
      callback.call(this.id);
      this._readyForActive = false;
    }
  }
}