## Flow

The whole point of this API is to not have to use `os.pullEvent` and make working with routines much easier. To better understand, first you'll need to know how things flow between the three main modules (`Procedures`,  `Events`, and `Callbacks`).

`Procedures` > `Events` > `Callbacks` > `Functions`

`Procedures` will be organized, planned work flows made up of `Events` and listeners.

`Events` will contains event data to listen for and a `Callback` to call when detected.

`Callbacks` will contain a single or multiple `Functions` to call when called on.

----------------

# Modules

Below is a breakdown of each module: what it's purpose is, methods it provides, and data that can be accessed from it. These are the basics of the whole API.

## Callback

A callback is what is executed once an event is received. It will have a name to be called by. It can have multiple functions assigned to it, each will be called when the callback is. All will be called with the same parameters.

Public:
- `callback.register(name, functions)` - Registers function(s) to a callback name. If this name exists it will be added to, if not it will be created. Returns the callback of this name. Can be used to simply create/obtain the callback of a name if used with no functions passed.
- `callback.unregister(name, functions)` - Unregisters function(s) from a callback name. If this name is empty it is destroyed.
- `callback.get(name)` - Returns callback table for given name, if it exists.

Methods:
- `cback:addFunction(functions)` - Add function(s) to this callback.
- `cback:removeFunction(functions)` - Remove function(s) from this callback.
- `cback:getFunctionID(function)` - Get ID of function returned by `cback:addFunction`.
- `cback:call(params)` - Call all functions with given parameters.
- `cback:copy(params)` - Returns deep copy of this callback.

Data:
- `cback.name` of the callback.
- `cback.functions` to call when called upon.

## Event

An event will contain information to listen for. And also details on what to do when the listener detects this information.

Public:
- `event.new(name, channel, timer, callback, params)` - Create a new event.
- `event.destroy(event/eventID)` - Destroy an event.
- `event.get(eventID)` - Get an event's table by event ID.

Methods:
- `eve:setChannel(channelID)` - Change channel of this event.
- `eve:setCallback(callback, ...)` - Change callback and params to use for this event.
- `eve:queue()` - Queue this event using `os.queueEvent(eve.name, eve.id, eve.channel, unpack(eve.params))`.

Data:
- `eve.id` of the event.
- `eve.name` of the event.
- `eve.channelID` to send event to when queuing.
- `eve.timerID` returned by `os.startTimer`. This will be ignored unless `Name` is "timer". This should probably only be used by procedure's methods.
- `eve.callback` to call when detected.
- `eve.params` to call callback with when detected, by default (can be overrided if queued from a procedure method).

## Procedure

Handler for an event queue and listener. The listener will filter events based on filters registered to it. If there are no filters added, listener will check all events created. Hint: It would be most efficient to add filters to catch only the events this procedure is expected to listen for.

Filters will all add to the same of three lists: `Name Filters`, `Channel Filters`, or `Timer Filters`. If any of these lists are empty the listener will not filter by that type. That is;
procedure.addFilter(`Name`, `Channel`, `Timer`)
- `Name` - Add name to `Name Filters`.
- `Channel` - Add a channel ID to `Channel Filters`. `-1` for local events (shortcut for this procedure's channel). 
- `Timer` - Add a timer ID to `Timer Filters`.

The procedure must be started to be listening, `proc:start`. Two internal callbacks and events will be created when doing so:
- A constant `Update Timer Event` that calls the `Internal Update Callback` every second. Automatically starts.
- An endpoint, the "stop procedure" button. Called while the procedure is running using `procedure:stop`, this queues the `Internal Stop Event` which of course calls the `Internal Stop Callback`.

Will provide a way to queue events immediately, schedule events, and set timed events. Handles setting timers and adding the filter for it, as well as checking for scheduled events in `Internal Update Callback` (using `os.clock` times). Scheduled events and timers will both be able to be one time or repeating and can be stopped. Scheduled and timed events will simply call `event:queue` at the specified time.

When queuing any event using the procedure method you can pass `Callback Params` to override the event's `Callback Params`. Also this method will automatically add it to the procedure's listeners.

Once the procedure is started, no code beyond `proc:start` will run until the procedure is compeleted. You could however, run multiple procedures at once using `procedure.start`.

Public:
- `procedure.new(channel, filters)` - Create a new procedure.
- `procedure.destroy(proc/procID)` - Destroy a procedure.
- `procedure.start(...)` - Start multiple procedures at once (params can all be single or a table).
- `procedure.stop(...)` - Stop multiple procedures at once (params can all be single or a table).

Methods:
- `proc:start()` - Start this procedure.
- `proc:stop()` - Stop this procedure.
- `proc:setChannel()` - Change channel of this procedure.
- `proc:addFilter(names, channels, timers)` - Add filters to this procedure (params can all be single or a table). 
- `proc:removeFilter(names, channels, timers)` - Remove filters from this procedure (params can all be single or a table).
- `proc:queueEvent(event, ...)` - Queue an event immediately. Add to listener.
- `proc:queueTimedEvent(event, seconds, repeating, ...)` - Queue an event after `os.startTimer` timer runs. Add to listener.
- `proc:queueScheduleEvent(event, time, repeating, ...)` - Queue an event at a specified `os.clock` time. Add to listener.

Data:
- `proc.id` of this procedure.
- `proc.channel` the procedure will run local events on.
- `proc.filters` to use in the listener.


