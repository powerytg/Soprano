package core.models
{
	import flash.events.EventDispatcher;
	
	public class HeatmapEntry extends EventDispatcher
	{
		/**
		 * @public
		 */
		public var time:Number;
		
		/**
		 * @public
		 */
		public var hits:Number;			
		
		/**
		 * Constructor
		 */
		public function HeatmapEntry()
		{
			super();
		}
	}
}