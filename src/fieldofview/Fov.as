package fieldofview {

	/**
	 * Calculates the [Hero]'s field of view of the dungeon.
	 * @author
	 */
	public class Fov {
		public var tileData : TileData;

		private var _shadowLine : ShadowLine;

		public function Fov() {
		}

		public function setTiles( tiles : Vector.<Tile>, width : int, height : int ) : void {
			if ( tileData == null )
				tileData = new TileData();
			tileData.setTiles( tiles, width, height );
		}

		/**
		 * Updates the visible flags in [stage] given the [Hero]'s [pos].
		 * @param	pos
		 */
		public function refresh( pos : Vector2i, maxRows : int = 999 ) : void {
			for ( var octant : int = 0; octant < 8; octant++ ) {
				refreshOctant( pos, octant, maxRows );
			}

			// The starting position is always visible.
			tileData.getTile( pos.x, pos.y ).isVisible = true;
		}

		private static var _helpVec : Vector2i = new Vector2i();

		public function refreshOctant( start : Vector2i, octant : int, maxRows : int = 999 ) : Vector.<Shadow> {
			var line : ShadowLine = new ShadowLine();
			var fullShadow : Boolean = false;

			// Sweep through the rows ('rows' may be vertical or horizontal based on
			// the incrementors). Start at row 1 to skip the center position.
			for ( var row : int = 1; row < maxRows; row++ ) {
				// If we've gone out of bounds, bail.
				tileData.transformOctant( row, 0, octant, _helpVec );

				if ( !tileData.bounds.containsXY( start.x + _helpVec.x, start.y + _helpVec.y ))
					break;

				for ( var col : int = 0; col <= row; col++ ) {

					tileData.transformOctant( row, col, octant, _helpVec );

					var posx : int = start.x + _helpVec.x;
					var posy : int = start.y + _helpVec.y;

					// If we've traversed out of bounds, bail on this row.
					// note: this improves performance, but works on the assumption that
					// the starting tile of the FOV is in bounds.
					if ( !tileData.bounds.containsXY( posx, posy ))
						break;

					var tile : Tile = tileData.getTile( posx, posy );

					// If we know the entire row is in shadow, we don't need to be more
					// specific.
					if ( fullShadow ) {
						//如何已经可见，则不修改
						if ( !tile.isVisible )
							tile.isVisible = false;
					} else {

						var projection : Shadow = _projectTile( row, col );

						// Set the visibility of this tile.
						var visible : Boolean = !line.isInShadow( projection );

						//如何已经可见，则不修改
						if ( !tile.isVisible )
							tile.isVisible = visible;

						// Add any opaque tiles to the shadow map.
						if ( visible && tile.isWall ) {
							line.add( projection );
							fullShadow = line.isFullShadow;
						}
					}
				}
			}

			return line.shadows;
		}

		/**
		 * Creates a [Shadow] that corresponds to the projected silhouette of the
		 * given tile. This is used both to determine visibility (if any of the
		 * projection is visible, the tile is) and to add the tile to the shadow map.
		 *
		 * The maximal projection of a square is always from the two opposing
		 * corners. From the perspective of octant zero, we know the square is
		 * above and to the right of the viewpoint, so it will be the top left and
		 * bottom right corners.
		 */
		private function _projectTile( row : int, col : int ) : Shadow {
			// The top edge of row 0 is 2 wide.
			var topLeft : Number = col / ( row + 2 );

			// The bottom edge of row 0 is 1 wide.
			var bottomRight : Number = ( col + 1 ) / ( row + 1 );

			return new Shadow( topLeft, bottomRight,
				new Vector2i( col, row + 2 ), new Vector2i( col + 1, row + 1 ));
		}
	}

}
