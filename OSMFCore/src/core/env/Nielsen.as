package core.env
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class Nielsen extends EventDispatcher
	{
		/**
		 * Singleton class
		 */
		public function Nielsen(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}