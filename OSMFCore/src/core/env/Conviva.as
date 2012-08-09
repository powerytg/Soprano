package core.env
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class Conviva extends EventDispatcher
	{
		/**
		 * @public
		 */
		public static const serverUrl:String = "http://livepass.conviva.com/";

		/**
		 * @public
		 */
		public static const pluginUrl:String = "http://livepassdl.conviva.com/OSMF/ConvivaOSMFPlugin-1.0.16313.swf";
		
		/**
		 * @public
		 */
		public static const customerId:String = "c3.Adobe";
		
		/**
		 * @public
		 */
		public static const CONVIVA_NAMESPACE:String = "http://www.conviva.com"; 
		
		/**
		 * Constructor
		 */
		public function Conviva(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}