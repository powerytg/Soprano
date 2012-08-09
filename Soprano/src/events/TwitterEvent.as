package events
{
	import core.models.Tweet;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class TwitterEvent extends Event
	{
		/**
		 * @public
		 */
		public static const REQEUST_TOKEN_RETRIEVED:String = "requestTokenRetrieved";
		
		/**
		 * @public
		 */
		public static const SEARCH_RESULT:String = "twitterSearchResult";

		/**
		 * @public
		 */
		public static const STATUS_UPDATE_SUCCESS:String = "twitterStatusUpdated";

		/**
		 * @public
		 */
		public static const STATUS_UPDATE_FAILED:String = "twitterStatusUpdateFailed";

		/**
		 * @public
		 */
		public var page:Number;
		
		/**
		 * @public
		 */
		public var tweet:Tweet;
		
		/**
		 * @public
		 */
		public var tweets:ArrayCollection;
		
		/**
		 * Constructor
		 */
		public function TwitterEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}