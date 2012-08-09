package core.events
{
	import flash.events.Event;
	
	public class TagEvent extends Event
	{
		/**
		 * @public
		 */
		public static const TAG_LIST_CHANGE:String = "tagListChange";
		
		/**
		 * Constructor
		 */
		public function TagEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}