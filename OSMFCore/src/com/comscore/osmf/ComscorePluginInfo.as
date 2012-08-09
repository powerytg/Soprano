package com.comscore.osmf {
	import __AS3__.vec.Vector;
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaFactoryItemType;
	import org.osmf.media.PluginInfo;
	import org.osmf.net.NetLoader;

	public class ComscorePluginInfo extends PluginInfo {
		public static const COMSCORE_METADATA_NAMESPACE:String = "http://www.comscore.com/osmf/1.0";
		
		public function ComscorePluginInfo() {
			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			
			var loader:NetLoader = new NetLoader();
			var item:MediaFactoryItem = new MediaFactoryItem("com.comscore.osmf.ComscorePluginInfo",
													loader.canHandleResource,
													createProxyElement,
													MediaFactoryItemType.PROXY);
			items.push(item);			
			super(items);
		}
		
		private function createProxyElement():MediaElement {
			return new ComscoreProxyElement();
		}
	}
}
