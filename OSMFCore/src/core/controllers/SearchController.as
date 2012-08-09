package core.controllers
{
	import core.env.Environment;
	import core.events.SearchEvent;
	import core.models.Clip;
	import core.models.Playlist;
	import core.models.Tag;
	import core.models.query.SearchEventPayload;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;


	public class SearchController extends EventDispatcher
	{
		/**
		 * @private
		 */
		private static var _searchController:SearchController;
		
		/**
		 * @private
		 */
		public static function get searchController():SearchController
		{
			return initialize();
		}
		
		/**
		 * @private
		 */
		public static function initialize():SearchController
		{
			if (_searchController == null){
				_searchController = new SearchController();
			}
			return _searchController;
		}
		
		/**
		 * @constructor
		 */
		public function SearchController()
		{
			super();
			if( _searchController != null ) throw new Error("Error:SearchController already initialised.");
			if( _searchController == null ) _searchController = this;
		}
		
		/**
		 * @public
		 */
		public function searchResource(page:Number = 1, itemsPerPage:Number = 9, keywords:String = "all", tag:Tag = null, year:Number = NaN, month:Number = NaN):EventDispatcher{
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
			service.url = Environment.serverUrl + "/playlists.search_resource.xml";
			service.resultFormat = "e4x";
			service.send(params);
			service.addEventListener(ResultEvent.RESULT, function(evt:ResultEvent):void{
				onSearchResourceResult(evt.result, dispatcher);			
			});
			
			return dispatcher;
		}
		
		/**
		 * @private
		 */
		protected function onSearchResourceResult(resultObject:Object, dispatcher:EventDispatcher):void{
			var result:XML = resultObject as XML;
			var keywords:String = String(result.query_term);
			var numPages:Number = Number(result.total_pages);
			var page:Number = Number(result.page);
			var itemsPerPage:Number = Number(result.per_page);
			var totalItems:Number = Number(result.total_items);
			var resultCollection:ArrayCollection = new ArrayCollection();
			
			// Parse result
			for each(var resourceXml:XML in result.result.children()){
				if(resourceXml.duration.children().length() > 0){
					var clip:Clip = new Clip();
					clip.id = String(resourceXml.id);
					clip.name = String(resourceXml.name);
					clip.previewUrl = String(resourceXml.preview_url);
					
					resultCollection.addItem(clip);					
				}
				else{
					var playlist:Playlist = new Playlist();
					playlist.id = String(resourceXml.id);
					playlist.numClips = Number(resourceXml.num_clips);
					playlist.previewUrl = String(resourceXml.preview_url);
					
					resultCollection.addItem(playlist);
				}
			}
			
			// Fire up an event to update UI components
			var payload:SearchEventPayload = new SearchEventPayload();
			payload.result = resultCollection;
			payload.numPages = numPages;
			payload.totalItems = totalItems;
			
			var event:SearchEvent = new SearchEvent(SearchEvent.RESOURCE_SEARCH_RESULT);
			event.payload = payload;
			dispatcher.dispatchEvent(event);
		}
	}
}