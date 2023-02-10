package input;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.TouchEvent;
import openfl.events.MouseEvent;
import openfl.events.EventDispatcher;
import fsm.State;
import fsm.FSM;
import input.Input.GameButtons;
@:keep
class TouchInput implements Input extends FSM<TouchStates, TouchInput> {
    var source:EventDispatcher;
    public var targetName(default, null) = "";

    public function new(s) {
        source = s;
        super();
        addState(Pressed, new PressedState());
        addState(Free, new FreeState());
        changeState(Free);

        source.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
        source.addEventListener(MouseEvent.MOUSE_UP, onUp);
        source.addEventListener(MouseEvent.MOUSE_OUT, onOut);
        source.addEventListener(MouseEvent.MOUSE_OVER, onOver);
        source.addEventListener(TouchEvent.TOUCH_BEGIN, onDown);
        source.addEventListener(TouchEvent.TOUCH_END, onUp);

        openfl.Lib.current.stage.addEventListener(Event.MOUSE_LEAVE, onUp);
    }

    function onDown(e:Event) {
        var trg:DisplayObject = e.target;
//        trace(trg.name);
        targetName = trg.name;
        changeState(Pressed);
    }

    function onUp(e:Event) {
        changeState(Free);
    }

    function onOver(e:MouseEvent) {
        var trg:DisplayObject = e.target;
        targetName = trg.name;
    }

    function onOut(e:MouseEvent) {
        var trg:DisplayObject = e.target;
        targetName = "";
    }

    public function getDirProjection(axis:Axis2D):Float {
        return untyped getCurrentState().getDirProjection(axis);
    }

    public function pressed(button:GameButtons):Bool {
        return untyped getCurrentState().pressed(button);
    }

}

@:enum abstract TouchStates (String) to String {
    var Pressed = "Pressed";
    var Free = "Free";
}
@:keep
class TouchState extends State<TouchStates, TouchInput> {
    public function new() {}

    public function getDirProjection(axis:Axis2D):Float {
        return 0;
    }

    public function pressed(button:GameButtons):Bool {
        return false;
    }
}
@:keep
class PressedState extends TouchState {

    override public function getDirProjection(axis:Axis2D):Float {
        return switch fsm.targetName {
            case ControlAliases._right : 1;
            case ControlAliases._left : -1;
            case _:0;
        }
    }

    override public function pressed(button:GameButtons):Bool {
        return fsm.targetName == ControlAliases._top;
    }
}
class FreeState extends TouchState {
}
@:enum abstract ControlAliases(String) to String {
    var _left = "_left";
    var _right = "_right";
    var _top = "_top";
}
