package core.plugins.annotation.models
{
	import core.models.Clip;
	
	import flash.events.EventDispatcher;
	
	import org.osmf.metadata.Metadata;
	
	public class AnnotationMetadata extends Metadata
	{
		/**
		 * @public
		 */
		public static const NS_ANNOTATION_METADATA:String = "http://osmf.org/plugins/annotation/annotationplugin/annotationMetadata";
		
		/**
		 * @public
		 */
		public var clip:Clip;

		/**
		 * Constructor
		 */
		public function AnnotationMetadata()
		{
			super();
		}
	}
}