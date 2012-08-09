package core.utils
{
	import core.events.ChainEvent;
	
	import flash.events.EventDispatcher;
	
	public class ChainAction extends EventDispatcher
	{
		/**
		 * @public
		 * 
		 * What to execute
		 */
		public var method:Function;
		
		/**
		 * @public
		 */
		public var params:Object;
		
		/**
		 * @public
		 * 
		 * the unique identifier
		 */
		public var uri:String;
		
		/**
		 * @public
		 */
		public var result:Object;
		
		/**
		 * Constructor
		 */
		public function ChainAction(_uri:String, _method:Function, _params:Object = null)
		{
			super();
			
			this.uri = _uri;
			method = _method;
			
			if(_params)
				params = _params;
		}
		
		/**
		 * @public
		 */
		public function run():void{
			if(params)
				method(params);
			else
				method();
		}
		
		/**
		 * @public
		 */
		public function complete(returnValue:Object = null):void{
			if(returnValue)
				result = returnValue;
			
			var evt:ChainEvent = new ChainEvent(ChainEvent.ACTION_COMPLETE);
			evt.action = this;
			dispatchEvent(evt);
		}
	}
}