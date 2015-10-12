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

		var tmx:TiledMap = new TiledMap('assets/data/testmap.tmx');
    level = new FlxTilemap();
    level.loadMap(tmx.getLayer("tiles").csvData, "assets/images/tiles.png", TILE_SIZE, TILE_SIZE, 0, 1);
		level.setTileProperties(4, FlxObject.NONE);
		level.setTileProperties(31, FlxObject.ANY);
		add(level);

		player = new Player(20, 20);
		add(player);
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		FlxG.collide(player, level);
		player.setOnGround(player.isTouching(FlxObject.FLOOR));
		super.update();
		if (FlxG.keys.justPressed.ESCAPE)
			System.exit(0);
	}
}
