package activities
{
	import flash.events.EventDispatcher;
	
	import frameworks.slim.activity.ActivityDeck;
	
	public class ActivityManager extends EventDispatcher
	{
		/**
		 * @public
		 */
		public var featuredActivity:FeaturedActivity = new FeaturedActivity();
		
		/**
		 * @public
		 */
		public var playlistDetailsActivity:PlaylistDetailsActivity = new PlaylistDetailsActivity();
		
		/**
		 * @public
		 */
		public var searchActivity:SearchActivity = new SearchActivity();
		
		/**
		 * @public
		 */
		public var tagActivity:TagActivity = new TagActivity();
		
		/**
		 * @public
		 */
		public var activityDeck:ActivityDeck = new ActivityDeck();
		
		/**
		 * @private
		 */
		private static var _activityManager:ActivityManager;
		
		/**
		 * @private
		 */
		public static function get activityManager():ActivityManager
		{
			return initialize();
		}
		
		/**
		 * @private
		 */
		public static function initialize():ActivityManager
		{
			if (_activityManager == null){
				_activityManager = new ActivityManager();
			}
			return _activityManager;
		}
		
		/**
		 * @constructor
		 */
		public function ActivityManager()
		{
			super();
			if( _activityManager != null ) throw new Error("Error:ActivityManager already initialised.");
			if( _activityManager == null ) _activityManager = this;
		}
	}
}