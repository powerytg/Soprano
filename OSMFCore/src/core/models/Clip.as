package core.models
{
	import core.plugins.ad.models.Ad;
	import core.plugins.annotation.models.Annotation;
	
	import org.osmf.media.MediaElement;
	import org.osmf.net.StreamingURLResource;
	
	/**
	 * Defines a video clip (or a live stream)
	 */
	public class Clip extends ModelBase
	{
		///////////////////////////////////
		//
		// Essential properties
		//
		///////////////////////////////////
		
		/**
		 * @public
		 * 
		 * The title of the clip
		 */
		public var name:String;
		
		/**
		 * @public
		 */
		public var url:String;
		
		/**
		 * @public
		 */
		public var previewUrl:String;

		/**
		 * @public
		 */
		public var hdPreviewUrl:String;

		/**
		 * @public
		 */
		public var streaming:Boolean;
		
		/**
		 * @public
		 */
		public var live:Boolean;
		
		/**
		 * @public
		 */
		public var dvr:Boolean;
		
		/**
		 * @public
		 * 
		 * Unit: seconds
		 */ 
		public var duration:Number;
		
		/**
		 * @public
		 */
		public var fullDuration:Number;
		
		/**
		 * @public
		 */
		public var startTime:Number;
		
		/**
		 * @public
		 */
		public var endTime:Number;
		
		/**
		 * @public
		 */
		public var orchestrated:Boolean = false;
		
		///////////////////////////////////
		//
		// Additional properties
		//
		///////////////////////////////////

		/**
		 * @public
		 */
		public var brand:Brand;

		/**
		 * @public
		 */
		public var cdn:CDN;

		/**
		 * @public
		 * 
		 * A clip could have more than one tags
		 */
		public var tags:Vector.<Tag>;

		/**
		 * @public
		 */
		public var releaseDate:String;
		
		/**
		 * @public
		 */
		public var company:String;
		
		/**
		 * @public
		 */
		public var description:String;

		///////////////////////////////////
		//
		// Plugin specific properties
		//
		///////////////////////////////////
		
		/**
		 * @public
		 */
		public var allowComment:Boolean;

		/**
		 * @public
		 * 
		 * Number of tracking beacons, if nativeTracking is enabled
		 */
		public var numTrackingBeacons:Number;
		
		/**
		 * @public
		 * 
		 * Frequency of tracking beacons, if nativeTracking is enabled
		 */
		public var nativeTrackingFrequency:int;

		/**
		 * @public
		 */
		public var liveAdInterval:Number;
		
		/**
		 * @public
		 */
		public var numHits:Number;

		/**
		 * @public
		 */
		public var comments:Vector.<Comment>;
		
		/**
		 * @public
		 */
		public var ads:Vector.<Ad>;

		/**
		 * @public
		 */
		public var annotations:Vector.<Annotation>;
		
		///////////////////////////////////
		//
		// Quality specific
		//
		///////////////////////////////////
		/**
		 * @public
		 * 
		 * these bitrates will get overriden unless surpassDefaultQualityPolicy is true
		 */
		public var bitrates:Array = [];
		
		///////////////////////////////////
		//
		// OSMF attachment
		//
		///////////////////////////////////

		/**
		 * @public
		 * 
		 * A reference to the media element
		 */
		public var mediaElement:MediaElement;

		/**
		 * @public
		 */
		public var resource:StreamingURLResource;
		
		/**
		 * Constructor
		 */
		public function Clip()
		{
			super();
		}
		
	}
}