package utils;
import openfl.events.MouseEvent;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
import utils.Updatable;
class AbstractEngine extends Sprite implements Updater {
    var last:Float = 0;
    var timeMultiplier:Float = 1;
    var updatables:Array<Updatable> = [];

    inline static var maxElapsed = 0.016666666;

    public function new() {
        super();
        addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
    }
    function mouseDownHandler(e:MouseEvent) {
        var trg:DisplayObject = e.target; 
        onDown(trg.name);
    }

    public function onDown(name:String) {
    
    }

    private function enterFrameHandler(e:Event):Void {
        var time = Lib.getTimer();
        var elapsed = (time - last) / 1000;
        if (elapsed > maxElapsed) elapsed = maxElapsed;
        last = time;
        // update(elapsed );
        update(elapsed * timeMultiplier);
    }

    public function update(t:Float):Void {
        for (u in updatables)
            u.update(t);
    }

    public function addUpdatable(e:Updatable):Void {
        updatables.push(e);
    }

    public function removeUpdatable(e:Updatable):Void {
        updatables.remove(e);
    }


}