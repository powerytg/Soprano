package activities.playbackActivities.events
{
	import flash.events.Event;
	
	public class MenuNavigatorEvent extends Event
	{
		/**
		 * @public
		 */
		public static const HORIZONTAL_SCROLL_POSITION_CHANGE:String = "horizontalScrollPositionChange";
		
		/**
		 * @public
		 */
		public static const HORIZONTAL_SCROLL_BEGIN:String = "horizontalScrollBegin";

		/**
		 * @public
		 */
		public static const HORIZONTAL_SCROLL_END:String = "horizontalScrollEnd";

		/**
		 * @public
		 */
		public static const VIEW_CHANGE:String = "viewChange";
		
		/**
		 * @public
		 */
		public var selectedViewIndex:Number;
		
		/**
		 * @public
		 */
		public var horizontalScrollPercentage:Number;
		
		/**
		 * Constructor
		 */
		public function MenuNavigatorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}