package core.env
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class SearchPolicy extends EventDispatcher
	{
		/**
		 * How many items per page
		 */
		public static var numItemsPerPage:Number = 9;
		
		/**
		 * Constructor
		 */
		public function SearchPolicy(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}