package;

import flixel.*;
import flixel.util.*;

class Player extends FlxSprite
{
  public static inline var RUN_VELOCITY:Float = 200;

  public function new(x:Float = 0, y:Float = 0)
  {
    super(x, y);
    loadGraphic(AssetPaths.player__png, true, 64, 64);
    setFacingFlip(FlxObject.LEFT, true, false);
    setFacingFlip(FlxObject.RIGHT, false, false);
    animation.add("idle", [0]);
    animation.add("run", [1, 2, 3, 4, 5, 6], 6, true);
  }

  override public function update():Void
  {
    super.update();
    movement();
  }

  private function movement():Void
  {
    var left:Bool = FlxG.keys.anyPressed(["LEFT", "A"]);
    var right:Bool = FlxG.keys.anyPressed(["RIGHT", "D"]);
    if (left && right)
      left = right = false;
    else if (left)
    {
      velocity.x = -RUN_VELOCITY;
      facing = FlxObject.LEFT;
    }
    else if (right)
    {
      velocity.x = RUN_VELOCITY;
      facing = FlxObject.RIGHT;
    }
    else
      velocity.x = 0;

    velocity.y = 500;

    if(velocity.x != 0)
      animation.play("run");
    else
      animation.play("idle");
  }
}
