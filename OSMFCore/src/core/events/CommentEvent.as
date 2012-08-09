package core.events
{
	import core.models.Clip;
	import core.models.Comment;
	
	import flash.events.Event;
	
	public class CommentEvent extends Event{
		
		/**
		 * @public
		 */
		public static const POST_SUCCESS:String = "commitSuccess";

		/**
		 * @public
		 */
		public static const POST_FAILED:String = "commitFailed";
		
		/**
		 * @public
		 */
		public static const COMMENT_RETRIEVED:String = "commentRetrieved";
		
		/**
		 * @public
		 */
		public var clip:Clip;
		
		/**
		 * @public
		 */
		public var page:Number;
		
		/**
		 * @public
		 */
		public var perPage:Number;
		
		/**
		 * @public
		 */
		public var numPages:Number;

		/**
		 * @public
		 */
		public var numItems:Number;

		/**
		 * @public
		 */
		public var comment:Comment;
		
		/**
		 * @public
		 */
		public var comments:Vector.<Comment>;

		/**
		 * Constructor
		 */
		public function CommentEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
	}
}