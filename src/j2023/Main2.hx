package j2023;

import openfl.Lib;
import openfl.geom.Point;
import macros.AVConstructor;
import openfl.display.Graphics;
import Axis2D;
import utils.AbstractEngine;
import openfl.display.Sprite;

using Axis2D;

class Main2 extends AbstractEngine {
	var balls:Array<Ball> = [];
	var rend:BallRenderer;
	var portal:Portal;

	public function new() {
		super();
		rend = new BallRenderer(this.graphics);
		var b = new Ball();
		b.pos[vertical] = 100;
		b.spd[horizontal] = 42;
		balls.push(b);
		portal = createPortal();
	}

	function createPortal() {
		var port = new Portal(createGate(), createGate());
		return port;
	}

	function createGate() {
		var gate = new Gate(100);
		addChild(gate);
		gate.x = rndPos(horizontal);
		gate.y = rndPos(vertical);
		trace(gate.x + " " + gate.y);
		trace(getGameBounds());
		gate.rotation = -180 + Math.random() *360;
		return gate;
	}

	function rndPos(a:Axis2D) {
		var b = getGameBounds();
		return b.pos[a] + Math.random() * b.size[a];
	}

	var bounds:Rect;

	function getGameBounds() {
		if (bounds != null)
			return bounds;
		var st = Lib.current.stage;
		var size:AVector2D<Float> = AVConstructor.create(Axis2D, st.stageWidth, stage.stageHeight);
		var pos = AVConstructor.create(Axis2D, 0., 0.);
		bounds = {
			pos: pos,
			size: size
		};
		return bounds;
	}

	override function update(t:Float) {
		super.update(t);
		rend.erase();
		var dt = 1 / 60;
		for (b in balls) {
			b.pos.setx(b.pos.x() + b.spd.x() * dt);
			b.pos.sety(b.pos.y() + b.spd.y() * dt);
            portal.handleBall(b);

			rend.render(b, b.pos);
		}
	}
    override function onDown(name:String) {
		var st = Lib.current.stage;
        balls[0].pos.setx(st.mouseX);
        balls[0].pos.sety(st.mouseY);
    }
}


class Portal {
	var entrance:Gate;
	var exit:Gate;
	var point:Point = new Point();

	public function new(en, ex) {
		this.entrance = en;
		this.exit = ex;
	}

	public function handleBall(b:Ball) {
		point.setTo(b.pos.x(), b.pos.y());
		var local = entrance.globalToLocal(point);
		if (local.y < 0 || local.x < - entrance.w/2 ||local.x > entrance.w/2)
			return;
		var newpos = exit.localToGlobal(local);

		point.setTo(b.spd.x() + entrance.x, b.spd.y() + entrance.y);
		var newspd = exit.localToGlobal(entrance.globalToLocal(point));
        newspd.x -= exit.x;
        newspd.y -= exit.y;
        trace(b.spd, point, newspd);

		b.pos.setx(newpos.x);
		b.pos.sety(newpos.y);
		b.spd.setx(newspd.x);
		b.spd.sety(newspd.y);
	}
}

class Gate extends Sprite {
	public var w:Float;
	var h = 10;

	public function new(w) {
		super();
		this.w = w;
		graphics.beginFill(0);
		graphics.drawRect(-w / 2, 0, w, h);
		graphics.endFill();
		graphics.beginFill(0xff0000);
		graphics.drawRect(-w / 2, 0, w, 2);
		graphics.endFill();
	}
}



class BallRenderer {
	var graphics:Graphics;

	public function new(gr) {
		this.graphics = gr;
	}

	public function render(b:Ball, pos:ReadOnlyAVector2D<Float>) {
		graphics.beginFill(b.color);
		graphics.drawCircle(pos[Axis2D.horizontal], pos[Axis2D.vertical], b.r);
		graphics.endFill();
	}

	public function erase() {
		graphics.clear();
	}
}
