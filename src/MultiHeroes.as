package {
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	
	import Dragging;
	import fieldofview.Fov;
	import fieldofview.Los;
	import fieldofview.Tile;
	import fieldofview.Vector2i;

	/**
	 * ...
	 * @author
	 */
	[SWF( frameRate = "60", width = "1100", height = "520" )]
	public class MultiHeroes extends Demo {

		private var fovInstance : Fov;

		private var _dragging : int = Dragging.NOTHING;

		private var _heroes : Vector.<Vector2i>;

		private var _dragFrom : Vector2i;

		private var _dragHero : Vector2i;

		public function MultiHeroes() {
			super()
		}

		override protected function initDatas() : void {
			super.initDatas();

			var loader : URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener( Event.COMPLETE, onLoadComplete );
			loader.load( new URLRequest( "assets/map.txt" ));
		}

		private function onLoadComplete( event : Event ) : void {
			var map : String = event.target.data;
			map = map.replace( /\r\n/g, "\n" );

			var tiles : Vector.<Tile> = new Vector.<Tile>();
			var array : Array = map.split( "\n" );
			var height : int = array.length;
			for ( var j : int = 0; j < height; j++ ) {
				var text : String = array[ j ];
				var width : int = text.length;
				for ( var i : int = 0; i < width; i++ ) {
					var tile : Tile = new Tile();
					tile.x = i;
					tile.y = j;
					tile.isWall = text.charAt( i ) == "#";
					tiles.push( tile );
				}
			}

			_heroes = new Vector.<Vector2i>();
			_heroes.push( new Vector2i( 3, 3 ));
			_heroes.push( new Vector2i( 4, 4 ));

			fovInstance = new Fov();
			fovInstance.setTiles( tiles, width, height );
			
			this.setTileData(fovInstance.tileData);
			
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);

			this.render();
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.UP)
			{
				var floorTile:Tile = getRandomFloor();
				if(floorTile == null)
					return;
				_heroes.push(new Vector2i(floorTile.x,floorTile.y));
			}
			else if(event.keyCode == Keyboard.DOWN)
			{
				_heroes.splice(int(Math.random()*_heroes.length),1);
			}
			this.render();
		}

		override protected function onMouseMove( pos : Vector2i ) : void {
			if ( _dragging == Dragging.NOTHING )
				return;

			switch ( _dragging ) {
				case Dragging.HERO:
					var closest : Vector2i = _dragHero.clone();
					var los : Los = new Los( _dragHero, pos );
					var step : Vector2i = los.next();
					while ( step != null ) {
						if ( getTile( step.x, step.y ).isWall )
							break;
						closest.copyFrom( step );
						if ( step.equals( pos ))
							break;

						step = los.next();
					}

					if ( !closest.equals( _dragHero )) {
						_dragHero.copyFrom( closest );
						render();
					}
					break;
				case Dragging.FLOOR:
				case Dragging.WALL:

					los = new Los( _dragFrom, pos );
					step = los.next();
					while ( step != null ) {
						getTile( step.x, step.y ).isWall = ( _dragging == Dragging.WALL );

						if ( step.equals( pos ))
							break;

						step = los.next();
					}

					_dragFrom = pos;
					render();
					break;
				default:
					break;
			}
		}

		override protected function onMouseUp( pos : Vector2i ) : void {
			_dragging = Dragging.NOTHING;
			_dragHero = null;
			_dragFrom = null;
		}

		override protected function onMouseDown( pos : Vector2i ) : void {

			for ( var i : int = 0; i < _heroes.length; i++ ) {
				if ( _heroes[ i ].x == pos.x && _heroes[ i ].y == pos.y ) {
					_dragHero = _heroes[ i ];
					_dragging = Dragging.HERO;
					return;
				}
			}

			var tile : Tile = getTile( pos.x, pos.y );
			tile.isWall = !tile.isWall;
			_dragging = tile.isWall ? Dragging.WALL : Dragging.FLOOR;
			_dragFrom = pos.clone();
			render();
		}

		override public function render() : void {
			if ( fovInstance == null )
				return;

			cleanTileStates();

			for ( var i : int = 0; i < _heroes.length; i++ ) {
				fovInstance.refresh( _heroes[ i ],4);
			}

			super.render();

			for ( i = 0; i < _heroes.length; i++ ) {
				drawSprite( TileAsset.hero, _heroes[ i ].x, _heroes[ i ].y );
			}
		}

		private function getRandomFloor(curTry:int=0,maxTry:int=10000):Tile
		{
			curTry++;
			var tiles:Vector.<Tile> = getTiles();
			var tile:Tile = tiles[int(Math.random()*tiles.length)];
			if(!tile.isWall)
			{
				return tile;
			}
			else if(curTry >= maxTry)
			{
				return null;
			}
			else
			{
				return getRandomFloor(curTry,maxTry);
			}
		}
	}

}
