package core.controllers
{
	import core.env.AnalysisPolicy;
	import core.events.MetricsEvent;
	import core.models.videoMetrics.VideoMetrics;
	import core.plugins.ad.events.AdEvent;
	
	import flash.events.EventDispatcher;
	import flash.net.NetStream;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.traits.MediaTraitType;
	
	public class MetricsController extends EventDispatcher
	{
		/**
		 * @private
		 */
		public var metrics:VideoMetrics;
		
		/**
		 * @private
		 */
		private static var _metricsController:MetricsController;
		
		/**
		 * @private
		 */
		public static function get metricsController():MetricsController
		{
			return initialize();
		}
		
		/**
		 * @private
		 */
		public static function initialize():MetricsController
		{
			if (_metricsController == null){
				_metricsController = new MetricsController();
			}
			return _metricsController;
		}
		
		/**
		 * @constructor
		 */
		public function MetricsController()
		{
			super();
			if( _metricsController != null ) throw new Error("Error:MetricsController already initialised.");
			if( _metricsController == null ) _metricsController = this;
			
			setupListeners();
		}
		
		/**
		 * @private
		 */
		private function setupListeners():void{
			mediaPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange);
			
			OSMFController.osmfController.addEventListener(AdEvent.STATE_CHANGE, onAdStateChange);
		}
		
		/**
		 * Sets up the video metrics. 
		 */	
		public function createMetrics():void {
			if(metrics || !AnalysisPolicy.ENABLE_VIDEO_METRICS)
				return;
			
			metrics = new VideoMetrics( mediaPlayer, netStream );				
			
			var evt:MetricsEvent = new MetricsEvent(MetricsEvent.READY);
			evt.metrics = metrics;
			dispatchEvent(evt);
		}
		
		/**
		 * @private
		 */
		private function get mediaPlayer():MediaPlayer{
			return OSMFController.osmfController.player;
		}
		
		/**
		 * @public
		 */
		private function get mediaElement():MediaElement{
			return mediaPlayer? mediaPlayer.media : null;
		}
		
		/**
		 * @private
		 */
		private function resource():StreamingURLResource {
			return OSMFController.osmfController.currentClip.resource;
		}
		
		/**
		 * @private
		 */
		private function get netStream():NetStream
		{ 
			if( mediaElement ) {
				var loadTrait:NetStreamLoadTrait = mediaElement.getTrait( MediaTraitType.LOAD ) as NetStreamLoadTrait;
				if( loadTrait ) {
					return loadTrait.netStream;
				}
				else {
					return null;
				}
			}
			else {
				return null;
			}
		}
		
		/**
		 * @private
		 */
		protected function onMediaPlayerStateChange( event:MediaPlayerStateChangeEvent ):void {
			switch( event.state ) {
				case MediaPlayerState.READY:
					onMediaPlayerReady();
					break;
				case MediaPlayerState.PLAYING:
					onMediaPlayerPlaying();
					break;
				case MediaPlayerState.UNINITIALIZED:
					onMediaPlayerUninitialized();
					break;
				case MediaPlayerState.PAUSED:
					onMediaPlayerPaused();
					break;
			}
		}
		
		/**
		 * @private
		 */
		private function onAdStateChange(evt:AdEvent):void{
			if(evt.state == AdEvent.AD_ACTIVATED){
				if(metrics){
					metrics.stopMetrics();
					metrics = null;
				}			
			}
			else if(evt.state == AdEvent.AD_DEACTIVATED){
				createMetrics();
			}
		}
		
		/**
		 * @private
		 */
		protected function onMediaPlayerReady():void {
			createMetrics();
			updateMetricsCapabilities();
		}
		
		/**
		 * @private
		 */
		protected function onMediaPlayerPlaying():void {
			createMetrics();
			metrics.startMetrics();
		}
		
		/**
		 * @private
		 */
		protected function onMediaPlayerUninitialized():void {
			if(metrics){
				metrics.stopMetrics();
				metrics = null;
			}			
		}
		
		/**
		 * @private
		 */
		protected function onMediaPlayerPaused():void {
			if(metrics)
				metrics.stopMetrics();			
		}
		
		/**
		 * @private
		 */
		protected function updateMetricsCapabilities():void{
			if(metrics != null && resource != null)
				metrics.calculateBitrateMetrics = resource.hasOwnProperty("streamItems") && resource["streamItems"].length > 1;
			else
				metrics.calculateBitrateMetrics = false;
		}
	}
}