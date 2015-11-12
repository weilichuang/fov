package fieldofview {

	/**
	 * ...
	 * @author
	 */
	public class Vector2i {
		public var x : int;
		public var y : int;

		public function Vector2i( x : int=0, y : int=0 ) {
			this.x = x;
			this.y = y;
		}
		
		public function setTo(x:int,y:int):void
		{
			this.x = x;
			this.y = y;
		}
		
		public function copyFrom(other:Vector2i):void
		{
			this.x = other.x;
			this.y = other.y;
		}
		
		public function equals(other:Vector2i):Boolean
		{
			return this.x == other.x && this.y == other.y;
		}
		
		public function clone():Vector2i
		{
			return new Vector2i(x,y);
		}

		public function add( other : Vector2i ) : Vector2i {
			return new Vector2i( this.x + other.x, this.y + other.y );
		}

	}

}
