package core.env
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class Comscore extends EventDispatcher
	{
		/**
		 * Namespace used by ExternalController class
		 */
		public static const COMSCORE_NAMESPACE:String = "http://www.comscore.com";
		
		// The following are ComScore specified tags
		public static const c1:int = 1;
		public static const c2:String = "8056073";
		public static const c3:String = "8056073";
		public static const c4:String = "8056073";
		public static const c5:String = "020200";
		public static const c6:String = "Demo"; 
		
		/**
		 * Singleton class
		 */
		public function Comscore(target:IEventDispatcher=null)
		{
			super(target);
			throw(new Error("This class is not to be instanized."));
		}
		
		
	}
}