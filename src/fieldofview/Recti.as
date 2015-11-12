package fieldofview {

	/**
	 * ...
	 * @author
	 */
	public class Recti {
		public var x : int;
		public var y : int;
		public var width : int;
		public var height : int;

		public function Recti() {

		}

		public function contains( other : Vector2i ) : Boolean {
			if ( other.x < this.x )
				return false;
			if ( other.x >= this.x + this.width )
				return false;
			if ( other.y < this.y )
				return false;
			if ( other.y >= this.y + this.height )
				return false;

			return true;
		}
		
		public function containsXY( px:int,py:int ) : Boolean {
			if ( px < this.x )
				return false;
			if ( px >= this.x + this.width )
				return false;
			if ( py < this.y )
				return false;
			if ( py >= this.y + this.height )
				return false;
			
			return true;
		}
	}

}
