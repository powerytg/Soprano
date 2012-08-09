package core.controllers
{
	import core.events.ChainEvent;
	import core.utils.ChainAction;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	public class ChainController extends EventDispatcher
	{
		/**
		 * @protected
		 */
		protected var chain:Vector.<ChainAction> = new Vector.<ChainAction>();
		
		/**
		 * @public
		 */
		protected var results:Dictionary = new Dictionary(true);
		
		/**
		 * Constructor
		 */
		public function ChainController()
		{
			super();
		}
				
		/**
		 * @public
		 */
		public function register(action:ChainAction):ChainAction{
			action.addEventListener(ChainEvent.ACTION_COMPLETE, onActionComplete, false, 0, true);
			chain.push(action);
			
			return action;
		}
		
		/**
		 * @public
		 * 
		 * Execute the chain sequentially
		 */
		public function run():void{
			if(chain.length == 0){
				var evt:ChainEvent = new ChainEvent(ChainEvent.CHAIN_COMPLETE);
				dispatchEvent(evt);
				return;
			}
			
			// Get an action from the chain and run it
			var action:ChainAction = chain.shift() as ChainAction;
			action.run();
		}
		
		/**
		 * @public
		 */
		public function onActionComplete(evt:ChainEvent):void{
			// Push the result into the results collection
			evt.action.removeEventListener(ChainEvent.ACTION_COMPLETE, onActionComplete);
			results[evt.action.uri] = evt.action.result;
			
			if(chain.length == 0){
				var evt:ChainEvent = new ChainEvent(ChainEvent.CHAIN_COMPLETE);
				dispatchEvent(evt);
				return;
			}
			
			// Run the next task
			run();
		}
		
		/**
		 * @public
		 */
		public function getResult(uri:String):Object{
			return results[uri];
		}
		
	}
}