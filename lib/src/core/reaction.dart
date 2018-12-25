import 'package:mobx/src/core/global_state.dart';
import 'package:mobx/src/core/observable.dart';

abstract class Derivation {
  String name;
  Set<Atom> observables;
  Set<Atom> newObservables;

  void onBecomeStale() {}
}

class Reaction implements Derivation {
  void Function() _onInvalidate;
  bool _isScheduled = false;
  bool _isDisposed = false;
  bool _isRunning = false;

  @override
  String name;

  @override
  Set<Atom> newObservables;

  @override
  Set<Atom> observables = Set();

  Reaction(onInvalidate, {String name}) {
    this.name = name ?? "Reaction@${global.nextId}";
    _onInvalidate = onInvalidate;
  }

  @override
  void onBecomeStale() {
    schedule();
  }

  track(void Function() fn) {
    global.startBatch();

    _isRunning = true;
    global.trackDerivation(this, fn);
    _isRunning = false;

    if (_isDisposed) {
      global.clearObservables(this);
    }

    global.endBatch();
  }

  run() {
    if (_isDisposed) {
      return;
    }

    global.startBatch();

    _isScheduled = false;

    if (global.shouldCompute(this)) {
      _onInvalidate();
    }

    global.endBatch();
  }

  dispose() {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;

    if (_isRunning) {
      return;
    }

    global.startBatch();
    global.clearObservables(this);
    global.endBatch();
  }

  schedule() {
    if (_isScheduled) {
      return;
    }

    _isScheduled = true;
    global.addPendingReaction(this);
    global.runReactions();
  }
}
