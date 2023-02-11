package j2023;

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
        createLabel();
		model.bounds.size = AVConstructor.create(stage.stageWidth, stage.stageHeight);
		model.balls.push(new Ball(graphics));
		model.gravity[vertical] = 100;
		model.platform = new Platform(100);
		model.platform.y = model.bounds.size[vertical] * model.platformPosition;
		model.platform.x = model.bounds.size[horizontal] * 0.5;
		addChild(model.platform);
		systems.push(new Ballistics(model));
		systems.push(new GameBounds(model));
		systems.push(new BallRenderer(model));
		systems.push(new PlatformMotor(model));
		systems.push(new PlatformDetector(model));
		systems.push(new PlatformElastics(model));
	}

	override function update(t:Float) {
		super.update(t);
		for (s in systems)
			s.update(1 / 60);
	}

    function createLabel() {
        var t = new TextField();
        model.t = t;
        var tf = new TextFormat("Calibri", 86, 0xffffff, true, false, false, null, null, TextFormatAlign.CENTER);
        t.type = TextFieldType.DYNAMIC;
        t.defaultTextFormat = tf;
        t.width = stage.stageWidth;
        t.text = "00";
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
	Bounce;
}

class Ball implements IBall {
	public var pos(default, null):AVector2D<Float> = AVConstructor.create(300, 400);
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
	public var platformPosition = 0.66;
	public var transitionDuration:Float = 0.5;
    public var t:TextField;
    public var floor = AVConstructor.create(Axis2D, 0,0);

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
        var dirty = false;
		for (pp in model.balls) {
			var pos = pp.pos;

			for (a in Axis2D) {
				var l = model.bounds.pos[a];
				var r = model.bounds.pos[a] + model.bounds.size[a];
				var s = model.bounds.size[a];

				while (pos[a] > r){
					pos[a] -= s;
                    model.floor[a] --;
                    dirty = true;
                }
				while (pos[a] < l){
					pos[a] += s;
                    model.floor[a] ++;
                    dirty = true;
                }
			}
		}
        if(dirty)
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
				case Bounce:
					handleBounce(ball, dt);
			}
		}
	}

	function handleBounce(ball:Ball, dt) {
		ball.transitionTime += dt;
		if (ball.transitionTime >= model.transitionDuration) {
            ball.transitionTime = 0;
            ball.spd[vertical] = -1 *ball.spd[vertical] + model.platform.speed[vertical];
            ball.pos[vertical] = model.platform.y - ball.r -1;
            ball.state = Ballistic;
            return;
        }
        ball.pos[vertical] = model.platform.y - ball.r;
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
        ball.state = Bounce;
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
