package;

import flixel.*;
import flixel.util.*;

class Player extends FlxSprite
{
  public static inline var RUN_VELOCITY = 270;
  public static inline var JUMP_VELOCITY = -590;
  public static inline var GRAVITY = 1970;
  public static inline var TERMINAL_VELOCITY = 480;

  public static inline var JUMP_DELAY = 0.05;

  private var onGround:Bool;
  private var isCrouching:Bool;
  private var jumpTimer:Float;

  public function new(x:Float = 0, y:Float = 0)
  {
    super(x, y);
    onGround = false;
    isCrouching = false;
    jumpTimer = 0;
    loadGraphic("assets/images/player.png", true, 64, 64);
    setFacingFlip(FlxObject.LEFT, true, false);
    setFacingFlip(FlxObject.RIGHT, false, false);
    animation.add("idle", [0]);
    animation.add("run", [1, 2, 3, 4, 5, 6], 10, true);
    animation.add("jump", [11]);
    animation.add("crouch", [10]);
    setSize(24, 47);
    offset.set(20, 17);
  }

  override public function update():Void
  {
    super.update();
    movement();
  }

  private function movement():Void
  {
    var left:Bool = FlxG.keys.anyPressed(["LEFT"]);
    var right:Bool = FlxG.keys.anyPressed(["RIGHT"]);
    var down:Bool = FlxG.keys.anyPressed(["DOWN"]);
    var jump:Bool = FlxG.keys.anyPressed(["Z"]);
    if(onGround)
    {

      if (left && right)
        left = right = false;

      if(jumpTimer > 0)
      {
        jumpTimer -= Math.min(FlxG.elapsed, jumpTimer);
        if(jumpTimer == 0)
        {
          velocity.y = JUMP_VELOCITY;
          if (left)
          {
            velocity.x = -RUN_VELOCITY;
            facing = FlxObject.LEFT;
          }
          else if(right)
          {
            velocity.x = RUN_VELOCITY;
            facing = FlxObject.RIGHT;
          }
          else
            velocity.x = 0;
          onGround = false;
        }
        animation.play("jump");
      }

      else if(down && onGround)
      {
        isCrouching = true;
        velocity.x = 0;
      }
      else
      {
        isCrouching = false;
        if (left)
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
      }
    }

    velocity.y += GRAVITY * FlxG.elapsed;
    if(velocity.y > TERMINAL_VELOCITY)
      velocity.y = TERMINAL_VELOCITY;
    if (jump && onGround && jumpTimer == 0 && !isCrouching)
    {
      jumpTimer = JUMP_DELAY;
      velocity.x = 0;
    }

    if (onGround)
    {
      if(isCrouching || jumpTimer > 0)
        animation.play("crouch");
      else if (velocity.x != 0)
        animation.play("run");
      else
        animation.play("idle");
    }
  }

  public function setOnGround(onGround)
  {
    this.onGround = onGround;
  }

}
