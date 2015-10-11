package;

import flixel.*;
import flixel.tile.*;
import flixel.text.*;
import flixel.ui.*;
import flixel.util.*;
import flixel.addons.editors.tiled.*;
import org.flixel.tmx.*;
import flash.system.*;

class PlayState extends FlxState
{
	public static inline var TILE_SIZE = 16;

	private var player:Player;
	private var level:FlxTilemap;

	override public function create():Void
	{
		super.create();
		player = new Player(20, 20);
		add(player);

		var tmx:TiledMap = new TiledMap('assets/data/testmap.tmx');
    level = new FlxTilemap();
    level.loadMap(tmx.getLayer("tiles").csvData, "assets/images/tiles.png", TILE_SIZE, TILE_SIZE, 0, 1);
		level.setTileProperties(31, FlxObject.ANY);
		add(level);
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		super.update();
		FlxG.collide(player, level);
		player.setCanJump(player.isTouching(FlxObject.FLOOR));
		if (FlxG.keys.justPressed.ESCAPE)
			System.exit(0);
	}
}
