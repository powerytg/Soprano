package core.plugins.ad.utils
{
	import core.plugins.ad.models.Ad;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.osmf.metadata.CuePoint;
	import org.osmf.metadata.CuePointType;
	import org.osmf.vast.media.VASTMediaGenerator;
	
	public class AdFactory extends EventDispatcher
	{
		/**
		 * Constructor
		 */
		public function AdFactory(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		/**
		 * @public
		 */
		public static function createAd(adXml:XML, index:Number):Ad{
			var ad:Ad = new Ad();
			ad.id = String(adXml.id);
			ad.name = String(adXml.name);
			ad.url = unescape(String(adXml.url));
			ad.vastType = String(adXml.vast_type) == "linear" ? VASTMediaGenerator.PLACEMENT_LINEAR : VASTMediaGenerator.PLACEMENT_NONLINEAR;
			
			var cuePointTime:Number = Number(adXml.cue_point);
			ad.cuePoint = new CuePoint(CuePointType.ACTIONSCRIPT, cuePointTime, "adPoint" + index.toString(), null);		
			
			return ad;
		}
		
	}
}