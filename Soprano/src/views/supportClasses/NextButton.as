package views.supportClasses
{
	import spark.components.Button;
	
	public class NextButton extends Button
	{
		/**
		 * Constructor
		 */
		public function NextButton()
		{
			super();
			setStyle("skinClass", NextButtonSkin);
		}
		
		/**
		 * @private
		 */
		override protected function measure():void{
			measuredWidth = 73;
			measuredHeight = 105;
		}
	}
}