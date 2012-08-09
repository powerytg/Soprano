package core.utils
{
	import core.models.Brand;
	import core.models.CDN;
	import core.models.Clip;
	import core.models.Playlist;
	import core.models.Tag;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * The ModelFactory class takes a model XML(coming from server), parse it and 
	 * create an model object out of it
	 */
	public class ModelFactory extends EventDispatcher
	{
		/**
		 * Constructor
		 */
		public function ModelFactory(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		/**
		 * @public
		 */
		public static function createPlayList(src:XML):Playlist{
			var playlist:Playlist = new Playlist();
			
			// Get playlist info
			playlist.id = String(src.id);
			playlist.name = String(src.name);
			playlist.adAvailability = String(src.ad_availability);
			
			// Get clips
			playlist.clips = new Vector.<Clip>();
			for each(var clipXml:XML in src.clips.children()){
				var clip:Clip = createClip(clipXml);
				playlist.clips.push(clip);
			}			
			
			return playlist;
		}
		
		/**
		 * @public
		 */
		public static function createClip(clipXml:XML):Clip{
			var clip:Clip = new Clip();
			
			// Basic
			clip.id = String(clipXml.id);
			clip.url = String(clipXml.url);
			clip.name = String(clipXml.name);
			clip.previewUrl = String(clipXml.preview_url);
			clip.hdPreviewUrl = String(clipXml.hd_preview_url);
			clip.startTime = Number(clipXml.start_time);
			clip.endTime = Number(clipXml.end_time);
			clip.fullDuration = Number(clipXml.duration);
			clip.streaming = String(clipXml.streaming) == "true" ? true : false;
			clip.live = String(clipXml.live) == "true" ? true : false;
			clip.dvr = String(clipXml.dvr) == "true" ? true : false;
			
			// Plugin specific
			clip.allowComment = String(clipXml.allow_comment) == "true" ? true : false;
			clip.numTrackingBeacons = Number(clipXml.num_tracking_beacons);
			clip.nativeTrackingFrequency = Math.floor(Number(clipXml.tracking_frequency));
			clip.liveAdInterval = Number(clipXml.live_ad_interval);
			
			// Determine duration
			if(clip.streaming && !isNaN(clip.startTime) && !isNaN(clip.endTime)) 
				clip.duration = clip.endTime - clip.startTime;
			else
				clip.duration = clip.fullDuration;
			
			// Additional
			clip.company = String(clipXml.company);
			clip.releaseDate = String(clipXml.release_date);
			clip.description = String(clipXml.description);			
			
			// Get brand info (optional)
			if(clipXml.child("brand")){
				clip.brand = createBrand(XML(clipXml.brand));
			}
			
			// Get CDN info (mandatory)
			clip.cdn = createCDN(XML(clipXml.cdn));
			
			// Get tags info (optional)
			clip.tags = new Vector.<Tag>();
			for each(var tagXml:XML in clipXml.tags.children()){ 
				var tag:Tag = createTag(tagXml);
				clip.tags.push(tag);
			}
			
			return clip;
		}
		
		/**
		 * @public
		 */
		public static function createBrand(brandXml:XML):Brand{
			var brand:Brand = new Brand();
			brand.id = String(brandXml.id);
			brand.name = String(brandXml.name);
			
			return brand;
		}
		
		/**
		 * @public
		 */
		public static function createCDN(cdnXml:XML):CDN{
			var cdn:CDN = new CDN();
			cdn.id = String(cdnXml.id);
			cdn.name = String(cdnXml.name);
			
			return cdn;
		}
		
		/**
		 * @public
		 */
		public static function createTag(tagXml:XML):Tag{
			var tag:Tag = new Tag();
			tag.id = String(tagXml.id);
			tag.name = String(tagXml.name);
			
			return tag;
		}
		
	}
}