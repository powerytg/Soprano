package core.models.sync
{
	import core.models.Clip;
	import core.models.Playlist;
	import core.models.Tag;
	
	import flash.events.EventDispatcher;
	
	/**
	 * Playlist selection change
	 */
	[Event(name="playlistChange", type="core.events.PlaylistEvent")]
	
	/**
	 * Tag collection change
	 */
	[Event(name="tagListChane", type="core.events.TagEvent")]
	
	public class Aggregator extends EventDispatcher
	{
		/**
		 * @public
		 */
		public var selectedPlaylist:Playlist;

		/**
		 * @public
		 */
		public var selectedClip:Clip;

		/**
		 * @public
		 */
		public var tags:Vector.<Tag>;
		
		/**
		 * @private
		 */
		private static var _aggregator:Aggregator;
		
		/**
		 * @private
		 */
		public static function get aggregator():Aggregator
		{
			return initialize();
		}
		
		/**
		 * @private
		 */
		public static function initialize():Aggregator
		{
			if (_aggregator == null){
				_aggregator = new Aggregator();
			}
			return _aggregator;
		}
		
		/**
		 * @constructor
		 */
		public function Aggregator()
		{
			super();
			if( _aggregator != null ) throw new Error("Error:Aggregator already initialised.");
			if( _aggregator == null ) _aggregator = this;
		}
		
	}
}