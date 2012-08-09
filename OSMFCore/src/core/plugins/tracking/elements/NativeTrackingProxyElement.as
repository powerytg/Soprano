package core.plugins.tracking.elements
{
	import core.env.Environment;
	import core.models.Clip;
	import core.plugins.tracking.models.NativeTrackingMetadata;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.TimelineMetadataEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.CuePoint;
	import org.osmf.metadata.CuePointType;
	import org.osmf.metadata.TimelineMetadata;
	
	public class NativeTrackingProxyElement extends ProxyElement
	{
		/**
		 * @protected
		 * 
		 * This timer is used to monitor the availability of proxiedElement. Will expire after that proxiedElement has been set
		 */
		protected var timer:Timer;

		/**
		 * @protected
		 * 
		 * A reference to the clip being tracked
		 */
		protected var clip:Clip;
		
		/**
		 * Constructor
		 */
		public function NativeTrackingProxyElement(proxiedElement:MediaElement=null)
		{
			super(proxiedElement);
			
			// Wait until proxiedElement is available
			timer = new Timer(100);
			timer.addEventListener(TimerEvent.TIMER, onWaitProxyAvailable);
			timer.start();						
		}
		
		/**
		 * @protected
		 * 
		 * Invoked every 100ms, just to check whether the proxied element is available. Expires right after that
		 */
		protected function onWaitProxyAvailable(evt:TimerEvent):void{
			if(proxiedElement != null){
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, onWaitProxyAvailable);
				
				// Grab necessary metadatas
				var metadata:NativeTrackingMetadata = getMetadata(NativeTrackingMetadata.NS_NATIVE_TRACKING_METADATA) as NativeTrackingMetadata;
				clip = metadata.clip;
				
				// Setup tracking beacons
				setupBeacons();
			}
		}		
		
		/**
		 * @protected
		 * 
		 * Setup tracking beacons
		 */
		protected function setupBeacons():void{
			// Try to grab the timeline
			var timeline:TimelineMetadata = proxiedElement.getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
			if(!timeline){
				timeline = new TimelineMetadata(proxiedElement);
				addMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE, timeline);
			}
			
			timeline.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onBeaconReached, false, 0, true);
			
			// Setup cue points
			for(var i:uint = 0; i < clip.numTrackingBeacons; i++){
				var beacon:CuePoint = new CuePoint(CuePointType.ACTIONSCRIPT, i * clip.nativeTrackingFrequency, "beacon" + i.toString(), null);
				timeline.addMarker(beacon);
			}
		}
		
		/**
		 * @protected
		 * 
		 * Invoked when a beacon is reached
		 */
		protected function onBeaconReached(evt:TimelineMetadataEvent):void{
			// Ignore if not a beacon
			if((evt.marker as CuePoint).name.match(/^beacon/) == null )
				return;
			
			// Fire a signal to the tracking server (and we don't care about the result at all)
			var request:URLRequest = new URLRequest(Environment.serverUrl + "/analysis.tracking.xml?clip_id=" + clip.id + "&time=" + Math.floor(evt.marker.time).toString());
			
			var loader:URLLoader = new URLLoader();
			loader.load(request);
			loader.addEventListener(Event.COMPLETE, onSuccess, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onFault, false, 0, true);
		}
		
		/**
		 * @private
		 */
		private function onSuccess(evt:Event):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			loader.removeEventListener(Event.COMPLETE, onSuccess);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onFault);
		}

		/**
		 * @private
		 */
		private function onFault(evt:Event):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			loader.removeEventListener(Event.COMPLETE, onSuccess);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onFault);
			
			trace("[NativeTrackingPlugin] beacon sending failed");
			trace(loader.data);
		}

	}
}