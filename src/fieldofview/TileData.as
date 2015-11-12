package fieldofview
{
	public class TileData
	{
		public var bounds : Recti;
		
		public var tiles : Vector.<Tile>;
		
		public function TileData()
		{
		}
		
		public function setTiles( tiles : Vector.<Tile>, width : int, heigth : int ) : void {
			this.tiles = tiles;
			this.bounds = new Recti();
			this.bounds.x = 0;
			this.bounds.y = 0;
			this.bounds.width = width;
			this.bounds.height = heigth;
		}
		
		public function getTile( x : int, y : int ) : Tile {
			return tiles[ x + y * this.bounds.width ];
		}
		
		public function transformOctant( row : int, col : int, octant : int, result : Vector2i = null ) : Vector2i {
			if ( result == null )
				result = new Vector2i();
			switch ( octant ) {
				case 0:
					result.setTo( col, -row );
					break;
				case 1:
					result.setTo( row, -col );
					break;
				case 2:
					result.setTo( row, col );
					break;
				case 3:
					result.setTo( col, row );
					break;
				case 4:
					result.setTo( -col, row );
					break;
				case 5:
					result.setTo( -row, col );
					break;
				case 6:
					result.setTo( -row, -col );
					break;
				case 7:
					result.setTo( -col, -row );
					break;
				default:
					break;
			}
			return result;
		}
	}
}