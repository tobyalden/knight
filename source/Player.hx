package;

import flixel.*;
import flixel.util.*;

class Player extends FlxSprite
{
  public static inline var RUN_VELOCITY = 270;
  public static inline var JUMP_VELOCITY = -590;
  public static inline var SLIDE_VELOCITY = 590;
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
  private var isSliding:Bool;
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
    isSliding = false;
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
    animation.add("crouch_attack", [17, 18, 19, 20, 21], Std.int((5 / ATTACK_TIME)), false);
    animation.add("slide", [22, 23], 3, false);
    animation.add("slide_fall", [23]);
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
      isCrouching = true;
      isJumpingForward = false;
      jumpTimer = JUMP_DELAY;
    }

    if(!onGround)
    {
      if(!isSliding)
        velocity.x = 0;
    }

    if(onGround)
    {

      if (left && right)
        left = right = false;

      if(isSliding)
      {
        if(facing == FlxObject.RIGHT)
          velocity.x -= Math.min(FlxG.elapsed * 1000, velocity.x);
        else
          velocity.x += Math.min(FlxG.elapsed * 1000, Math.abs(velocity.x));
        if(velocity.x == 0)
          isSliding = false;
      }
      else if(jumpTimer > 0)
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
      else if(down && onGround && attackTimer == 0)
      {
        isCrouching = true;
        velocity.x = 0;
      }
      else
      {

        if(attackTimer == 0)
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

    if ((jump || isBufferingJump) && onGround && jumpTimer == 0 && (!isSliding || (isSliding && animation.curAnim.curFrame == 1)))
    {
      if(attackTimer < ATTACK_CANCEL_WINDOW)
      {
        if(down)
        {
          if(!isSliding)
          {
            isSliding = true;
            animation.play("slide", true);
            if (left)
              facing = FlxObject.LEFT;
            else if(right)
              facing = FlxObject.RIGHT;
            if(facing == FlxObject.RIGHT)
              velocity.x = SLIDE_VELOCITY;
            else
              velocity.x = -SLIDE_VELOCITY;
          }
        }
        else
        {
          attackTimer = 0;
          jumpTimer = JUMP_DELAY;
          velocity.x = 0;
          isBufferingJump = false;
        }
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
    if(attack && attackTimer < ATTACK_CANCEL_WINDOW && onGround && !isSliding)
    {
      attackTimer = ATTACK_TIME;
      isCrouching = down;
    }

    animate();

  }

  private function animate()
  {
    if(isSliding)
    {

    }
    else if(attackTimer > 0)
    {
      if(isCrouching)
        animation.play("crouch_attack");
      else
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
