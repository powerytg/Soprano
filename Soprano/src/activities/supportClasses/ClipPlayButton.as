package activities.supportClasses
{
	import activities.skins.ClipPlayButtonSkin;
	
	import spark.components.Button;
	
	public class ClipPlayButton extends Button
	{
		/**
		 * Constructor
		 */
		public function ClipPlayButton()
		{
			super();
			setStyle("skinClass", ClipPlayButtonSkin );
		}
		
		/**
		 * @protected
		 */
		override protected function measure():void{
			super.measure();
			measuredWidth = 61;
			measuredHeight = 61;
		}
	}
}