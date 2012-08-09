package core.env
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class EmbedPolicy extends EventDispatcher
	{
		/**
		 * @public
		 */
		public static var availableSize:Array = [{width: 512, height: 288}, {width: 720, height: 423}];
		
		/**
		 * Constructor
		 */
		public function EmbedPolicy(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}