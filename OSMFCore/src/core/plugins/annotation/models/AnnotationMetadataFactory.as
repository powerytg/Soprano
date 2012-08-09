package core.plugins.annotation.models
{
	import core.models.Clip;
	
	public class AnnotationMetadataFactory
	{
		/**
		 * Constructor
		 */
		public function AnnotationMetadataFactory()
		{
		}
		
		/**
		 * Produce a CommentMetadataFactory object
		 */
		public static function createMetadata(clip:Clip):AnnotationMetadata{
			var metadata:AnnotationMetadata = new AnnotationMetadata(); 
			metadata.clip = clip;
			
			return metadata;
		}
	}
}