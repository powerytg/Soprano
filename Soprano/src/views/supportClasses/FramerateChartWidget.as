package views.supportClasses
{
	import spark.components.Label;
	
	import views.supportClasses.BaseChartWidget;
	import views.supportClasses.FramerateChartWidgetSkin;

	/**
	 * 
	 * 
	 * @author Nathan Weber
	 */
	public class FramerateChartWidget extends BaseChartWidget
	{
		//----------------------------------------
		//
		// Skin Parts
		//
		//----------------------------------------
		
		[SkinPart(required="false")]
		/**
		 *  The title label.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var titleText:Label;
		
		//----------------------------------------
		//
		// Public Methods
		//
		//----------------------------------------
		
		public override function reset():void{
			super.reset();
			titleText.text = '';
		}
		
		//----------------------------------------
		//
		// Internal Methods
		//
		//----------------------------------------
		
		/**
		 * @private 
		 */		
		override protected function generatePoint( time:Number ):Object {
			var p:Object = new Object();
			p.time = time;
			p.fps = metrics.currentFPS;
			
			setTitleText();
			
			return p;
		}
		
		private function setTitleText():void {
			if ( titleText ) {
				titleText.text = generateTitleText();
			}
		}
		
		/**
		 * Decides the text to be displayed as the title.
		 *  
		 * @return 
		 * 
		 * @private
		 * TODO : Move to skin?
		 */		
		protected function generateTitleText():String {
			return " Current Frame Rate (" + Math.floor( metrics.currentFPS ) + ") FPS";
		}
		
		//----------------------------------------
		//
		// Constructor
		//
		//----------------------------------------
		
		/**
		 * Constructor. 
		 */		
		public function FramerateChartWidget() {
			super();
			setStyle("skinClass", FramerateChartWidgetSkin);
		}
	}
}