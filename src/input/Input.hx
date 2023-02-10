package input;
interface Input {
    function getDirProjection(axis:Axis2D):Float;
    function pressed(button:GameButtons):Bool;
}

@:enum abstract GameButtons(Int) {
    var jump = 0;
}

typedef ButtonMap<T> = Map<GameButtons, T>;
