package core.plugins.ad.events
{
	import flash.events.Event;
	
	import core.plugins.ad.models.Ad;
	
	public class AdEvent extends Event
	{
		/**
		 * @public
		 */
		public static const STATE_CHANGE:String = "adStateChange";
		
		/**
		 * @public
		 */
		public static const AD_ACTIVATED:String = "adActivated";
		
		/**
		 * @public
		 */
		public static const AD_DEACTIVATED:String = "adDeactivated";
		
		/**
		 * @public
		 * 
		 * The change state, possible value is AD_ACTIVATED or AD_DEACTIVATED
		 */
		public var state:String;
		
		/**
		 * @public
		 * 
		 * A reference to the ad value object
		 */
		public var ad:Ad;
		
		/**
		 * Constructor
		 */
		public function AdEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
		 * @public
		 */
		override public function clone():Event{
			var evt:AdEvent = new AdEvent(STATE_CHANGE);
			evt.state = state;
			evt.ad = ad;
			
			return evt;
		}
	}
}