package core.events
{
	import core.models.Clip;
	import core.models.Playlist;
	
	import flash.events.Event;
	
	public class PlaylistEvent extends Event
	{
		/**
		 * @public
		 * 
		 * Invoked when user selected a playlist
		 */
		static public const PLAYLIST_CHANGE:String = "playlistChange";

		/**
		 * @public
		 * 
		 * Invoked when user selected an entry in the playlist
		 */
		static public const PLAYLIST_SELECTION_CHANGE:String = "playlistSelectionChange";
		
		/**
		 * @public
		 * 
		 * Invoked when the current playing clip changed
		 */
		static public const CURRENT_CLIP_CHANGE:String = "currentClipChange";
		
		/**
		 * @public
		 * 
		 * Invoked when the current clip is buffering
		 */
		static public const SHOW_LOADING_SCREEN:String = "showLoadingScreen";
		
		/**
		 * @public
		 * 
		 * Invoked when the current clip finishes buffering
		 */
		static public const REMOVE_LOADING_SCREEN:String = "removeLoadingScreen";
		
		/**
		 * @public
		 */
		static public const PLAYLIST_LOADED:String = "playlistLoaded";
		
		/**
		 * @public
		 * 
		 * Selected playlist entry
		 */
		public var selectedItem:Clip;

		/**
		 * @public
		 */
		public var selectedPlaylist:Playlist;
		
		/**
		 * Constructor
		 */
		public function PlaylistEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}