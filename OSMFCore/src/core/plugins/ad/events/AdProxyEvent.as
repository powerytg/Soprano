package core.plugins.ad.events
{
	import core.models.Clip;
	import core.plugins.ad.models.Ad;
	
	import flash.events.Event;
	
	public class AdProxyEvent extends Event
	{
		/**
		 * @public
		 */
		public static const ORCHESTRATED:String = "adOrchestrated";
		
		/**
		 * @public
		 */
		public static const AD_LOADED:String = "adLoaded";

		/**
		 * @public
		 */
		public static const AD_LOAD_ERROR:String = "adLoadError";

		/**
		 * @public
		 */
		public var ad:Ad;
		
		/**
		 * @public
		 */
		public var clip:Clip;
		
		/**
		 * Consructor
		 */
		public function AdProxyEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}		
	}
}