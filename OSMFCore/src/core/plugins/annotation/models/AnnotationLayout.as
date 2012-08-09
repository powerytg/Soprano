package core.plugins.annotation.models
{
	public class AnnotationLayout
	{
		/**
		 * @public
		 */
		public static const TOP:String = "top";
		
		/**
		 * @public
		 */
		public static const BOTTOM:String = "bottom";
		
		/**
		 * @public
		 */
		public static const LEFT:String = "left";
		
		/**
		 * @public
		 */
		public static const RIGHT:String = "right";
		
		/**
		 * @public
		 * 
		 * Possible values are: LEFT and RIGHT
		 */
		public var horizontalAlign:String
		
		/**
		 * @public
		 * 
		 * Possible values are: TOP and BOTTOM
		 */
		public var verticalAlign:String;
		
		/**
		 * @public
		 * 
		 * Horizontal distance to edge
		 */
		public var horizontalPadding:Number;
		
		/**
		 * @public
		 * 
		 * Vertical distance to edge
		 */
		public var verticalPadding:Number;
		
		/**
		 * @public
		 */
		public var width:Number;

		/**
		 * @public
		 */
		public var height:Number;

		/**
		 * Constructor
		 */
		public function AnnotationLayout()
		{
		}
	}
}