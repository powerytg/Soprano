package core.plugins.tracking
{
	import core.plugins.tracking.elements.NativeTrackingProxyElement;
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaFactoryItemType;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.net.StreamingURLResource;
	
	public class NativeTrackingPluginInfo extends PluginInfo
	{
		/**
		 * @public
		 */
		public static var NS_NATIVE_TRACKING_ENABLED:String = "http://org/osmf/plugins/tracking/nativeTracking/nativeTrackingEnabled";
		
		/**
		 * Constructor
		 */
		public function NativeTrackingPluginInfo()
		{
			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			var item:MediaFactoryItem = new MediaFactoryItem("core.plugins.tracking.NativeTrackingPluginInfo",
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
			// Do not put on wrapper elements
			if(resource is StreamingURLResource){
				var streamResource:StreamingURLResource = resource as StreamingURLResource;
				if(streamResource.url.match(/(smil|f4m)$/) != null){
					trace("[NativeTrackingPlugin] Ignore SMIL/F4M wrapper: " + streamResource.url);
					return false;
				}
			}
			
			if(!resource.getMetadataValue(NS_NATIVE_TRACKING_ENABLED))
				return false;
			
			if((resource.getMetadataValue(NS_NATIVE_TRACKING_ENABLED) as Boolean) == false)
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
			return new NativeTrackingProxyElement();
		}		
	}
}