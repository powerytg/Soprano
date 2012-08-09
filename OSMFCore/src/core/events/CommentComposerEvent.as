package core.events
{
	import flash.events.Event;
	
	public class CommentComposerEvent extends Event{
		/**
		 * @public
		 */
		public static var SUCCESS:String = "commitSuccess";

		/**
		 * @public
		 */
		public static var FAILED:String = "commitFailed";
		
		/**
		 * Constructor
		 */
		public function CommentComposerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
	}
}