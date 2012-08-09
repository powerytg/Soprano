package core.controllers
{
	import core.env.Environment;
	import core.events.AnalysisEvent;
	import core.models.Clip;
	import core.models.HeatmapEntry;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	
	public class AnalysisController extends EventDispatcher
	{
		/**
		 * @public
		 */
		public var clip:Clip;
		
		/**
		 * Constructor
		 */
		public function AnalysisController()
		{
			super();
		}
		
		/**
		 * @public
		 */
		public function getHeatmap():void{
			var request:URLRequest = new URLRequest(Environment.serverUrl + "/analysis.heatmap.xml?clip_id=" + clip.id);
			var loader:URLLoader = new URLLoader();
			
			loader.addEventListener(Event.COMPLETE, onHeatmapRetrieved, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onHeatmapFault, false, 0, true);
			loader.load(request);
		}
		
		/**
		 * @private
		 */
		protected function onHeatmapRetrieved(evt:Event):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			var result:XML = XML(loader.data);
			
			loader.removeEventListener(Event.COMPLETE, onHeatmapRetrieved);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onHeatmapFault);
			
			var heatmap:Vector.<HeatmapEntry> = new Vector.<HeatmapEntry>();
			for each(var heatmapXml:XML in result.heatmap.children()){
				var entry:HeatmapEntry = new HeatmapEntry();
				entry.time = Number(heatmapXml.time);
				entry.hits = Number(heatmapXml.hits);
				heatmap.push(entry);
			}
			
			var e:AnalysisEvent = new AnalysisEvent(AnalysisEvent.HEATMAP_RETRIEVED);
			e.clip = clip;
			e.heatmap = heatmap; 
			dispatchEvent(e);
		}
		
		/**
		 * @private
		 */
		protected function onHeatmapFault(evt:Event):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			
			loader.removeEventListener(Event.COMPLETE, onHeatmapRetrieved);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onHeatmapFault);
			
			trace("[Analysis] Getting heatmap failed");
			trace(loader.data);
			
			dispatchEvent(new AnalysisEvent(AnalysisEvent.HEATMAP_FAILED));
		}
	}
}