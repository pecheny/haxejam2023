package input;
import utils.Updatable;
import input.Input.GameButtons;
class JustPressed implements Updatable {
    public var input:Input;
    var last:Bool = false;
    var button:GameButtons;

    public function new(input, button) {
        this.input = input;
        this.button = button;
    }

    public function update(dt:Float):Void {
        last = input.pressed(button);
    }

    public function isJustPressed() {
        return input.pressed(button) && !last;
    }

}
