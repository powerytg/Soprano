package activities.supportClasses
{
	import activities.skins.SearchButtonSkin;
	
	import spark.components.Button;
	
	public class SearchButton extends Button
	{
		/**
		 * Constructor
		 */
		public function SearchButton()
		{
			super();
			setStyle("skinClass", SearchButtonSkin );
		}
		
		/**
		 * @protected
		 */
		override protected function measure():void{
			super.measure();
			measuredWidth = 397;
			measuredHeight = 124;
		}
	}
}