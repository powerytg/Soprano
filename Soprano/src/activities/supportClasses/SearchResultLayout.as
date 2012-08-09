package activities.supportClasses
{
	import mx.core.IVisualElement;
	
	import spark.layouts.supportClasses.LayoutBase;
	
	public class SearchResultLayout extends LayoutBase
	{
		/**
		 * @private
		 */
		private var padding:Number = 10;
		
		/**
		 * Constructor
		 */
		public function SearchResultLayout()
		{
			super();
		}
		
		/**
		 * @private
		 */
		override public function updateDisplayList(width:Number, height:Number):void{
			for(var i:uint = 0; i < target.numElements; i++){
				var e:IVisualElement = useVirtualLayout ? target.getVirtualElementAt( i ) :
					target.getElementAt( i );

				var xPosition:Number = (i % 2 == 0) ? padding : 172 + padding;
				var yPosition:Number = Math.floor(i / 2) * 102 + padding;
				
				e.setLayoutBoundsSize(NaN, NaN, false);				
				e.setLayoutBoundsPosition(xPosition, yPosition);
			}
			
			target.setContentSize(349, 311);
		}
		
	}
}