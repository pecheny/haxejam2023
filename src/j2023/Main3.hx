package j2023;

import openfl.geom.Point;
import utils.Data.Vec2D;
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
		// stage.window.frameRate = 60;
		// lime.app.Application.current.window.frameRate = 60;
		// timeMultiplier = 1.5;

		model.bounds.size = AVConstructor.create(stage.stageWidth, stage.stageHeight);
		initLabel(model.floorLabel, 186, stage.stageHeight * .33);
		initLabel(model.recordLabel, 86, stage.stageHeight * .33 - 50);
		initLabel(model.windLabel, 48, stage.stageHeight * .33 - 100);
		var canvas = new Sprite();
		addChild(canvas);
		model.balls.push(new Ball(canvas.graphics));
		model.reset();
		addChild(model.platform);
		systems.push(new Ballistics(model));
		systems.push(new GameBounds(model));
		systems.push(new BallRenderer(model));
		systems.push(new PlatformMotor(model));
		systems.push(new PlatformDetector(model, 1));
		systems.push(new PlatformDetector(model, -1));
		systems.push(new PlatformElastics(model));
		systems.push(new PlatformJumper(model));
		// systems.push(new Portal(model));
		var keys = new KeyBinder();
		keys.addCommand(Keyboard.R, model.reset);
		keys.addCommand(Keyboard.P, () -> {
			p = !p;
			trace("p");
		});
	}

	var p = false;

	override function update(dt:Float) {
		if (p)
			return;
		for (s in systems)
			s.update(dt);
	}

	function initLabel(t:TextField, size, pos) {
		var tf = new TextFormat("Calibri", size, 0x517bcf, true, false, false, null, null, TextFormatAlign.CENTER);
		t.type = TextFieldType.DYNAMIC;
		t.selectable = false;
		t.height = size;
		t.defaultTextFormat = tf;
		t.width = stage.stageWidth;
		t.y = pos;
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
	Bounce(onPlatformX:Float, platformPos:Float, sign:Int);
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
	public var floorLabel:TextField;
	public var recordLabel:TextField;
	public var windLabel:TextField;
	public var floor = AVConstructor.create(Axis2D, 0, 0);

	public var entrance:Gate = new Gate(100, 0x00ff00);
	public var exit:Gate = new Gate(100, 0xff0000);

	public function new() {
		var keys = new KeyPoll(openfl.Lib.current.stage);
		input = new KeyboardInput({
			forward: Keyboard.RIGHT,
			backward: Keyboard.LEFT,
			up: Keyboard.UP,
			down: Keyboard.DOWN,
		}, keys, [GameButtons.jump => Keyboard.SPACE]);
		floorLabel = new TextField();
		recordLabel = new TextField();
		windLabel = new TextField();
		gravity[vertical] = 100;
		platform = new Platform(100);
		platformPosition = 0.66;
	}

	function rndPos(a:Axis2D) {
		var b = bounds;
		return b.pos[a] + Math.random() * b.size[a];
	}

	function randomizeGate(gate:Gate) {
		gate.x = rndPos(horizontal);
		gate.y = rndPos(vertical);
		gate.rotation = -180 + Math.random() * 360;
	}

	public function reset() {
		for (ball in balls) {
			ball.pos[horizontal] = 300;
			ball.pos[vertical] = 400;
			// ball.pos[vertical] = 700;
			ball.spd[horizontal] = Math.random() * 20 - 10;
			ball.spd[vertical] = 430;
		}
		floor[horizontal] = 0;
		floor[vertical] = 0;
		platform.y = bounds.size[vertical] * platformPosition;
		platform.x = bounds.size[horizontal] * 0.5;
		platform.speed[horizontal] = 0;
		platform.speed[vertical] = 0;
		gravity[horizontal] = 0;
		record = 0;
		updateLabels();
		randomizeGate(entrance);
		randomizeGate(exit);
	}

	var record = 0;

	public function updateLabels() {
		if (floor[vertical] > 10)
			gravity[horizontal] = if (Math.random() > 0.7) Math.random() * 30 - 15 else 0;
		else
			gravity[horizontal] = 0;
		windLabel.text = "wind: " + Std.int(gravity[horizontal] * 100);
		var v = floor[vertical];
		floorLabel.text = "" + v;
		if (v < record)
			return;
		record = v;
		recordLabel.text = "MAX: " + v;
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
					if (a == vertical)
						dirty = true;
				}
				while (pos[a] < l) {
					pos[a] += s;
					model.floor[a]++;
					if (a == vertical)
						dirty = true;
				}
			}
		}
		if (dirty)
			model.updateLabels();
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
					model.platform.speed[vertical] -= 400 * (dt * 60);
					// state=jumping;
					t = 0;
				}
			case jumping:
				// t+=dt;
				// if(t < 0.6)
				// 	model.platform.speed[vertical] -= 200;
				// if (t > 1)
				//     state = idle;
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
	var sign = 1;

	public function new(m, sign) {
		super(m);
		this.sign = sign;
	}

	override function update(dt:Float) {
		for (ball in model.balls) {
			switch ball.state {
				case Ballistic:
					handleBallistic(ball, dt);
				case Bounce(localx, platformInitial, sign):
					if (sign == this.sign)
						handleBounce(ball, dt, localx, platformInitial);
			}
		}
	}

	function handleBounce(ball:Ball, dt, localX, platformInitial:Float) {
		ball.transitionTime += dt;
		if (ball.transitionTime >= model.transitionDuration) {
			if (ball.spd[vertical] * sign > 0)
				ball.spd[vertical] *= -1;
			if (model.platform.speed[vertical] * ball.spd[vertical] > 0)
				ball.spd[vertical] += model.platform.speed[vertical];
			ball.pos[vertical] = model.platform.y - (ball.r + model.platform.h / 2 + 4) * sign;
			var platformIntegralSpeed = (model.platform.x - platformInitial) / model.transitionDuration;
			ball.spd[horizontal] += platformIntegralSpeed;
			ball.state = Ballistic;
			ball.transitionTime = 0;
		} else if (sign * (model.platform.speed[vertical] - ball.spd[vertical]) > 0) {
			ball.state = Ballistic;
			ball.transitionTime = 0;
			ball.pos[vertical] -= sign * 3;
		} else {
			ball.pos[vertical] = model.platform.y - (ball.r + model.platform.h / 2) * sign;
			ball.pos[horizontal] = model.platform.x + localX;
		}
	}

	function handleBallistic(ball:Ball, dt:Float) {
		var left:Float = -model.platform.w / 2;
		var right:Float = model.platform.w / 2;
		var localY = ball.pos[vertical] - model.platform.y;
		var localX = ball.pos[horizontal] - model.platform.x;
		var r = ball.r;
		if (localY + (r + model.platform.h / 2) < 0) {
			return;
		}
		if (localY - (r + model.platform.h / 2) > 0) {
			return;
		}
		var localVSpd = ball.spd[vertical] - model.platform.speed[vertical];
		if (localVSpd * sign < 0) {
			return;
		}
		var x = localX;
		if (x + r < left || x - r > right)
			return;
		if (x > left && x < right)
			straightBounce(ball);
		else
			cornerHit(ball);
	}

	var cornerPos = new Vec2D(0, 0);
	var localPos = new Vec2D(0, 0);
	var localSpd = new Vec2D(0, 0);
	var normal = new Vec2D(0, 0);

	function cornerHit(ball:Ball) {
		var pl = model.platform;
		var ballSpd:Vec2D = cast ball.spd;
		var platfSpd:Vec2D = cast pl.speed;
		localSpd.copyFrom(ballSpd);
		localSpd.remove(platfSpd);
		localPos.x = ball.pos[horizontal] - pl.x;
		localPos.y = ball.pos[vertical] - pl.y;
		cornerPos.x = localPos.x > 0 ? pl.w / 2 : -pl.w / 2;
		normal.copyFrom(cornerPos);
		normal.remove(localPos);
		normal.normalize(1);
		localSpd.reflect(normal);
		ballSpd.x = localSpd.x + platfSpd.x;
		ballSpd.y = localSpd.y + platfSpd.y;
	}

	function straightBounce(ball:Ball) {
		// ball.spd[vertical] *= -1;
		// ball.pos[vertical] = model.platform.y - ball.r - 1;
		// model.platform.y += 20;
		model.platform.speed[vertical] += ball.spd[vertical];
		ball.transitionTime = 0;
		ball.state = Bounce(ball.pos[horizontal] - model.platform.x, model.platform.x, sign);
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
		graphics.drawRect(-w / 2, -h / 2, w, h);
		graphics.endFill();
		// graphics.beginFill(0xff0000);
		// graphics.drawRect(-w / 2, 0, w, 2);
		// graphics.endFill();
	}
}

class Portal extends System {
	var point:Point = new Point();

	override function update(dt:Float) {
		for (ball in model.balls)
			handleBall(ball);
	}

	public function handleBall(b:Ball) {
		var entrance = model.entrance;
		var exit = model.exit;
		point.setTo(b.pos[horizontal], b.pos[vertical]);
		var local = entrance.globalToLocal(point);
		if (local.y < 0 || local.x < -entrance.w / 2 || local.x > entrance.w / 2)
			return;
		var newpos = exit.localToGlobal(local);

		point.setTo(b.spd[horizontal] + entrance.x, b.spd[vertical] + entrance.y);
		var newspd = exit.localToGlobal(entrance.globalToLocal(point));
		newspd.x -= exit.x;
		newspd.y -= exit.y;
		trace(b.spd, point, newspd);

		b.pos[horizontal] = (newpos.x);
		b.pos[vertical] = (newpos.y);
		b.spd[horizontal] = (newspd.x);
		b.spd[vertical] = (newspd.y);
	}
}

class Gate extends Sprite {
	public var w:Float;

	var h = 20;

	public function new(w, c) {
		super();
		this.w = w;
		w += 20;
		graphics.beginFill(0);
		graphics.drawRect(-w / 2, 0, w, h);
		graphics.endFill();
		graphics.beginFill(c);
		graphics.drawRect(-w / 2, 0, w, 2);
		graphics.endFill();
	}
}
