typedef VoidDelegate = void Function();

class JEventArgs {
  static const empty = JEventArgs();
  const JEventArgs();
}

class JPureEvent {
  final List<VoidDelegate> _subscribers =
      List<VoidDelegate>.empty(growable: true);
  JPureEvent operator +(VoidDelegate subscription) =>
      this.._subscribers.add(subscription);

  JPureEvent operator -(VoidDelegate subscription) =>
      this.._subscribers.remove(subscription);

  bool invoke() {
    for (var element in _subscribers) {
      element();
    }
    return _subscribers.isEmpty ? false : true;
  }
}

class JEvent<EventArgs extends JEventArgs> {
  final List<Function(EventArgs)> _subscribers =
      List<Function(EventArgs)>.empty(growable: true);
  JEvent operator +(Function(EventArgs) subscription) =>
      this.._subscribers.add(subscription);

  JEvent operator -(Function(EventArgs) subscription) =>
      this.._subscribers.remove(subscription);

  bool invoke(EventArgs args) {
    for (var element in _subscribers) {
      element(args);
    }
    return _subscribers.isEmpty ? false : true;
  }
}

typedef OwnedEventDelegate<Owner, EventArgs extends JEventArgs> = void Function(
    Owner, EventArgs);

/// TODO: Store owner?
class JOwnedEvent<Owner, EventArgs extends JEventArgs> {
  // final Owner owner;
  // JOwnedEvent(this.owner);
  // final Owner? owner;
  // JOwnedEvent({this.owner});
  final List<OwnedEventDelegate> _subscribers =
      List<OwnedEventDelegate>.empty(growable: true);
  JOwnedEvent<Owner, EventArgs> operator +(OwnedEventDelegate subscription) =>
      this.._subscribers.add(subscription);
  JOwnedEvent<Owner, EventArgs> operator -(OwnedEventDelegate subscription) =>
      this.._subscribers.remove(subscription);

  bool invoke(Owner owner, EventArgs args) {
    for (var element in _subscribers) {
      element(owner, args);
    }
    return _subscribers.isEmpty ? false : true;
  }
}
