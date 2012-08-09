package core.controllers
{
	import core.env.Environment;
	import core.events.TagEvent;
	import core.models.Tag;
	import core.models.sync.Aggregator;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class TagController extends EventDispatcher
	{
		
		/**
		 * @private
		 */
		private static var _tagController:TagController;
		
		/**
		 * @private
		 */
		public static function get tagController():TagController
		{
			return initialize();
		}
		
		/**
		 * @private
		 */
		public static function initialize():TagController
		{
			if (_tagController == null){
				_tagController = new TagController();
			}
			return _tagController;
		}
		
		/**
		 * Constructor
		 */
		public function TagController()
		{
			super();
			if( _tagController != null ) throw new Error("Error:TagController already initialised.");
			if( _tagController == null ) _tagController = this;
		}
		
		/**
		 * @public
		 */
		public function getAllTags():void{
			var request:URLRequest = new URLRequest();
			request.url = Environment.serverUrl + "/tags.list.xml";
			
			var loader:URLLoader = new URLLoader();
			loader.load(request);

			loader.addEventListener(Event.COMPLETE, onGetAllTagsComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onGetAllTagsError);
		}
		
		/**
		 * @private
		 */
		private function onGetAllTagsError(evt:IOErrorEvent):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			loader.removeEventListener(Event.COMPLETE, onGetAllTagsComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onGetAllTagsError);
			
			trace("[TagController] retrieving tags failed");
		}
		
		/**
		 * @private
		 */
		private function onGetAllTagsComplete(evt:Event):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			loader.removeEventListener(Event.COMPLETE, onGetAllTagsComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onGetAllTagsError);

			var result:XML = XML(loader.data);
			Aggregator.aggregator.tags = new Vector.<Tag>();
			
			// Add the rest of the entries from XML
			for each(var tagXml:XML in result.tags.children()){
				var tag:Tag = new Tag();
				tag.id = String(tagXml.id);
				tag.name = String(tagXml.name);
				tag.numClips = Number(tagXml.num_clips);
				
				Aggregator.aggregator.tags.push(tag);
			}
			
			Aggregator.aggregator.dispatchEvent(new TagEvent(TagEvent.TAG_LIST_CHANGE));
		}
	
	}
}