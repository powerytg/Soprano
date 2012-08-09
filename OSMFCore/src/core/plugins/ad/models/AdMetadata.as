package core.plugins.ad.models
{
	import core.models.Clip;
	
	import flash.events.EventDispatcher;
	
	import org.osmf.metadata.Metadata;
	
	public class AdMetadata extends Metadata
	{
		/**
		 * @public
		 */
		public static const NS_AD_METADATA:String = "http://osmf.org/plugins/ad/adplugin/adMetadata";
		
		/**
		 * @public
		 */
		public var useLongAd:Boolean = false;
		
		/**
		 * @public
		 */
		public var liveAdInterval:Number;
		
		/**
		 * @public
		 */
		public var clip:Clip
		
		/**
		 * Constructor
		 */
		public function AdMetadata()
		{
			super();
		}
	}
}