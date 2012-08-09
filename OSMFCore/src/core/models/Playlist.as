package core.models
{
	import mx.collections.ArrayCollection;

	/**
	 * The playlist container includes many clips (of type Clip).
	 * Additionally, it gets instructions from the server to determine whether to enable
	 * ads or banners
	 */
	public class Playlist extends ModelBase
	{
		/**
		 * @public
		 */
		public var name:String;
		
		/**
		 * @public
		 */
		public var creationDate:String;
		
		/**
		 * @public
		 * 
		 * Possible values: "normal", "long", "none"
		 */
		public var adAvailability:String;
		
		/**
		 * @public
		 * 
		 * The playlist container
		 */
		public var clips:Vector.<Clip>;
		
		/**
		 * @public
		 */
		public var numClips:Number;
		
		/**
		 * @public
		 */
		public var previewUrl:String;
		
		/**
		 * @public
		 */
		public var useLongAd:Boolean = false;
		
		/**
		 * Constructor
		 */
		public function Playlist()
		{
			super();
		}
		
	}
}