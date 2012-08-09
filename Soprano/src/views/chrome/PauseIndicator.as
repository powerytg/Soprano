package views.chrome
{
	import flash.events.Event;
	
	import mx.core.UIComponent;
	
	public class PauseIndicator extends UIComponent
	{
		/**
		 * @private
		 */
		private var ring:PauseRing;
		
		/**
		 * Constructor
		 */
		public function PauseIndicator()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
		}
		
		/**
		 * @private
		 */
		override protected function measure():void{
			super.measure();
			measuredWidth = 159;
			measuredHeight = 162;
		}
		
		/**
		 * @private
		 */
		override protected function createChildren():void{
			super.createChildren();
			
			if(!ring){
				ring = new PauseRing();
				addChild(ring);				
			}
		}
		
		/**
		 * @private
		 */
		private function onAddedToStage(evt:Event):void{
			if(ring)
				ring.play();
		}
		
		/**
		 * @private
		 */
		private function onRemovedFromStage(evt:Event):void{
			if(ring)
				ring.stop();
		}
		
	}
}