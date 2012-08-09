package core.events
{
	import core.plugins.ad.models.Ad;
	
	import flash.events.Event;
	
	public class AdModeEvent extends Event
	{
		/**
		 * @public
		 */
		public static const NEED_TO_CHOOSE_AD_MODE:String = "needToChooseAdMode";
		
		/**
		 * @public
		 */
		public var longAd:Ad;
		
		/**
		 * Constructor
		 */
		public function AdModeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}