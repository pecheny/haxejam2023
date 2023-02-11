package j2023;

import utils.KeyBinder;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.TextFieldType;
import openfl.text.TextField;
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
		createLabel();
		var canvas = new Sprite();
		addChild(canvas);
		model.balls.push(new Ball(canvas.graphics));
        model.reset();
		addChild(model.platform);
		systems.push(new Ballistics(model));
		systems.push(new GameBounds(model));
		systems.push(new BallRenderer(model));
		systems.push(new PlatformMotor(model));
		systems.push(new PlatformDetector(model));
		systems.push(new PlatformElastics(model));
		systems.push(new PlatformJumper(model));
	}

	override function update(t:Float) {
		super.update(t);
		for (s in systems)
			s.update(1 / 60);
	}

	function createLabel() {
		var t = model.t;
		model.t = t;
		var tf = new TextFormat("Calibri", 186, 0x517bcf, true, false, false, null, null, TextFormatAlign.CENTER);
		t.type = TextFieldType.DYNAMIC;
		t.height = 300;
		t.defaultTextFormat = tf;
		t.width = stage.stageWidth;
		t.y = stage.stageHeight * .33;
		addChild(t);
	}
}

interface PointParticle {
	public var pos(default, null):AVector2D<Float>;
	public var spd(default, null):AVector2D<Float>;
}

interface IBall extends PointParticle {
	public var r(default, null):Float;
}

enum BallState {
	Ballistic;
	Bounce(onPlatformX:Float, platformPos:Float);
}

class Ball implements IBall {
	public var pos(default, null):AVector2D<Float> = AVConstructor.create(0, 0);
	public var spd(default, null):AVector2D<Float> = AVConstructor.create(0, 0);
	public var r:Float = 20;
	public var state:BallState = Ballistic;
	public var graphics:Graphics;
	public var color:Int = 0x4FBDD6;
	public var transitionTime:Float = 0;

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
	public var platformPosition:Float;
	public var transitionDuration:Float = 0.2;
	public var t:TextField;
	public var floor = AVConstructor.create(Axis2D, 0, 0);

	public function new() {
		var keys = new KeyPoll(openfl.Lib.current.stage);
		input = new KeyboardInput({
			forward: Keyboard.RIGHT,
			backward: Keyboard.LEFT,
			up: Keyboard.UP,
			down: Keyboard.DOWN,
		}, keys, [GameButtons.jump => Keyboard.SPACE]);
        var keys = new KeyBinder();
        keys.addCommand(Keyboard.R, reset);
        t = new TextField();
		gravity[vertical] = 100;
		platform = new Platform(100);
		platformPosition = 0.66;
	}

	public function reset() {
		for (ball in balls) {
			ball.pos[horizontal] = 300;
			ball.pos[vertical] = 400;
			ball.spd[horizontal] = Math.random() * 20 - 10;
			ball.spd[vertical] = -20;
		}
        floor[horizontal] = 0;
        floor[vertical] = 0;
		platform.y = bounds.size[vertical] * platformPosition;
		platform.x = bounds.size[horizontal] * 0.5;
        platform.speed[horizontal] = 0;
        platform.speed[vertical] = 0;
		t.text = "0";
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
		var dirty = false;
		for (pp in model.balls) {
			var pos = pp.pos;

			for (a in Axis2D) {
				var l = model.bounds.pos[a];
				var r = model.bounds.pos[a] + model.bounds.size[a];
				var s = model.bounds.size[a];

				while (pos[a] > r) {
					pos[a] -= s;
					model.floor[a]--;
					dirty = true;
				}
				while (pos[a] < l) {
					pos[a] += s;
					model.floor[a]++;
					dirty = true;
				}
			}
		}
		if (dirty)
			model.t.text = "" + model.floor[vertical];
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

@:enum abstract PlatformState(Int) {
	var idle;
	var jumping;
}

class PlatformJumper extends System {
	var state:PlatformState = idle;
	var t:Float;

	override function update(dt:Float) {
		switch state {
			case idle:
				if (model.input.pressed(GameButtons.jump)) {
					model.platform.speed[vertical] -= 190;
				}
			case jumping:
		}
	}
}

class PlatformElastics extends System {
	var k = 300.;
	var c = 50.;
	var mass = 5;
	var tick = 0;

	override function update(dt:Float) {
		tick++;
		var zero = model.bounds.size[vertical] * model.platformPosition;
		var p = model.platform;
		var elForce = -k * (p.y - zero);
		var frForce = -p.speed[vertical] * c;
		var force = elForce + frForce;
		var acc = force / mass;
		// if (tick % 50 == 0)
		// 	trace('elf: $elForce, fr: $frForce, total: $force, acc: $acc, spd:${p.speed[vertical]}');
		p.speed[vertical] += acc * dt;
		p.y += p.speed[vertical] * dt;
	}
}

class PlatformDetector extends System {
	override function update(dt:Float) {
		for (ball in model.balls) {
			switch ball.state {
				case Ballistic:
					handleBallistic(ball, dt);
				case Bounce(localx, platformInitial):
					handleBounce(ball, dt, localx, platformInitial);
			}
		}
	}

	function handleBounce(ball:Ball, dt, localX, platformInitial:Float) {
		ball.transitionTime += dt;
		if (ball.transitionTime >= model.transitionDuration) {
			ball.spd[vertical] = -1 * ball.spd[vertical] + model.platform.speed[vertical];
			ball.pos[vertical] = model.platform.y - ball.r - 1;
			var platformIntegralSpeed = (model.platform.x - platformInitial) / model.transitionDuration;
			ball.spd[horizontal] += platformIntegralSpeed;
			ball.state = Ballistic;
			ball.transitionTime = 0;
			return;
		} else if (model.platform.speed[vertical] > ball.spd[vertical]) {
			ball.state = Ballistic;
			ball.transitionTime = 0;
		}
		ball.pos[vertical] = model.platform.y - ball.r;
		ball.pos[horizontal] = model.platform.x + localX;
	}

	function handleBallistic(ball:Ball, dt:Float) {
		var left:Float = -model.platform.w / 2;
		var right:Float = model.platform.w / 2;
		var localY = ball.pos[vertical] - model.platform.y;
		var localX = ball.pos[horizontal] - model.platform.x;
		var r = ball.r;
		if (localY + r < 0)
			return;
		if (localY - r > model.platform.h)
			return;
		var x = localX;
		if (x + r < left || x - r > right)
			return;
		if (x > left && x < right)
			straightBounce(ball);
	}

	function straightBounce(ball:Ball) {
		// ball.spd[vertical] *= -1;
		// ball.pos[vertical] = model.platform.y - ball.r - 1;
		// model.platform.y += 20;
		model.platform.speed[vertical] += ball.spd[vertical];
		ball.transitionTime = 0;
		ball.state = Bounce(ball.pos[horizontal] - model.platform.x, model.platform.x);
	}
}

class BallRenderer extends System {
	override function update(dt) {
		for (b in model.balls) {
			var g = b.graphics;
			g.clear();
			g.beginFill(b.color);
			switch b.state {
				case Ballistic:
					g.drawCircle(b.pos[Axis2D.horizontal], b.pos[Axis2D.vertical], b.r);
				case Bounce(_):
					var t = b.transitionTime / model.transitionDuration;
					var easyt = 1 - (t - 0.5) * (t - 0.5) * 4;
					var r = b.r;
					var compressedR = lerp(easyt, r, r * 0.7);
					// var extendedR = Math.sqrt(r * r - compressedR * compressedR);
					var extendedR = r + (r - compressedR);
					g.drawEllipse(b.pos[Axis2D.horizontal] - extendedR, b.pos[Axis2D.vertical] - compressedR, extendedR * 2, compressedR * 2);
			}
			g.endFill();
		}
	}

	public static inline function lerp /*unclamped*/ (pct:Float, lo:Float, ho:Float):Float {
		return (ho - lo) * pct + lo;
	};
}

class PlatformMotor extends System {
	override function update(dt:Float) {
		var p = model.platform;
		var l = model.bounds.pos[horizontal] + p.w / 2;
		var r = model.bounds.size[horizontal] - p.w / 2;
		var o = model.input.getDirProjection(horizontal) * 230 * dt;
		p.x = MathUtil.clamp(p.x + o, l, r);
	}
}

class Platform extends Sprite {
	public var w:Float;
	public var speed:AVector2D<Float> = AVConstructor.create(0, 0);

	public var h = 10;

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
