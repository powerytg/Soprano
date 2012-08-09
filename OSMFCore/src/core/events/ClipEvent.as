package core.events
{
	import core.models.Clip;
	
	import flash.events.Event;
	
	public class ClipEvent extends Event
	{
		/**
		 * @public
		 */
		public static const CLIP_CHANGE:String = "clipSelectionChange";
		
		/**
		 * @public
		 */
		public var selectedClip:Clip;
		
		/**
		 * Constructor
		 */
		public function ClipEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}