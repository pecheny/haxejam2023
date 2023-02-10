package utils;

import openfl.events.KeyboardEvent;
class KeyBinder {
    var cooomandsMap:Map<Int, Void -> Void> = new Map();
    var uncooomandsMap:Map<Int, Void -> Void> = new Map();

    public function new() {
        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onUp);
    }

    public function addCommand(keyCode:Int, handler:Void -> Void, releaseHandler:Void->Void = null) {
        if (cooomandsMap.exists(keyCode))
            trace("WARN: override handler for keyCode " + keyCode + ".");
        cooomandsMap[keyCode] = handler;
        if (releaseHandler != null) uncooomandsMap[keyCode] = releaseHandler;
    }

    public function clenKey(keyCode) {
        cooomandsMap.remove(keyCode);
    }

    function onKey(e:KeyboardEvent) {
        if (cooomandsMap.exists(e.keyCode)) {
            cooomandsMap[e.keyCode]();
        }
    }

    function onUp(e:KeyboardEvent) {
        if (uncooomandsMap.exists(e.keyCode)) {
            uncooomandsMap[e.keyCode]();
        }
    }
}
