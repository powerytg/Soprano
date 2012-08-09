package views.supportClasses
{
	import spark.skins.mobile.ButtonSkin;
	
	public class NextButtonSkin extends ButtonSkin
	{
		/**
		 * Up skin
		 */
		[Embed(source="../images/Next.png")]
		protected var upFace:Class;
		
		/**
		 * Down skin
		 */
		[Embed(source="../images/NextDown.png")]
		protected var downFace:Class;
		
		/**
		 * Constructor
		 */
		public function NextButtonSkin()
		{
			super();
			upBorderSkin = upFace;
			downBorderSkin = downFace;
		}
		
		/**
		 * @private
		 */
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			// Draw nothing
		}
	}
}