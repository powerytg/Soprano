package core.events
{
	import flash.events.Event;

	/**
	 * The CoreEvent class defines the most important OSMF-related events
	 */
	public class CoreEvent extends Event
	{
		public static const EXTERNAL_PLUGIN_LOADED:String = "externalPluginLoaded";
		public static const EXTERNAL_PLUGIN_FAILED:String = "externalPluginFailed";
		public static const OSMF_READY:String = "osmfReady";
		public static const PLAYLIST_LOADED:String = "playlistLoaded";
		
		/**
		 * Constructor
		 */
		public function CoreEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}