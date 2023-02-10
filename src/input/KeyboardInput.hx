package input;
import macros.AVConstructor;
import Axis2D.AxisCollection2D;
import utils.KeyPoll;
import input.Input;
class KeyboardAxisInput {
    var fkey:Int;
    var bkey:Int;
    var keys:KeyPoll;

    public function new(forwardKey, backwardKey, keys) {
        fkey = forwardKey;
        bkey = backwardKey;
        this.keys = keys;
    }

    public function get() {
        var v = 0.;
        if (keys.isDown(fkey)) v += 1;
        if (keys.isDown(bkey)) v -= 1;
        return v;
    }
}

class KeyboardInput implements Input {
    var controllers:AxisCollection2D<KeyboardAxisInput>;
    var keys:KeyPoll;
    var mapping:ButtonMap<Int>;
    public function new(mapping:{
            forward:Int, backward:Int, up:Int, down:Int
    }, keys, bmapping) {
        this.keys = keys;
        this.mapping = bmapping;
        controllers = AVConstructor.empty();
        controllers[Axis2D.horizontal] = new KeyboardAxisInput(mapping.forward, mapping.backward, keys);
        controllers[Axis2D.vertical] = new KeyboardAxisInput(mapping.down, mapping.up, keys);
    }

    public function getDirProjection(axis:Axis2D) {
        return controllers[axis].get();
    }

    public function pressed(button:GameButtons):Bool {
        return keys.isDown(mapping[button]);
    }
}
