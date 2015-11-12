package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import fieldofview.Tile;
	import fieldofview.TileData;
	import fieldofview.Vector2i;

	public class Demo extends Sprite {
		[Embed( source = "assets/tiles.png" )]
		private var TILE_CLS : Class;

		private var _tileSprite : Sprite;

		private var _bitmapData : BitmapData;

		protected var tileData : TileData;

		public function Demo() {
			if ( stage )
				init();
			else
				addEventListener( Event.ADDED_TO_STAGE, init );
		}

		private function init( e : Event = null ) : void {
			removeEventListener( Event.ADDED_TO_STAGE, init );

			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;

			_bitmapData = Bitmap( new TILE_CLS()).bitmapData;

			_tileSprite = new Sprite();
			this.addChild( _tileSprite );
			_tileSprite.addEventListener( MouseEvent.MOUSE_DOWN, _onMouseDown );
			_tileSprite.addEventListener( MouseEvent.MOUSE_UP, _onMouseUp );
			_tileSprite.addEventListener( MouseEvent.MOUSE_MOVE, _onMouseMove );

			initDatas();
		}

		protected function initDatas() : void {

		}

		protected function setTileData( tileData : TileData ) : void {
			this.tileData = tileData;
			if ( _tileSprite ) {
				var w:int = tileData.bounds.width * TileAsset.TILE_WIDTH;
				var h:int = tileData.bounds.height * TileAsset.TILE_HEIGHT;
				_tileSprite.graphics.beginFill(0x0,0);
				_tileSprite.graphics.drawRect(0,0,w,h);
				_tileSprite.graphics.endFill();
			}
		}

		protected function onMouseMove( pos : Vector2i ) : void {

		}

		protected function _onMouseMove( event : MouseEvent ) : void {

			var px : int = _tileSprite.mouseX / TileAsset.TILE_WIDTH;
			var py : int = _tileSprite.mouseY / TileAsset.TILE_HEIGHT;
			var pos : Vector2i = new Vector2i( px, py );

			onMouseMove( pos );

			event.updateAfterEvent();
		}

		protected function onMouseUp( pos : Vector2i ) : void {

		}

		protected function _onMouseUp( event : MouseEvent ) : void {

			var px : int = _tileSprite.mouseX / TileAsset.TILE_WIDTH;
			var py : int = _tileSprite.mouseY / TileAsset.TILE_HEIGHT;
			var pos : Vector2i = new Vector2i( px, py );

			onMouseUp( pos );
		}

		protected function onMouseDown( pos : Vector2i ) : void {

		}

		protected function _onMouseDown( event : MouseEvent ) : void {
			var px : int = _tileSprite.mouseX / TileAsset.TILE_WIDTH;
			var py : int = _tileSprite.mouseY / TileAsset.TILE_HEIGHT;
			var pos : Vector2i = new Vector2i( px, py );

			onMouseDown( pos );
		}

		protected function getTile( px : int, py : int ) : Tile {
			return tileData.getTile( px, py );
		}

		protected function getTiles() : Vector.<Tile> {
			return tileData.tiles;
		}

		private var _tileBitmaps : Array = [];

		protected function drawTile( pos : Vector2i, spriteType : int = 0 ) : void {
			var tile : Tile = getTile( pos.x, pos.y );
			if ( tile.isExplored ) {
				spriteType = tile.isWall ? TileAsset.wall : TileAsset.floor;
				if ( tile.isVisible )
					spriteType++;
			}

			drawSprite( spriteType, tile.x, tile.y );
		}

		protected function drawLine( from : Vector2i, to : Vector2i, lineColor : uint = 0x888888, alpha : Number = 1.0 ) : void {
			_tileSprite.graphics.lineStyle( 1, lineColor, alpha );
			_tileSprite.graphics.moveTo( from.x, from.y );
			_tileSprite.graphics.lineTo( to.x, to.y );
			_tileSprite.graphics.endFill();
		}

		protected function drawSprite( spriteType : int, px : int, py : int ) : void {
			var newBitmapData : BitmapData;
			if ( _tileBitmaps[ spriteType ] == null ) {
				newBitmapData = new BitmapData( TileAsset.TILE_WIDTH, TileAsset.TILE_HEIGHT, true );

				var rect : Rectangle = new Rectangle( spriteType * TileAsset.TILE_WIDTH, 0, TileAsset.TILE_WIDTH, TileAsset.TILE_HEIGHT );
				newBitmapData.copyPixels( _bitmapData, rect, new Point( 0, 0 ));
				_tileBitmaps[ spriteType ] = newBitmapData;
			} else {
				newBitmapData = _tileBitmaps[ spriteType ];
			}

			_tileSprite.graphics.beginBitmapFill( newBitmapData );
			_tileSprite.graphics.drawRect( px * TileAsset.TILE_WIDTH, py * TileAsset.TILE_HEIGHT, TileAsset.TILE_WIDTH, TileAsset.TILE_HEIGHT );
			_tileSprite.graphics.endFill();
		}

		protected function clear() : void {
			_tileSprite.graphics.clear();
			
			if(tileData != null)
			{
				var w:int = tileData.bounds.width * TileAsset.TILE_WIDTH;
				var h:int = tileData.bounds.height * TileAsset.TILE_HEIGHT;
				_tileSprite.graphics.beginFill(0x0,0);
				_tileSprite.graphics.drawRect(0,0,w,h);
				_tileSprite.graphics.endFill();
			}
		}

		public function render() : void {
			clear();

			var tiles : Vector.<Tile> = getTiles();
			for ( var i : int = 0; i < tiles.length; i++ ) {
				var tile : Tile = tiles[ i ];
				drawTile( new Vector2i( tile.x, tile.y ));
			}
		}

		/**
		 * 清理方块的可见性
		 *
		 */
		public function cleanTileStates() : void {
			var tiles : Vector.<Tile> = getTiles();
			for ( var i : int = 0; i < tiles.length; i++ ) {
				var tile : Tile = tiles[ i ];
				tile.isVisible = false;
			}
		}

		private var _tmpVec : Vector2i = new Vector2i();

		protected function walkOctant( center : Vector2i, octant : int, distance : int = 10 ) : Vector.<Vector2i> {
			var result : Vector.<Vector2i> = new Vector.<Vector2i>();

			for ( var row : int = 1; row < distance; row++ ) {
				// Stop if we go out of bounds.
				var pos : Vector2i = center.add( tileData.transformOctant( row, 0, octant, _tmpVec ));
				if ( !tileData.bounds.contains( pos ))
					return result;

				for ( var col : int = 0; col <= row; col++ ) {
					pos = center.add( tileData.transformOctant( row, col, octant, _tmpVec ));

					// Skip any columns that are out of bounds.
					if ( tileData.bounds.contains( pos )) {
						result.push( pos );
					}
				}
			}
			return result;
		}
	}

}
