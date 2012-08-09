package core.plugins.annotation.events
{
	import core.plugins.annotation.models.Annotation;
	
	import flash.events.Event;
	
	public class AnnotationEvent extends Event
	{
		/**
		 * @public
		 */
		public static const CUE_POINT_REACHED:String = "cuePointReached";

		/**
		 * @public
		 */
		public static const CUE_POINT_EXPIRED:String = "cuePointExpired";
		
		/**
		 * @public
		 */
		public var currentAnnotation:Annotation;
		
		/**
		 * Constructor
		 */
		public function AnnotationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}