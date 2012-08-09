package core.plugins.annotation
{
	import core.plugins.annotation.elements.AnnotationProxyElement;
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaFactoryItemType;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.net.DynamicStreamingResource;
	
	public class AnnotationPluginInfo extends PluginInfo
	{
		/**
		 * @public
		 */
		public static const NS_ANNOTATION_ENABLED:String = "http://osmf.org/plugins/annotation/annotationPlugin/annotationEnabled";
		
		/**
		 * Constructor
		 */
		public function AnnotationPluginInfo()
		{
			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			var item:MediaFactoryItem = new MediaFactoryItem("core.plugins.annotation.AnnotationPluginInfo",
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
			
			if(!resource.getMetadataValue(NS_ANNOTATION_ENABLED))
				return false;
			
			if(resource is DynamicStreamingResource)
				return false;
			
			if((resource.getMetadataValue(NS_ANNOTATION_ENABLED) as Boolean) == false)
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
			return new AnnotationProxyElement();
		}
	}
}