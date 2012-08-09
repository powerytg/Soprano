package views.chrome
{
	import flash.events.Event;
	
	import mx.core.UIComponent;
	
	public class LoadingIndicator extends UIComponent
	{
		/**
		 * @private
		 */
		private var ring:LoadingRing;
		
		/**
		 * Constructor
		 */
		public function LoadingIndicator()
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
			measuredWidth = 185;
			measuredHeight = 180;
		}
		
		/**
		 * @private
		 */
		override protected function createChildren():void{
			super.createChildren();
			
			if(!ring){
				ring = new LoadingRing();
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