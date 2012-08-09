package core.events
{
	import flash.events.Event;
	
	public class MobilePolicyEvent extends Event
	{
		/**
		 * @public
		 */
		public static const POLICY_CHANGE:String = "policyChange";
		
		/**
		 * @public
		 */
		public var policy:String;
		
		/**
		 * @public
		 */
		public var value:Object;
		
		/**
		 * Constructor
		 */
		public function MobilePolicyEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}