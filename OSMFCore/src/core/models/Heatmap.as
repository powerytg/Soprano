package  core.models
{
	import flash.events.EventDispatcher;
	
	public class Heatmap extends EventDispatcher
	{
		/**
		 * @public
		 */
		public var entries:Vector.<HeatmapEntry> = new Vector.<HeatmapEntry>();
		
		/**
		 * Constructor
		 */
		public function Heatmap()
		{
			super();
		}
	}
}