package core.plugins.tracking.models
{
	import core.models.Clip;

	public class NativeTrackingMetadataFactory
	{
		/**
		 * Constructor
		 */
		public function NativeTrackingMetadataFactory()
		{
		}
		
		/**
		 * Produce a NativeTrackingMetadata object
		 */
		public static function createMetadata(clip:Clip):NativeTrackingMetadata{
			var nativeTrackingMetadata:NativeTrackingMetadata = new NativeTrackingMetadata();
			nativeTrackingMetadata.clip = clip;
			
			return nativeTrackingMetadata;
		}
	}
}