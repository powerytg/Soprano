package core.plugins.annotation.models
{
	import core.models.ModelBase;
	
	import org.osmf.metadata.CuePoint;

	public class Annotation extends ModelBase
	{
		/**
		 * @public
		 */
		public var content:String;
		
		/**
		 * @public
		 */
		public var layout:AnnotationLayout = new AnnotationLayout();

		/**
		 * @public
		 */
		public var cuePoint:CuePoint;
		
		/**
		 * @public
		 */
		public var duration:Number;
		
		/**
		 * Constructor
		 */
		public function Annotation()
		{
			super();
		}
	}
}