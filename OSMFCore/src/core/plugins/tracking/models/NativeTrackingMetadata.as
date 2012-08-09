package core.plugins.tracking.models
{
	import core.models.Clip;
	
	import org.osmf.metadata.Metadata;
	
	public class NativeTrackingMetadata extends Metadata
	{
		/**
		 * @public
		 * 
		 * Namespace
		 */
		public static const NS_NATIVE_TRACKING_METADATA:String = "nativeTrackingMetadata";
		
		/**
		 * @public
		 * 
		 * A reference to the clip
		 */
		public var clip:Clip;
				
		/**
		 * Constructor
		 */
		public function NativeTrackingMetadata()
		{
			super();
		}
	}
}