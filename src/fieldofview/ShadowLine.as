package fieldofview {

	public class ShadowLine {
		private var _shadows : Vector.<Shadow>;

		public function ShadowLine() {
			_shadows = new Vector.<Shadow>();
		}
		
		public function reset():void
		{
			_shadows.length = 0;
		}

		public function get shadows() : Vector.<Shadow> {
			return _shadows;
		}

		public function isInShadow( projection : Shadow ) : Boolean {
			for (var i:int = 0, len:int = _shadows.length; i < len;i++)
			{
				if ( _shadows[i].contains( projection ))
					return true;
			}
			return false;
		}

		/**
		 * Add [shadow] to the list of non-overlapping shadows. May merge one or more shadows.
		 * @param	shadow
		 */
		public function add( shadow : Shadow ) : void {
			var shadowLen:int = _shadows.length;
			// Figure out where to slot the new shadow in the sorted list.
			var index : int = 0;
			for ( ; index < shadowLen; index++ ) {
				//Stop when we hit the insertion point
				if ( _shadows[ index ].start >= shadow.start )
					break;
			}

			//The new shadow is going here. See if it overlaps the previous or next.
			var overlappingPrevious : Shadow;
			if ( index > 0 && _shadows[ index - 1 ].end > shadow.start ) {
				overlappingPrevious = _shadows[ index - 1 ];
			}

			var overlappingNext : Shadow;
			if ( index < shadowLen && _shadows[ index ].start < shadow.end ) {
				overlappingNext = _shadows[ index ];
			}

			//Insert and unify with overlapping shadows.
			if ( overlappingNext != null ) {
				if ( overlappingPrevious != null ) {
					//Overlaps both, so unify one and delete the other
					overlappingPrevious.end = overlappingNext.end;
					overlappingPrevious.endPos = overlappingNext.endPos;
					_shadows.splice( index, 1 );
				} else {
					//Only overlaps the next shadow,so unify it with that.
					overlappingNext.start = shadow.start;
					overlappingNext.startPos = shadow.startPos;
				}
			} else {
				if ( overlappingPrevious != null ) {
					//Only overlaps the previous shadow, so unify it with thas.
					overlappingPrevious.end = shadow.end;
					overlappingPrevious.endPos = shadow.endPos;
				} else {
					//Does not overlap anything,so insert.
					_shadows.splice( index, 0, shadow );
				}
			}
		}

		public function get isFullShadow() : Boolean {
			return _shadows.length == 1 && _shadows[ 0 ].start == 0 && _shadows[ 0 ].end == 1;
		}
	}

}
