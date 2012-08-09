package core.events
{
	import core.models.videoMetrics.VideoMetrics;
	
	import flash.events.Event;
	
	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class MetricsEvent extends Event
	{
		//----------------------------------------
		//
		// Constants
		//
		//----------------------------------------
		
		/**
		 * Dispatched when metrics have been updated. 
		 */		
		public static const UPDATE:String = 'metricsUpdate';
		
		/**
		 * @public
		 */
		public static const READY:String = "metricsReady";
		
		/**
		 * @public
		 */
		public var metrics:VideoMetrics;
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		/**
		 * Constructor.
		 *  
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 */		
		public function MetricsEvent( type:String, bubbles:Boolean=false, cancelable:Boolean=false ) {
			super( type, bubbles, cancelable );
		}
	}
}