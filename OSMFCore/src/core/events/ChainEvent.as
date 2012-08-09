package core.events
{
	import core.utils.ChainAction;
	
	import flash.events.Event;
	
	public class ChainEvent extends Event
	{
		/**
		 * @public
		 */
		public static const ACTION_COMPLETE:String = "actionComplete";
		
		/**
		 * @public
		 */
		public static const CHAIN_COMPLETE:String = "chainComplete";
		
		/**
		 * @public
		 */
		public var action:ChainAction;
		
		/**
		 * Constructor
		 */
		public function ChainEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}