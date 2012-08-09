package core.plugins.ad
{
	import core.plugins.ad.elements.AdProxyElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaFactoryItemType;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.media.URLResource;
	import org.osmf.net.DynamicStreamingResource;
	
	public class AdPluginInfo extends PluginInfo
	{
		/**
		 * @public
		 */
		public static const NS_AD_ENABLED:String = "http://osmf.org/plugins/ad/adplugin/adEnabled";

		/**
		 * Constructor
		 */
		public function AdPluginInfo()
		{
			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			var item:MediaFactoryItem = new MediaFactoryItem("core.plugins.ad.AdPluginInfo",
															 canHandleResourceCallBack,
															 createMediaElementCallBack,
															 MediaFactoryItemType.PROXY);
			items.push(item);
			
			super(items);
		}
		
		/**
		 * @protected
		 * 
		 * Determines whether the plugin can handle the resource or not
		 */
		protected function canHandleResourceCallBack(resource:MediaResourceBase):Boolean{
			if(!resource)
				return false;
			
			if(!resource.getMetadataValue(NS_AD_ENABLED))
				return false;
			
			if(resource is DynamicStreamingResource)
				return false;
			
			if((resource.getMetadataValue(NS_AD_ENABLED) as Boolean) == false)
				return false;
			else{
				
				return true;
			}
		}
		
		/**
		 * @protected
		 * 
		 * Hijack the passed-in media element, and return an orchstrated proxy element that has ads mixed-in
		 */
		protected function createMediaElementCallBack():MediaElement{
			return new AdProxyElement();
		}
	}
}