package core.events
{
	import core.models.query.QueryCondition;
	import core.models.query.SearchEventPayload;
	
	import flash.events.Event;
	
	public class SearchEvent extends Event
	{
		/**
		 * @public
		 */
		public static const PLAYLIST_SEARCH_RESULT:String = "playlistSearchResult";

		/**
		 * @public
		 */
		public static const CLIP_SEARCH_RESULT:String = "clipSearchResult";

		/**
		 * @public
		 */
		public static const RESOURCE_SEARCH_RESULT:String = "resourceSearchResult";

		/**
		 * @public
		 */
		public static const CONDITION_CHANGE:String = "conditionChange";
		
		/**
		 * @public
		 */
		public var payload:SearchEventPayload;
		
		/**
		 * @public
		 */
		public var condition:QueryCondition;
		
		/**
		 * Constructor
		 */
		public function SearchEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}