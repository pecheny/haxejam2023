package input;
import utils.Signal;
import utils.AbstractEnumTools;
import utils.Updatable;
import Axis2D.AxisCollection2D;
import input.Input;
class Recorder implements UpdatableWithTime {
    public var input:Input;
    var events:Array<InputEvent> = [];
    var time:Float = 0;

    var keys:Array<GameButtons>;
    var axis:AxisCollection2D<Float> = new AxisCollection2D(0.);
    var buttons = new Map<GameButtons, Bool>();

    public function new(inp) {
        this.input = inp;
        keys = AbstractEnumTools.getValues(GameButtons);
    }

    public function update(dt) {
        time += dt;
        for (gb in keys) {
            var last = buttons.exists(gb) && buttons.get(gb);
            var current = input.pressed(gb);
            if (last != current) {
                events.push(new InputEvent(time, ButtonEvent(gb, current)));
                buttons.set(gb, current);
            }
        }
        for (a in Axis2D.keys) {
            var last = axis[a];
            var current = input.getDirProjection(a);
            if (last != current) {
                events.push(new InputEvent(time, AxisEvent(a, current)));
                axis[a] = current;
            }
        }
    }

    public function reset() {
        events = [];
        time = 0;
    }

    public function getRecord() {
        return events;
    }

    public function getTime():Float {
        return time;
    }
}

class InputRecordPlayer implements Input implements UpdatableWithTime {
    var events:Array<InputEvent> = [];
    var time:Float = 0;

    var mapping:ButtonMap<Int> = new ButtonMap();
    var axis:AxisCollection2D<Float>;
    var buttons:Map<GameButtons, Bool>;
    var i = 0;
    public var disabled = false;
    public var onFinish = new Signal<Void -> Void>();

    public function new() {}

    public function init(events) {
        this.events = events;
        disabled = false;
        time = 0;
        i = 0;
        axis = new AxisCollection2D(0.);
        buttons = new Map<GameButtons, Bool>();
    }

    inline function consume(evt:EventType) {
        switch evt {
            case ButtonEvent(gb, val): buttons[gb] = val;
            case AxisEvent(a, v): axis[a] = v;
        }
    }

    public function update(dt) {
        time += dt;
        if (disabled)
            return;
        if (i >= events.length) {
            disabled = true;
            onFinish.dispatch();
            return;
        }
        var evt:InputEvent = events[i];
        while (evt.time <= time) {
            consume(evt.type);
            i++;
            if (i >= events.length)
                return;
            evt = events[i];
        }
    }

    public function getDirProjection(a:Axis2D):Float {
        return axis[a];
    }

    public function pressed(button:GameButtons):Bool {
        return buttons.exists(button) && buttons.get(button);
    }

    public function getTime():Float {
        return time;
    }

}

interface UpdatableWithTime extends Updatable {
    public function getTime():Float;
}

class InputEvent {
    public var time:Float;
    public var type:EventType;

    public function new(ti, ty) {
        this.time = ti;
        this.type = ty;
    }

    function toString() {
        return '[$time : $type]';
    }
}


//@:enum abstract EventType(Bool) {
//    var button = true;
//    var axis = false;
//}

enum EventType {
    ButtonEvent(b:GameButtons, isPressed:Bool);
    AxisEvent(axis:Axis2D, value:Float);
}