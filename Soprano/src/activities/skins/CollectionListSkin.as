package activities.skins
{
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	
	import frameworks.slim.skins.ListSkin;
	
	import spark.primitives.BitmapImage;
	
	public class CollectionListSkin extends ListSkin
	{
		/**
		 * @public
		 */
		[Embed(source="../images/OneItemBackground.png")]
		private static var columnFace:Class;

		/**
		 * @private
		 */
		private var columnImage:Bitmap = new columnFace();
		
		/**
		 * Constructor
		 */
		public function CollectionListSkin()
		{
			super();
		}
		
		/**
		 * @private
		 */
		override protected function createChildren():void{
			super.createChildren();
		}
	
		/**
		 * @private
		 */
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void{
			var m:Matrix = new Matrix();
			m.translate(11, 0);
			graphics.clear();
			graphics.beginBitmapFill(columnImage.bitmapData, m, false);
			graphics.drawRect(11, 0, 79, unscaledHeight);
			graphics.endFill();
		}
		
		/**
		 *  @private 
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{   
			graphics.clear();
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// Scroller. Leave 80px from bottom so that the search button does
			// not cause trouble for content below
			setElementSize(scroller, unscaledWidth, unscaledHeight - 80);
			setElementPosition(scroller, 0, 0);
		}
	}
}