package core.controllers
{
	import core.env.Environment;
	import core.events.PlaylistEvent;
	import core.events.SearchEvent;
	import core.models.Clip;
	import core.models.Playlist;
	import core.models.Tag;
	import core.models.query.SearchEventPayload;
	import core.models.sync.Aggregator;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	
	public class PlaylistController extends EventDispatcher
	{
		/**
		 * @private
		 */
		private static var _playlistController:PlaylistController;
		
		/**
		 * @private
		 */
		public static function get playlistController():PlaylistController
		{
			return initialize();
		}
		
		/**
		 * @public
		 */
		public static function initialize():PlaylistController
		{
			if (_playlistController == null){
				_playlistController = new PlaylistController();
			}
			return _playlistController;
		}
		
		/**
		 * Constructor
		 */
		public function PlaylistController()
		{
			super();
			if( _playlistController != null ) throw new Error("Error:PlaylistController already initialised.");
			if( _playlistController == null ) _playlistController = this;
		}
		
		/**
		 * @public
		 */
		public function searchPlaylist(page:Number = 1, itemsPerPage:Number = 9, keywords:String = "all", tag:Tag = null, year:Number = NaN, month:Number = NaN):EventDispatcher{
			var params:Object = new Object();
			params.page = page == 0 ? 1 : page;
			params.per_page = itemsPerPage;
			params.keywords = keywords;
			
			if(!isNaN(year))
				params.year = year;
			
			if(!isNaN(month))
				params.month = month;
			
			if(tag)
				params.tag = tag.id;
			
			var dispatcher:EventDispatcher = new EventDispatcher();
			var service:HTTPService = new HTTPService();
			service.url = Environment.serverUrl + "/playlists.search.xml";
			service.resultFormat = "e4x";
			service.send(params);
			service.addEventListener(ResultEvent.RESULT, function(evt:ResultEvent):void{
				onSearchPlaylistResult(evt.result, dispatcher);			
			});
			
			return dispatcher;
		}
		
		/**
		 * @private
		 */
		protected function onSearchPlaylistResult(resultObject:Object, dispatcher:EventDispatcher):void{
			var result:XML = resultObject as XML;
			var keywords:String = String(result.query_term);
			var numPages:Number = Number(result.total_pages);
			var page:Number = Number(result.page);
			var itemsPerPage:Number = Number(result.per_page);
			var totalItems:Number = Number(result.total_items);
			var resultCollection:ArrayCollection = new ArrayCollection();
			
			// Parse playlists
			for each(var playlistXml:XML in result.playlists.children()){
				// Fetch the entry from allPlaylists, or create a new one to fit in
				var id:String = String(playlistXml.id);
				var	playlist:Playlist = new Playlist();
				playlist.id = id;
				playlist.name = String(playlistXml.name);
				playlist.numClips = Number(playlistXml.num_clips);
				playlist.previewUrl = String(playlistXml.preview_url);					
				
				resultCollection.addItem(playlist);
			}
			
			// Fire up an event to update UI components
			var payload:SearchEventPayload = new SearchEventPayload();
			payload.result = resultCollection;
			payload.numPages = numPages;
			payload.totalItems = totalItems;
			
			var event:SearchEvent = new SearchEvent(SearchEvent.PLAYLIST_SEARCH_RESULT);
			event.payload = payload;
			dispatcher.dispatchEvent(event);
		}
		
		/**
		 * @public
		 */
		public function getPlaylist(playlist:Playlist):void{
			var params:Object = new Object();
			params.id = playlist.id;
			
			var service:HTTPService = new HTTPService();
			service.url = Environment.serverUrl + "/playlists.get.xml";
			service.resultFormat = "e4x";
			service.addEventListener(ResultEvent.RESULT, onGetPlaylistResult);
			service.send(params);
		}
		
		/**
		 * @private
		 */
		protected function onGetPlaylistResult(evt:ResultEvent):void{
			var result:XML = XML(evt.result);
			
			var playlistId:String = String(result.id);
			var playlist:Playlist = Aggregator.aggregator.selectedPlaylist;
			
			// Since the name and id of the playlist is already there (see getAllPlaylist()), 
			// all we need to do is to fill the rest of the information
			playlist.clips = new Vector.<Clip>();			
			playlist.numClips = result.clips.children().length();
			playlist.creationDate = String(result.creation_date);
			
			// Parse clips
			var clips:Array = ClipController.clipController.parseClipXmlList(result.clips);
			for each(var clip:Clip in clips){
				playlist.clips.push(clip);
			}
			
			// Send an event
			var event:PlaylistEvent = new PlaylistEvent(PlaylistEvent.PLAYLIST_LOADED);
			event.selectedPlaylist = playlist;
			Aggregator.aggregator.dispatchEvent(event);
		}
		
	}
}