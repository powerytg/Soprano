package polkit.events
{
	import flash.events.Event;
	
	import polkit.Policy;
	
	public class PolicyKitEvent extends Event
	{
		/**
		 * @public
		 */
		public static const POLICY_CHANGE:String = "policyChange";
		
		/**
		 * @public
		 */
		public var policy:Policy;

		/**
		 * @public
		 */
		public var oldValue:Object;

		/**
		 * @public
		 */
		public var newValue:Object;

		/**
		 * Constructor
		 */
		public function PolicyKitEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}