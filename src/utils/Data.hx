package utils;
import haxe.ds.Vector;

typedef Vec2D = Vector2D<Float>;
typedef Vec2DRO = Vector2DRO<Float>;
typedef MeterPerSecond = Float;
typedef MeterPerSSq = Float;
typedef Speed = Vector2D<MeterPerSecond>;
typedef Accel = Vector2D<MeterPerSSq>;
class Vec2DWatcher<TUnit:Float> {
    public var x(get, set):TUnit;
    public var y(get, set):TUnit;
    var val:Vector2D<TUnit>;
    public function new (x, y) {
        val = new Vector2D<TUnit>(x,y);
    }

    function set_x(value:TUnit):TUnit {
        return val.x = value;
    }

    function set_y(value:TUnit):TUnit {
        return val.y = value;
    }

    function get_x():TUnit {
        return val.x;
    }

    function get_y():TUnit {
        return val.y;
    }

    public inline function copyFrom(f:Vector2DRO<TUnit>, force = false) {
        if (val.distance(f) > 20 && !force)
//            throw "wrong";
        trace( "wrong");

        return val.copyFrom(f);
    }

    public inline function distance(other:Vector2DRO<TUnit>) {
        val.distance(other);
    }
    
    @:to public function to_Vector2DRO():Vector2DRO<TUnit> {
        return cast val;
    }
    @:arrayAccess public inline function set(a:Axis2D, v) {
        return val.set(a, v);
    }


    @:arrayAccess public inline function get(a:Axis2D) {
        return val.get(a);
    }
}

@:forward(get)
abstract Vector2D<TUnit:Float>(Vector<TUnit>) {
    public var x(get, set):TUnit;
    public var y(get, set):TUnit;

    public inline function new(x = 0., y = 0.) {
        this = new Vector(2);
        init(cast x, cast y);
    }

    public inline function init(x, y) {
        this.set(0, x);
        this.set(1, y);
        return toThis();
    }


    public inline function get_x():TUnit {
        return this[0];
    }

    public inline function get_y():TUnit {
        return this[1];
    }

    public inline function set_x(value:TUnit):TUnit {
        return this.set(0, value);
    }

    public inline function set_y(value:TUnit):TUnit {
        return this.set(1, value);
    }

    @:arrayAccess public inline function set(a:Axis2D, val) {
        return this.set(a, val);
    }


    @:arrayAccess public inline function get(a:Axis2D) {
        return this.get(a);
    }

    public inline function copyFrom(f:Vector2DRO<TUnit>) {
        this[0] = f.x;
        this[1] = f.y;
        return toThis();
    }

    inline function toThis():Vector2D<TUnit> {
        return cast this;
    }

    @:to public function to_Vector2DRO():Vector2DRO<TUnit> {
        return cast this;
    }

    public inline function toString() {
        return '[$x, $y]';
    }

    public inline function add(other:Vector2DRO<TUnit>):Vector2D<TUnit> {
        x += other.x;
        y += other.y;
        return cast this;
    }

    public inline function remove(other:Vector2DRO<TUnit>):Vector2D<TUnit> {
        x -= other.x;
        y -= other.y;
        return cast this;
    }

    public inline function dot(other:Vec2DRO) {
        return x * other.x + y * other.y;
    }

    public inline function mul(m:TUnit):Vector2D<TUnit> {
        x *= m;
        y *= m;
        return toThis();
    }

    public inline function normalize(length:Float = 1):Vector2D<TUnit> {
        if (x != 0. || y != 0.) {
            var norm:TUnit = cast length / Math.sqrt(x * x + y * y);
            x *= norm;
            y *= norm;
        }
        return cast this;
    }

    public inline function flip() {
        x *= -1;
        y *= -1;
        return this;
    }

    public inline function reflect(normal:Vec2DRO) {
        var diff:Vector2D<TUnit> = cast normal.clone().mul(dot(normal) * 2);
        remove(diff);
        return toThis();
    }

    public inline function distance(other:Vector2DRO<TUnit>) {
        var dx = other.x - x;
        var dy = other.y - y;
        return Math.sqrt(dx * dx + dy * dy);
    }
}


abstract Vector2DRO<TUnit:Float>(haxe.ds.Vector<TUnit>) {
    public static var ZERO = new Vector2DRO(0, 0);

    public inline function new(x, y) {
        this = new Vector(2);
        this.set(0, x);
        this.set(1, y);
    }

    public var x(get, never):TUnit;
    public var y(get, never):TUnit;

    public inline function get_x():TUnit {
        return this[0];
    }

    public inline function get_y():TUnit {
        return this[1];
    }

    public inline function get(a:Axis2D)
    return this.get(a);

    public inline function toString() {
        return '[$x, $y]';
    }

    public inline function distance(other:Vector2DRO<TUnit>) {
        var dx = other.x - x;
        var dy = other.y - y;
        return Math.sqrt(dx * dx + dy * dy);
    }

    public inline function dot(other:Vec2DRO) {
        return x * other.x + y * other.y;
    }

    public inline function length() {
        return Math.sqrt(x * x + y * y);
    }

    public inline function clone() {
        return new Vector2D<TUnit>(x, y);
    }
}
typedef PolyId = Int;
typedef Meters = Float;
//abstract Meters(Float) from Float to Float {
//    public inline function new(v) this = v;
//}
abstract Range(haxe.ds.Vector<Float>) {
    public inline function new(a:Float, b:Float) {
        this = new Vector(2);
        if (b > a) {
            this[0] = a;
            this[1] = b;
        } else {
            this[0] = b;
            this[1] = a;
        }
    }

    public inline function getValue(weight:Float) {
        return this[0] + (this[1] - this[0]) * weight;
    }

    public inline function inside(val:Float) {
        return val > this[0] && val < this[1];
    }
}

@:enum abstract Sign(Int) to Int {
    var positive = 1;
    var negative = -1;
}
