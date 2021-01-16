# `procedure` API

* **Description**
    * This is basically a wrapper for os.pullEvent with parallel advantages.

* **Basics**
    * First define a procedure with `procedure.new()`.
    * Create some event functions, register them to callback names with `proc.registerCallback`.
        * For a simple procedure you could assign a function `__internalUpdate` to get on the internal 1 second repeater.
    * Register expected events (ex. an initializer for a process) to the procedure with `proc.registerEvent`.
        * When registering an event you tell it what callback to call, whether to delete after being caught, a time to call it, etc.
    * start the procedure with `proc.start`.
        * alternatively, `procedure.start` can be used to start multiple at once.
        * if a procedure is expected to stop itself do so with `proc.stop`.

--------

* **Notes**
    * The main thing to keep in mind so far: Multiple events within a procedure will run simultaneously no issue. However, if you start a new procedure from within an event, this will halt the current procedure. Basically new procedures run on the same thread as the current one. Figuring out a way to run procedures AND keep the procedure they were ran from active would be extremely useful in some cases. Such as if you wanted a main procedure to always be listening for modem_events (to receive instructions from another computer maybe) while also being able to run procedures within it and still listen. You could still achive this, just without the listener running while running child procedures, unless of course you register the listener events to each procedure layer.

--------

## All of the following are apart of the **`procedure` API**.

--------

# Procedures

### procedure.new`()`

Creates a new `procedure`, returns it's instance.

>* **Parameters**
>   * *N/A*
>* **Returns**
>   * `procedure`: Returns instance of the newly created procedure.

### procedure.start`(...)`

Runs all given procedures in at the same time using `parallel.waitForAll`. 

>* **Parameters**
>   * `...`: List of procedures to run `start` on.
>* **Returns**
>   * *N/A*

### procedure.destroy`(...)`

Destroys all given procedures. If they are running, they will get a short chance to stop. This can be run from outside of a procedure.

>* **Parameters**
>   * `...`: List of procedures to destroy.
>* **Returns**
>   * *N/A*

--------

# Callbacks

### procInstance:registerCallback`(name, func)`

Registers a function to a callback name. This is required for a function to be called for the callback. Without doing this events will still work but not have anything to call.

>* **Parameters**
>   * `name`: Callback name.
>   * `func`: Function to be registered for this callback.
>* **Returns**
>   * `id`: Index of registered function under this callback.

>* **Notes**
>   * Multiple functions can be registered to a single callback name, if so they will be called in the order they were registered.

--------

### procInstance:unregisterCallback`(name, id)`

Un-registers a function from a callback name using ID from when it was registered.

>* **Parameters**
>   * `name`: Callback name.
>   * `id`: ID returned by `registerCallback`.
>* **Returns**
>   * `nil`: Function is not registered under this callback.
>   * `true`: Removed successfully.

--------

# Events

### procInstance:registerEvent`(event, senderPort, onetime, callback, ...)`

Registers an event to be watched for. This is required for an event to be picked up by the event watcher.

>* **Parameters**
>   * `event`: Event name or timer ID (from `os.startTimer`).
>   * `senderPort`: Same as `Frequency` in `os.pullEvent`.
>   * `onetime`: Boolean value indicating whether this event should unregister itself after being called.
>   * `callback`: Callback name to call when executing.
>   * `...`: Parameters to include when calling callback.
>* **Returns**
>   * `id`: Index of registered event.

>* **Notes**
>   * While this works for a name or timer ID, timed events should use `registerTimedEvent` if possible.

--------

### procInstance:registerQueuedEvent`(event, senderPort, onetime, callback, ...)`

(Alternative for `registerEvent`) Registers an event to be watched for. Then queues it to be called ASAP.

>* **Parameters**
>   * `event`: Event name.
>   * `senderPort`: Same as `Frequency` in `os.pullEvent`.
>   * `onetime`: Boolean value indicating whether this event should unregister itself after being called.
>   * `callback`: Callback name to call when executing.
>   * `...`: Parameters to include when calling callback.
>* **Returns**
>   * `id`: Index of registered event.

>* **Notes**
>   * This should not be used for a timer ID, it would result in creating a timer that calls nothing.

--------

### procInstance:registerScheduledEvent`(event, senderPort, seconds, onetime, callback, ...)`

(Alternative for `registerEvent`) Registers an event to be called after a specific timeframe.

This is different from `registerTimedEvent`. A "scheduled" event is based on `os.clock()`, gets called when a time is passed. This makes this one more useful for situations like reinstating the process after a reboot.

>* **Parameters**
>   * `event`: Event name.
>   * `senderPort`: Same as `Frequency` in `os.pullEvent`.
>   * `seconds`: Seconds from now the event should be scheduled for (gets added to `os.clock()` value).
>   * `onetime`: Boolean value indicating whether this event should unregister itself after being called.
>   * `callback`: Callback name to call when executing.
>   * `...`: Parameters to include when calling callback.
>* **Returns**
>   * `id`: Index of registered event.

>* **Notes**
>   * This should not be used for a timer ID, it would result in creating a timer that calls nothing.

--------

### procInstance:registerTimedEvent`(seconds, senderPort, onetime, callback, ...)`

(Alternative for `registerEvent`) Registers an event to be called after a specific timeframe.

This is different from `registerScheduledEvent`. A "timed" event is called using `os.startTimer`.

>* **Parameters**
>   * `seconds`: Seconds from now the event should called.
>   * `senderPort`: Same as `Frequency` in `os.pullEvent`.
>   * `onetime`: Boolean value indicating whether this event should unregister itself after being called.
>   * `callback`: Callback name to call when executing.
>   * `...`: Parameters to include when calling callback.
>* **Returns**
>   * `id`: Index of registered event.

--------

### procInstance:unregisterEvent`(eventid)`

Unregisters an event from the event watcher.

>* **Parameters**
>   * `eventid`: Index returned by `registerEvent*` functions.
>* **Returns**
>   * `nil`: `eventid` was not registered.
>   * `true`: Removed successfully.

>* **Notes**
>   * If `eventid` was a `registerTimedEvent` event, the actual timer will still run but not call anything.

--------

### procInstance:queueEvent`(event, senderPort)`

Adds event to queue so that it gets called ASAP.

>* **Parameters**
>   * `event`: Event name or timer ID (from `os.startTimer`).
>   * `senderPort`: Same as `Frequency` in `os.pullEvent`.
>* **Returns**
>   * `nil`: Event isn't registered.
>   * `true`: Queued successfully.

>* **Notes**
>   * If `event` was a `registerTimedEvent` event, the actual timer will still run but not call anything. What it would've called is called now.

--------

### procInstance:queueEventID`(eventid)`

(Alternative for `queueEvent`) Adds event to queue so that it gets called ASAP.

>* **Parameters**
>   * `eventid`: Index returned by `registerEvent*` functions.
>* **Returns**
>   * `nil`: Event isn't registered.
>   * `true`: Queued successfully.

>* **Notes**
>   * If `event` was a `registerTimedEvent` event, the actual timer will still run but not call anything. What it would've called is called now.

--------

### procInstance:getEventData`(eventid, dataName)`

Return internal data of an event.

>* **Parameters**
>   * `eventid`: Index returned by `registerEvent*` functions.
>   * `dataName`: Data to be retrieved from registered event.
>* **Returns**
>   * `nil`: Event isn't registered.
>   * `data`: Data that was found (which could also be `nil`).

>* **Notes**
>   * Possible `dataName`'s are the following:
>       * `expected_event`
>       * `expected_sender`
>       * `callback_name`
>       * `callback_params`
>       * `remove_after`
>       * `timed_seconds`
>       * `scheduled_time`

--------

### procInstance:setEventData`(eventid, dataName, value)`

Change internal data of an event.

>* **Parameters**
>   * `eventid`: Index returned by `registerEvent*` functions.
>   * `dataName`: Data to be retrieved from registered event.
>   * `value`: New value of event data.
>* **Returns**
>   * `nil`: Event isn't registered.
>   * `true`: Changed data successfully.

>* **Notes**
>   * Possible `dataName`'s are the following:
>       * `expected_event`
>       * `expected_sender`
>       * `callback_name`
>       * `callback_params`
>       * `remove_after`
>       * `timed_seconds`
>       * `scheduled_time`

--------

### procInstance:start`()`

The main function to call after everything is set up for the routine. This actually begins the routine, which controls the event watcher. Thus without this the script isn't actually watching for registered events.

>* **Parameters**
>   * *N/A*
>* **Returns**
>   * *N/A*

>* **Notes**
>   * You CAN start a procedure from within a procedure, but the current procedure will be halted until the new one is completed. You could also initiate the same procedure from within itself.

--------

### procInstance:stop`()`

Ends procedure. Just stops event watching basically. Doesn't reset events/callbacks.

>* **Parameters**
>   * *N/A*
>* **Returns**
>   * *N/A*

--------

### procInstance:reset`()`

Ends procedure, stops event watching, and resets all registered events and callbacks.

>* **Parameters**
>   * *N/A*
>* **Returns**
>   * *N/A*

--------

# Internal Functions

### procInstance:__event_call`(eventid, eventdata)`

Internal function that does the actual calling when a registered event is found by event watcher.

>* **Parameters**
>   * `eventid`: Registered event ID.
>   * `eventdata`: Event data returned by `os.pullEvent()`.
>* **Returns**
>   * *N/A*

--------

# Internal Callbacks

### procInstance:__internalUpdate`(eventdata)`

Internal callback that's queued every second. Can be hooked if a procedure relies on ticks.

>* **Parameters**
>   * `eventdata`: Event data returned by `os.pullEvent()`.
>* **Returns**
>   * *N/A*

--------

### procInstance:__stopProc`(eventdata)`

Internal callback used to end the event checker (and thus end the procedure).

>* **Parameters**
>   * `eventdata`: Event data returned by `os.pullEvent()`.
>* **Returns**
>   * *N/A*

--------
