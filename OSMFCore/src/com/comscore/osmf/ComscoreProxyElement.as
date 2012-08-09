package com.comscore.osmf {
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.TimelineMetadata;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	public class ComscoreProxyElement extends ProxyElement {
		private var timer:Timer;
		
		public function ComscoreProxyElement(proxiedElement:MediaElement=null) {
			super(proxiedElement);
			
			timer = new Timer(100);
			timer.addEventListener(TimerEvent.TIMER, onWaitProxyAvailable);
			timer.start();			
		}
		
		private function onWaitProxyAvailable(evt:TimerEvent):void {
			if(proxiedElement != null){
				timer.stop();

				var mediaElement:MediaElement = super.proxiedElement;			
				var tempResource:MediaResourceBase = (mediaElement && mediaElement.resource != null) ? mediaElement.resource : resource;
				if (tempResource == null) { return; }
				
				var metadata:Metadata = tempResource.getMetadataValue(ComscorePluginInfo.COMSCORE_METADATA_NAMESPACE) as Metadata;
				
				if (metadata == null) { return; }	
								
				beacon(metadata.getValue("c1"), 
						metadata.getValue("c2"), 
						metadata.getValue("c3"), 
						metadata.getValue("c4"), 
						metadata.getValue("c5"), 
						metadata.getValue("c6"));
			}
		}
		
		protected function beacon(c1:String, c2:String, c3:String, c4:String, c5:String, c6:String):String {
			var page:String = "", referrer:String = "", title:String = "";

			try {
				page = ExternalInterface.call("function() { return document.location.href; }").toString();
				referrer = ExternalInterface.call("function() { return document.referrer; }").toString();
				title = ExternalInterface.call("function() { return document.title; }").toString();	
				
				if (typeof(page) == "undefined" || page == "null") { page = ""; };
				if (typeof(referrer) == "undefined" || referrer == "null") { referrer = ""; }
				if (typeof(title) == "undefined" || title == "null") { title = ""; }
			
				if (page != null && page.length > 512) { page = page.substr(0, 512); }
				if (referrer.length > 512) { referrer = referrer.substr(0, 512); }
			} 
			catch (e:Error) {
				trace(e);				
			}
			
			var p:Function = function(s:String):String {
				if (s == null || s == "null") return "";
				return escape(s);
			}
				
			var url:String = (new Array(
				page.indexOf("https:") == 0 ? "https://sb" : "http://b",
				".scorecardresearch.com/p",
				"?c1=", c1, 
				"&c2=", p(c2), 
				"&c3=", p(c3), 
				"&c4=", p(c4), 
				"&c5=", p(c5), 
				"&c6=", p(c6), 
				"&c7=", p(page), 
				"&c8=", p(title), 
				"&c9=", p(referrer),
				"&rn=", Math.random(),
				"&cv=1.0"
			)).join("");
						
			if (url.length > 2080) { url = url.substr(0, 2080); }
						
			var loader:URLLoader = new URLLoader();
			loader.load(new URLRequest(url));
							
			trace(url);				
			return url;
		}
	}
}
