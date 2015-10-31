package;

import flixel.*;
import flixel.util.*;

class Player extends FlxSprite
{
  public static inline var RUN_VELOCITY = 270;
  public static inline var JUMP_VELOCITY = -590;
  public static inline var GRAVITY = 1970;
  public static inline var TERMINAL_VELOCITY = 480;

  public static inline var JUMP_DELAY = 0.1;
  public static inline var JUMP_APEX_VELOCITY = 200;

  public static inline var ATTACK_TIME = 0.5;
  public static inline var ATTACK_CANCEL_WINDOW = 0.2;


  private var onGround:Bool;
  private var isCrouching:Bool;
  private var isLanding:Bool;
  private var isJumpingForward:Bool;
  private var isAttacking:Bool;
  private var isBufferingJump:Bool;
  private var jumpTimer:Float;
  private var attackTimer:Float;

  public function new(x:Float = 0, y:Float = 0)
  {
    super(x, y);
    onGround = false;
    isCrouching = false;
    isLanding = false;
    isJumpingForward = false;
    isBufferingJump = false;
    jumpTimer = 0;
    attackTimer = 0;
    loadGraphic("assets/images/player.png", true, 80, 80);
    setFacingFlip(FlxObject.LEFT, true, false);
    setFacingFlip(FlxObject.RIGHT, false, false);
    animation.add("idle", [0]);
    animation.add("run", [1, 2, 3, 4, 5, 6], 10, true);
    animation.add("crouch", [7]);
    animation.add("jump_start", [8]);
    animation.add("jump_tuck", [9]);
    animation.add("jump_end", [10]);
    animation.add("attack", [11, 12, 13, 14, 15], Std.int((5 / ATTACK_TIME)), false);
    setSize(29, 63);
    offset.set(23, 17);
  }

  override public function update():Void
  {
    movement();
    super.update();
  }

  private function movement():Void
  {
    var left:Bool = FlxG.keys.anyPressed(["LEFT"]);
    var right:Bool = FlxG.keys.anyPressed(["RIGHT"]);
    var down:Bool = FlxG.keys.anyPressed(["DOWN"]);
    var jump:Bool = FlxG.keys.anyPressed(["Z"]);
    var attack:Bool = FlxG.keys.justPressed.X;

    onGround = isTouching(FlxObject.FLOOR);
    if(justTouched(FlxObject.FLOOR))
    {
      isLanding = true;
      isJumpingForward = false;
      jumpTimer = JUMP_DELAY;
    }

    if(onGround)
    {

      if (left && right)
        left = right = false;

      if(jumpTimer > 0)
      {
        jumpTimer -= Math.min(FlxG.elapsed, jumpTimer);
        velocity.x = 0;
        if(jumpTimer == 0)
        {
          if(isLanding)
            isLanding = false;
          else
          {
            velocity.y = JUMP_VELOCITY;
            if (left)
            {
              velocity.x = -RUN_VELOCITY;
              facing = FlxObject.LEFT;
              isJumpingForward = true;
            }
            else if(right)
            {
              velocity.x = RUN_VELOCITY;
              facing = FlxObject.RIGHT;
              isJumpingForward = true;
            }
            else
              velocity.x = 0;
            onGround = false;
          }
        }
      }
      else if(down && onGround)
      {
        isCrouching = true;
        velocity.x = 0;
      }
      else
      {
        isCrouching = false;

        if(attackTimer == 0)
        {
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
    }
    else
    {
      if(isJumpingForward)
      {
        if(facing == FlxObject.RIGHT)
          velocity.x = RUN_VELOCITY;
        else
          velocity.x = -RUN_VELOCITY;
      }
    }

    velocity.y += GRAVITY * FlxG.elapsed;
    if(velocity.y > TERMINAL_VELOCITY)
      velocity.y = TERMINAL_VELOCITY;

    if ((jump || isBufferingJump) && onGround && jumpTimer == 0 && !isCrouching)
    {
      if(attackTimer < ATTACK_CANCEL_WINDOW)
      {
        attackTimer = 0;
        jumpTimer = JUMP_DELAY;
        velocity.x = 0;
        isBufferingJump = false;
      }
      else
      {
        isBufferingJump = true;
      }
    }

    if(attackTimer > 0)
    {
      attackTimer -= Math.min(FlxG.elapsed, attackTimer);
      velocity.x = 0;
    }
    if(attack && attackTimer < ATTACK_CANCEL_WINDOW && onGround)
    {
      attackTimer = ATTACK_TIME;
      animation.play("attack", true);
    }

    animate();

  }

  private function animate()
  {
    if(attackTimer > 0)
    {
      animation.play("attack");
    }
    else if (onGround)
    {
      if(isCrouching || jumpTimer > 0)
        animation.play("crouch");
      else if (velocity.x != 0)
        animation.play("run");
      else
        animation.play("idle");
    }
    else
    {
      if(Math.abs(velocity.y) < JUMP_APEX_VELOCITY)
        animation.play("jump_tuck");
      else if(velocity.y < 0)
        animation.play("jump_start");
      else
        animation.play("jump_end");
    }
  }

  public function setOnGround(onGround)
  {
    this.onGround = onGround;
  }

}
