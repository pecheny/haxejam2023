package j2023;

import utils.KeyPoll;
import input.Input;
import openfl.display.Sprite;
import openfl.ui.Keyboard;
import input.KeyboardInput;
import hxmath.math.MathUtil;
import openfl.display.Graphics;
import macros.AVConstructor;
import utils.Updatable;
import utils.AbstractEngine;
import Axis2D;

class Main3 extends AbstractEngine {
	var model = new Model();
	var systems:Array<System> = [];

	public function new() {
		super();
		model.bounds.size = AVConstructor.create(stage.stageWidth, stage.stageHeight);
		model.balls.push(new Ball(graphics));
		model.gravity[vertical] = 100;
		model.platform = new Platform(100);
		model.platform.y = model.bounds.size[vertical] * 0.66;
		model.platform.x = model.bounds.size[horizontal] * 0.5;
		addChild(model.platform);
		systems.push(new Ballistics(model));
		systems.push(new GameBounds(model));
		systems.push(new BallRenderer(model));
		systems.push(new PlatformMotor(model));
		systems.push(new PlatformDetector(model));
	}

	override function update(t:Float) {
		super.update(t);
		for (s in systems)
			s.update(1 / 60);
	}
}

interface PointParticle {
	public var pos(default, null):AVector2D<Float>;
	public var spd(default, null):AVector2D<Float>;
}

interface IBall extends PointParticle {
	public var r(default, null):Float;
}

class Ball implements IBall {
	public var pos(default, null):AVector2D<Float> = AVConstructor.create(100, 100);
	public var spd(default, null):AVector2D<Float> = AVConstructor.create(0, 0);
	public var r:Float = 20;
	public var graphics:Graphics;
	public var color:Int = 0x903020;

	public function new(gr) {
		this.graphics = gr;
	}
}

class Model {
	public var bounds:Rect = {
		pos: AVConstructor.create(0, 0),
		size: AVConstructor.create(0, 0),
	};
	public var balls(default, null):Array<Ball> = [];
	public var platform:Platform;
	public var gravity:AVector2D<Float> = AVConstructor.create(0, 0);
	public var input:Input;

	public function new() {
		var keys = new KeyPoll(openfl.Lib.current.stage);
		input = new KeyboardInput({
			forward: Keyboard.RIGHT,
			backward: Keyboard.LEFT,
			up: Keyboard.UP,
			down: Keyboard.DOWN,
		}, keys, [GameButtons.jump => Keyboard.SPACE]);
	}
}

class System {
	var model:Model;

	public function new(m) {
		this.model = m;
	}

	public function update(dt:Float) {}
}

class GameBounds extends System {
	override public function update(dt) {
		for (pp in model.balls) {
			var pos = pp.pos;

			for (a in Axis2D) {
				var l = model.bounds.pos[a];
				var r = model.bounds.pos[a] + model.bounds.size[a];
				var s = model.bounds.size[a];

				while (pos[a] > r)
					pos[a] -= s;
				while (pos[a] < l)
					pos[a] += s;
			}
		}
	}
}

class Ballistics extends System {
	var maxPrjVal = 400;

	override public function update(dt:Float) {
		var gravity = model.gravity;

		for (pp in model.balls) {
			for (a in Axis2D) {
				pp.spd[a] = MathUtil.clamp(pp.spd[a] + gravity[a] * dt, -maxPrjVal, maxPrjVal);
				pp.pos[a] += pp.spd[a] * dt;
			}
		}
	}
}

class PlatformDetector extends System {
	override function update(dt:Float) {
		var left:Float = -model.platform.w/2;
		var right:Float = model.platform.w/2;
		for (ball in model.balls) {
			var localY = ball.pos[vertical] - model.platform.y;
			var localX = ball.pos[horizontal] - model.platform.x;
			var r = ball.r;
			if (localY + r < 0)
				continue;
			var x = localX;
			if (x + r < left || x - r > right)
				continue;
			if (x > left && x < right)
				straightBounce(ball);
		}
	}

	function straightBounce(ball:IBall) {
		ball.spd[vertical] *= -1;
        ball.pos[vertical] = model.platform.y - ball.r - 1;
	}
}

class BallRenderer extends System {
	override function update(dt) {
		for (b in model.balls) {
			var g = b.graphics;
			g.clear();
			g.beginFill(b.color);
			g.drawCircle(b.pos[Axis2D.horizontal], b.pos[Axis2D.vertical], b.r);
			g.endFill();
		}
	}
}

class PlatformMotor extends System {
	override function update(dt:Float) {
		var p = model.platform;
		var l = model.bounds.pos[horizontal] + p.w / 2;
		var r = model.bounds.size[horizontal] - p.w / 2;
		var o = model.input.getDirProjection(horizontal) * 90 * dt;
		p.x = MathUtil.clamp(p.x + o, l, r);
	}
}

class Platform extends Sprite {
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
