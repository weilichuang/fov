package {
	import Dragging;
	import fieldofview.Fov;
	import fieldofview.Los;
	import fieldofview.Shadow;
	import fieldofview.Tile;
	import fieldofview.TileData;
	import fieldofview.Vector2i;

	public class ShadowCast extends Demo {
		private var _dragging : int = Dragging.NOTHING;

		private var _hero : Vector2i;

		private var _dragFrom : Vector2i;

		private var tiles : Vector.<Tile>;
		private var tileNumX : int;
		private var tileNumY : int;

		private var _line : int = 0;

		public function ShadowCast() {
			super();
		}

		override protected function initDatas() : void {
			_hero = new Vector2i( 7, 17 );

			tileNumX = 31;
			tileNumY = 19;
			var tiles : Vector.<Tile> = new Vector.<Tile>();
			for ( var j : int = 0; j < tileNumY; j++ ) {
				for ( var i : int = 0; i < tileNumX; i++ ) {
					var tile : Tile = new Tile();
					tile.x = i;
					tile.y = j;
					tiles.push( tile );
				}
			}

			this.tileData = new TileData();
			this.tileData.setTiles( tiles, tileNumX, tileNumY );
			this.setTileData(this.tileData);

			getTile( 7, 13 ).isWall = true;
			getTile( 11, 11 ).isWall = true;
			getTile( 10, 11 ).isWall = true;
			getTile( 9, 8 ).isWall = true;
			getTile( 9, 7 ).isWall = true;
			getTile( 10, 3 ).isWall = true;
			getTile( 11, 3 ).isWall = true;
			getTile( 12, 3 ).isWall = true;
			getTile( 12, 4 ).isWall = true;
			getTile( 12, 5 ).isWall = true;
			getTile( 12, 6 ).isWall = true;

			this.render();
		}

		override protected function onMouseMove( pos : Vector2i ) : void {
			if ( _dragging == Dragging.NOTHING )
				return;

			switch ( _dragging ) {
				case Dragging.FLOOR:
				case Dragging.WALL:

					var los : Los = new Los( _dragFrom, pos );
					var step : Vector2i = los.next();
					while ( step != null ) {
						getTile( step.x, step.y ).isWall = ( _dragging == Dragging.WALL );

						if ( step.equals( pos ))
							break;

						step = los.next();
					}

					_dragFrom = pos;
					render();
					break;
				case Dragging.LINE:
					var line : Number = _hero.y - pos.y;
					line = Math.max( 0, line );
					line = Math.min( 17, line );
					if ( _line != line ) {
						_line = line;
						render();
					}
					break;
				default:
					break;
			}
		}

		override protected function onMouseUp( pos : Vector2i ) : void {
			_dragging = Dragging.NOTHING;
		}

		override protected function onMouseDown( pos : Vector2i ) : void {
			if ( pos.x < 7 ) {
				_dragging = Dragging.LINE;
				return;
			}

			var tile : Tile = getTile( pos.x, pos.y );
			tile.isWall = !tile.isWall;
			_dragging = tile.isWall ? Dragging.WALL : Dragging.FLOOR;
			_dragFrom = pos.clone();
			render();
		}

		override public function render() : void {

			clear();

			var posList : Vector.<Vector2i> = walkOctant( _hero, 0, 18 );
			for each ( var pos : Vector2i in posList ) {
				getTile( pos.x, pos.y ).isVisible = true;
			}

			var fov : Fov = new Fov();
			fov.tileData = tileData;
			var shadows : Vector.<Shadow> = fov.refreshOctant( _hero, 0, _line + 1 );

			drawTile( _hero, TileAsset.floor );
			drawTile( _hero, TileAsset.hero );

			posList = walkOctant( _hero, 0, 18 );
			for each( pos in posList ) {
				drawTile( pos );
			}

			var lineY : int = ( _hero.y - _line )*10;
			var lineLeft : int = 7*10;
			var lineRight : int = ( 9 + _line )*10;

			drawLine( new Vector2i( lineLeft, lineY ), new Vector2i( lineRight, lineY ), 0xffffff, 0.2 );

			var lineWidth : int = lineRight - lineLeft;
			for each ( var shadow : Shadow in shadows ) {
				var left : int = shadow.start * lineWidth + lineLeft;
				var right : int = shadow.end * lineWidth + lineLeft;

				drawLine( new Vector2i( left, lineY ), new Vector2i( right, lineY ), 0xffffff );

				// Show the lines from the point where the shadow starts.
				drawLine( endpointToPixel( shadow.startPos ), new Vector2i( left, lineY ), 0xffffff, 0.3 );
				drawLine( endpointToPixel( shadow.endPos ), new Vector2i( right, lineY ), 0xffffff, 0.3 );
			}

			drawSprite( TileAsset.slider, 60, lineY-5);

			lineY = 175;
			lineLeft = 100;
			lineRight = 250;
			lineWidth = lineRight - lineLeft;
			for each ( shadow in shadows ) {
				left = shadow.start * lineWidth + lineLeft;
				right = shadow.end * lineWidth + lineLeft;

				// Show the lines from the point where the shadow starts.
				drawLine( new Vector2i( left, lineY ), new Vector2i( right, lineY ), 0x0 );
				drawLine( new Vector2i( left, lineY - 2 ), new Vector2i( left, lineY + 2 ), 0x0 );
				drawLine( new Vector2i( right, lineY - 2 ), new Vector2i( right, lineY + 2 ), 0x0 );
			}
		}

		protected function endpointToPixel( endpoint : Vector2i ) : Vector2i {
			var pos : Vector2i = tileData.transformOctant( endpoint.y - 2, endpoint.x, 0 );
			pos.x = ( pos.x + _hero.x ) * 10;
			pos.y = ( pos.y + _hero.y ) * 10;
			return pos;
		}
	}
}
