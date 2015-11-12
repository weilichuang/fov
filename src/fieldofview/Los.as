package fieldofview {

	/**
	 * Line-of-sight object for tracing a straight line from a [start] to [end]
	 * and determining which intermediate tiles are touched.
	 */
	public class Los {
		public var first : Vector2i;
		public var last : Vector2i;

		private var current : Vector2i;
		private var primaryIncrement : Vector2i;
		private var secondaryIncrement : Vector2i;

		private var error : int;
		private var primary : int;
		private var secondary : int;

		public function Los( first : Vector2i, last : Vector2i ) {
			this.first = first;
			this.last = last;

			var delta : Vector2i = new Vector2i( 0, 0 );
			delta.x = last.x - first.x;
			delta.y = last.y - first.y;

			// Figure which octant the line is in and increment appropriately.
			if ( delta.x > 0 ) {
				primaryIncrement = new Vector2i( 1, 0 );
			} else if ( delta.x == 0 ) {
				primaryIncrement = new Vector2i( 0, 0 );
			} else {
				primaryIncrement = new Vector2i( -1, 0 );
			}

			if ( delta.y > 0 ) {
				secondaryIncrement = new Vector2i( 0, 1 );
			} else if ( delta.y == 0 ) {
				secondaryIncrement = new Vector2i( 0, 0 );
			} else {
				secondaryIncrement = new Vector2i( 0, -1 );
			}

			// Discard the signs now that they are accounted for.
			delta.x = Math.abs( delta.x );
			delta.y = Math.abs( delta.y );

			// Assume moving horizontally each step.
			primary = delta.x;
			secondary = delta.y;

			// Swap the order if the y magnitude is greater.
			if ( delta.y > delta.x ) {
				var temp : int = primary;
				primary = secondary;
				secondary = temp;

				var temp2 : Vector2i = primaryIncrement;
				primaryIncrement = secondaryIncrement;
				secondaryIncrement = temp2;
			}

			current = first.clone();
			error = 0;
		}

		public function next() : Vector2i {
			current.x += primaryIncrement.x;
			current.y += primaryIncrement.y;

			// See if we need to step in the secondary direction.
			error += secondary;
			if ( error * 2 >= primary ) {
				current.x += secondaryIncrement.x;
				current.y += secondaryIncrement.y;
				error -= primary;
			}

			return current;
		}
	}
}
