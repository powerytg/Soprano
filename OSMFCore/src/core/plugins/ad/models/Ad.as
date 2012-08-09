package core.plugins.ad.models
{
	import core.models.ModelBase;
	
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.CuePoint;
	import org.osmf.vast.loader.VASTLoadTrait;
	
	public class Ad extends ModelBase
	{
		/**
		 * @public
		 */
		public var name:String;
		
		/**
		 * @public
		 */
		public var url:String;
		
		/**
		 * @public
		 */
		public var vastType:String;
		
		/**
		 * @public
		 */
		public var duration:Number;
		
		/**
		 * @public
		 */
		public var cuePoint:CuePoint;
		
		/**
		 * @public
		 */
		public var media:MediaElement;
		
		/**
		 * @public
		 */
		public var active:Boolean = true;
		
		/**
		 * @public
		 */
		public var loaded:Boolean = false;
		
		/**
		 * @public
		 */
		public var vastLoadTrait:VASTLoadTrait;
		
		/**
		 * Constructor
		 */
		public function Ad()
		{
			super();
		}
	}
}