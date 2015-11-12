package fieldofview {

	/**
	 * ...
	 * @author
	 */
	public class Tile {

		public var x : int;
		public var y : int;
		public var isWall : Boolean = false;
		private var _isVisible : Boolean = false;
		private var _isExplored:Boolean = false;

		public function Tile() {

		}
		
		public function get isVisible():Boolean
		{
			return _isVisible;
		}
		
		public function set isVisible(value:Boolean):void
		{
			_isVisible = value;
			if(value)
				_isExplored = true;
		}
		
		public function get isExplored():Boolean
		{
			return _isExplored;
		}

	}

}
