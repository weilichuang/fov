package fieldofview {

	/**
	 * Represents the 1D projection of a 2D shadow onto a normalized line. In
	 * other words, a range from 0.0 to 1.0.
	 * @author
	 */
	public class Shadow {
		public var start : Number;
		public var end : Number;

		public var startPos : Vector2i;
		public var endPos : Vector2i;

		public function Shadow( start : Number, end : Number, startPos : Vector2i, endPos : Vector2i ) {
			this.start = start;
			this.end = end;
			this.startPos = startPos;
			this.endPos = endPos;
		}

		public function contains( other : Shadow ) : Boolean {
			return start <= other.start && end >= other.end;
		}

	}

}
