package j2023;

import openfl.Lib;
import hxmath.math.Vector2;
import hxmath.math.Matrix3x2;
import AVector;
import macros.AVConstructor;
import openfl.display.Graphics;
import Axis2D;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import utils.AbstractEngine;

using hxmath.math.Matrix3x2;

class Main extends AbstractEngine {
	public function new() {
		super();
		stage.window.frameRate = 60;
		stage.scaleMode = StageScaleMode.SHOW_ALL;
		stage.align = StageAlign.TOP_LEFT;
		graphics.beginFill(0xffffff);
		graphics.drawCircle(100, 100, 100);
		var mat = new Matrix();
		// var m = new GodModel();
		// fsm = new GameFsm(m);
		// m.fsm = fsm;
		// fsm.changeState(GameStates.WELCOME);
        localToGlobal
	}

	override public function update(t:Float):Void {
		super.update(t);
		// fsm.update(t);
	}
}





class TeleportRender {
	var bounds:AVector2D<Float> = AVConstructor.create(0, 0);
}

class Game {
    var t:Teleport;
    var b:Ball;
    var rend = new BallRenderer(Lib.current.graphics);

    // var trg = AVConstructor.create(Axis2D, 0., 0.);
    public function new() {
        t = new Teleport();
        t.m.setTranslate(-100, 0);
        t.trigger = (b:Ball) -> {
            b.pos[horizontal] > 100;
        };
        b
    }
    public function update(dt) {
        var trg = b.pos;
        trg[horizontal] = b.pos[horizontal] + b.pos[horizontal] * dt;
        trg[vertical] = b.pos[vertical] + b.pos[vertical] * dt;

        if(t.trigger(b)) {
            t.translate(trg, b.pos);
            t.translate(b.vel, b.vel);
        } else {
            b.pos[horizontal] = trg[horizontal];
            b.pos[vertical] = trg[vertical];
        }
        rend.render(b, b.pos);
    }
}

class Teleport {
	public var trigger:Ball->Void;
	var active:Ball->Void;
	public var m = Matrix3x2.identity;
	var v = new Vector2();

	// public function translate(pos:ReadOnlyAVector2D<Float>, trg:AVector2D>) {
	public function translate(pos:ReadOnlyAVector2D<Float>, trg:AVector2D<Float>) {
		v.x = pos[horizontal];
		v.y = pos[vertical];
		transform[trg];
        
	}

	inline function transform(trg:AVector2D<Float>) {
		trg[horizontal] = m.a * v.x + m.c * v.y + m.t.x;
		trg[vertical] = m.b * v.x + m.d * v.y + m.t.y;
	}
}
