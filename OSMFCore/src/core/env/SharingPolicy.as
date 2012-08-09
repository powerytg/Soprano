package core.env
{
	import core.models.Clip;
	
	import flash.events.EventDispatcher;

	public class SharingPolicy extends EventDispatcher
	{
		/**
		 * Constructor
		 */
		public function SharingPolicy()
		{
			super(null);
		}
		
		/**
		 * @public
		 * 
		 * Determine whether we could allow sharing a clip with start/end offset
		 */
		public static function isTimelineAvailable(clip:Clip):Boolean{
			if(clip.live || clip.dvr)
				return false;
			
			if(clip.streaming)
				return true;
			
			return false;
		}
		
	}
}