package core.plugins.ad.events
{
	import flash.events.Event;
	
	import org.osmf.media.MediaElement;
	
	public class DurationProxyElementEvent extends Event
	{
		/**
		 * @public
		 */
		public static const TIME_UP:String = "adTimeUp";
		
		/**
		 * Constructor
		 */
		public function DurationProxyElementEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}