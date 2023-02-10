package input;
import utils.Mathu;
import input.Input;
class MetaInput implements Input {
    var inputs:Array<Input> = [];

    public function new() {
    }

    public function add(i) {
        inputs.push(i);
        return this;
    }

    public function getDirProjection(axis:Axis2D):Float {
        var val = 0.;
        for (i in inputs) {
            val += i.getDirProjection(axis);
        }
        return Mathu.clamp(val, -1, 1);
    }

    public function pressed(button:GameButtons):Bool {
        for (i in inputs) {
            if (i.pressed(button)) return true;
        }
        return false;
    }


}
