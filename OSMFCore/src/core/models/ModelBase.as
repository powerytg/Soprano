package core.models
{
	import flash.events.EventDispatcher;
	
	/**
	 * Base of all consumable models
	 */
	public class ModelBase extends EventDispatcher
	{
		/**
		 * @public
		 */
		public var id:String;
		
		/**
		 * Constructor
		 */
		public function ModelBase()
		{
			super(null);
		}
	}
}