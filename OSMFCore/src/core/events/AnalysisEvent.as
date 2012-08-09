package core.events
{
	import core.models.Clip;
	import core.models.HeatmapEntry;
	
	import flash.events.Event;
	
	public class AnalysisEvent extends Event
	{
		/**
		 * @public
		 */
		public static const HEATMAP_FAILED:String = "heatmapFailed";

		/**
		 * @public
		 */
		public static const HEATMAP_RETRIEVED:String = "heatmapRetrieved";

		/**
		 * @public
		 */
		public var clip:Clip;
		
		/**
		 * @public
		 */
		public var heatmap:Vector.<HeatmapEntry>;
		
		/**
		 * Constructor
		 */
		public function AnalysisEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}