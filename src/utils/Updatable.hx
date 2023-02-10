package utils;
interface Updatable {
    function update(dt:Float):Void;
}
interface Updater {
    public function addUpdatable(e:Updatable):Void;
    public function removeUpdatable(e:Updatable):Void;
}
