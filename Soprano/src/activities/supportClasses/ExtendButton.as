package activities.supportClasses
{
	import activities.skins.ExtendButtonSkin;
	
	import spark.components.Button;
	
	public class ExtendButton extends Button
	{
		/**
		 * Constructor
		 */
		public function ExtendButton()
		{
			super();
			setStyle("skinClass", ExtendButtonSkin );
		}
		
		/**
		 * @protected
		 */
		override protected function measure():void{
			super.measure();
			measuredWidth = 111;
			measuredHeight = 111;
		}
	}
}