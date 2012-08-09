package core.controllers
{
	import core.env.Environment;
	import core.events.SearchEvent;
	import core.models.Brand;
	import core.models.CDN;
	import core.models.Clip;
	import core.models.Tag;
	import core.models.query.SearchEventPayload;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class ClipController extends EventDispatcher
	{
		/**
		 * @private
		 */
		private static var _clipController:ClipController;
		
		/**
		 * @public
		 */
		public static function get clipController():ClipController
		{
			return initialize();
		}
		
		/**
		 * @public
		 */
		public static function initialize():ClipController
		{
			if (_clipController == null){
				_clipController = new ClipController();
			}
			return _clipController;
		}
		
		/**
		 * Constructor
		 */
		public function ClipController()
		{
			super();
			if( _clipController != null ) throw new Error("Error:ClipController already initialised.");
			if( _clipController == null ) _clipController = this;
		}
		
		/**
		 * @public
		 */
		public function parseClipXml(clipXml:XML):Clip{
			var clip:Clip = new Clip();
			clip.id = String(clipXml.id);
			clip.name = String(clipXml.name);
			clip.duration = Number(clipXml.duration);
			clip.company = String(clipXml.company);
			clip.releaseDate = String(clipXml.release_date);
			clip.description = String(clipXml.description);
			clip.url = String(clipXml.url);
			clip.previewUrl = String(clipXml.preview_url);
			clip.hdPreviewUrl = String(clipXml.hd_preview_url);
			clip.allowComment = String(clipXml.allow_comment) == "true" ? true: false;
			clip.live = String(clipXml.live) == "true" ? true: false;
			clip.dvr = String(clipXml.dvr) == "true" ? true: false;
			
			// Get brand info (optional)
			var brands:XMLList = XMLList(clipXml.child("brand"));
			if(brands.children().length() != 0){
				var brand:Brand = new Brand();
				brand.id = String(brands.id);
				brand.name = String(brands[0].name[0]);
				clip.brand = brand;
			}
			
			// Get CDN info (required)
			clip.cdn = new CDN();
			clip.cdn.id = String(clipXml.cdn.id);
			clip.cdn.name = String(clipXml.cdn.name);
			
			// Get tags info (optional)
			clip.tags = new Vector.<Tag>();
			for each(var tagXml:XML in clipXml.tags.children()){
				var tag:Tag = new Tag();
				tag.id = String(tagXml.id);
				tag.name = String(tagXml.name);
				clip.tags.push(tag);
			}
			
			return clip;
		}
		
		/**
		 * @public
		 */
		public function parseClipXmlList(rawClipXml:XMLList):Array{
			var clips:Array = [];
			
			for each(var clipXml:XML in rawClipXml.children()){
				var clip:Clip = parseClipXml(clipXml);				
				clips.push(clip);				
			}
			
			return clips;
		}
	
		/**
		 * @public
		 */
		public function searchClip(page:Number = 1, itemsPerPage:Number = 9, keywords:String = "all", tag:Tag = null, year:Number = NaN, month:Number = NaN):EventDispatcher{
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
			service.url = Environment.serverUrl + "/clips.search.xml";
			service.resultFormat = "e4x";
			service.send(params);
			service.addEventListener(ResultEvent.RESULT, function(evt:ResultEvent):void{
				onSearchClipResult(evt.result, dispatcher);			
			});
			
			return dispatcher;
		}
		
		/**
		 * @private
		 */
		protected function onSearchClipResult(resultObject:Object, dispatcher:EventDispatcher):void{
			var result:XML = resultObject as XML;
			var keywords:String = String(result.query_term);
			var numPages:Number = Number(result.total_pages);
			var page:Number = Number(result.page);
			var itemsPerPage:Number = Number(result.per_page);
			var totalItems:Number = Number(result.total_items);
			var resultCollection:ArrayCollection = new ArrayCollection();
			
			// Parse result
			for each(var clipXml:XML in result.clips.children()){
				var clip:Clip = new Clip();
				clip.id = String(clipXml.id);
				clip.name = String(clipXml.name);
				clip.previewUrl = String(clipXml.preview_url);
				clip.duration = Number(clipXml.duration);
				
				resultCollection.addItem(clip);
			}
			
			// Fire up an event to update UI components
			var payload:SearchEventPayload = new SearchEventPayload();
			payload.result = resultCollection;
			payload.numPages = numPages;
			payload.totalItems = totalItems;
			
			var event:SearchEvent = new SearchEvent(SearchEvent.CLIP_SEARCH_RESULT);
			event.payload = payload;
			dispatcher.dispatchEvent(event);
		}
		
	}
}