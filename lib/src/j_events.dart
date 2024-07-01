/// TODO: Expand w/ analyzer or codegen for intellisense
const event = Event();

/// TODO: Expand w/ analyzer or codegen for intellisense
class Event {
  const Event();
}

typedef VoidDelegate = void Function();

class JEventArgs {
  static const empty = JEventArgs();
  const JEventArgs();
}

class JPureEvent {
  JPureEvent([List<VoidDelegate>? subscribers])
      : _subscribers = subscribers ?? List<VoidDelegate>.empty(growable: true);
  const JPureEvent.makeConst(List<VoidDelegate> subscribers)
      : _subscribers = subscribers;
  final List<VoidDelegate> _subscribers;
  JPureEvent operator +(VoidDelegate subscription) =>
      this.._subscribers.add(subscription);
  JPureEvent subscribe(VoidDelegate subscription) =>
      this.._subscribers.add(subscription);

  JPureEvent operator -(VoidDelegate subscription) =>
      this.._subscribers.remove(subscription);

  JPureEvent unsubscribe(VoidDelegate subscription) =>
      this.._subscribers.remove(subscription);

  bool invoke() {
    for (var element in _subscribers) {
      element();
    }
    return _subscribers.isEmpty ? false : true;
  }
}

class JEvent<EventArgs extends JEventArgs> {
  JEvent([List<Function(EventArgs)>? subscribers])
      : _subscribers =
            subscribers ?? List<Function(EventArgs)>.empty(growable: true);
  const JEvent.makeConst(List<Function(EventArgs)> subscribers)
      : _subscribers = subscribers;
  final List<Function(EventArgs)> _subscribers;
  JEvent operator +(Function(EventArgs) subscription) =>
      this.._subscribers.add(subscription);
  JEvent subscribe(Function(EventArgs) subscription) =>
      this.._subscribers.add(subscription);

  JEvent operator -(Function(EventArgs) subscription) =>
      this.._subscribers.remove(subscription);

  JEvent unsubscribe(Function(EventArgs) subscription) =>
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
  JOwnedEvent([List<OwnedEventDelegate>? subscribers])
      : _subscribers =
            subscribers ?? List<OwnedEventDelegate>.empty(growable: true);
  const JOwnedEvent.makeConst(List<OwnedEventDelegate> subscribers)
      : _subscribers = subscribers;
  final List<OwnedEventDelegate> _subscribers;
  JOwnedEvent<Owner, EventArgs> operator +(OwnedEventDelegate subscription) =>
      this.._subscribers.add(subscription);
  JOwnedEvent<Owner, EventArgs> subscribe(OwnedEventDelegate subscription) =>
      this.._subscribers.add(subscription);
  JOwnedEvent<Owner, EventArgs> operator -(OwnedEventDelegate subscription) =>
      this.._subscribers.remove(subscription);
  JOwnedEvent<Owner, EventArgs> unsubscribe(OwnedEventDelegate subscription) =>
      this.._subscribers.remove(subscription);

  bool invoke(Owner owner, EventArgs args) {
    for (var element in _subscribers) {
      element(owner, args);
    }
    return _subscribers.isEmpty ? false : true;
  }
}
