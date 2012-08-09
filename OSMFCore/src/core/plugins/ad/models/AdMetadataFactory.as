package core.plugins.ad.models
{
	import core.env.Environment;
	import core.models.Clip;

	/**
	 * A factory for populating necessary metadata for the ad plugin
	 */
	public class AdMetadataFactory
	{
		/**
		 * Constructor
		 */
		public function AdMetadataFactory()
		{
		}
		
		/**
		 * Produce an AdMetadata
		 */
		public static function createMetadata(clip:Clip, useLongAd:Boolean):AdMetadata{
			var metadata:AdMetadata = new AdMetadata();
			metadata.clip = clip;
			metadata.useLongAd = useLongAd;

			return metadata;
		}
	}
}