package core.controllers
{
	import com.comscore.osmf.ComscorePluginInfo;
	
	import core.env.*;
	import core.events.*;
	import core.models.*;
	import core.plugins.ad.*;
	import core.plugins.ad.events.*;
	import core.plugins.ad.models.*;
	import core.plugins.annotation.*;
	import core.plugins.annotation.models.AnnotationMetadata;
	import core.plugins.annotation.models.AnnotationMetadataFactory;
	import core.plugins.tracking.*;
	import core.plugins.tracking.models.*;
	import core.utils.ComscoreMetadataFactory;
	import core.utils.ConvivaMetadataFactory;
	import core.utils.ModelFactory;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.DRMEvent;
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.net.StreamType;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.traits.DRMState;
	import org.osmf.traits.DRMTrait;
	import org.osmf.traits.MediaTraitType;
	
	/**
	 * OSMfController handles initializing, loading, orchestrating playlist/clip resources
	 * as well as their playback, quality and other properties
	 */
	public class OSMFController extends EventDispatcher
	{
		/**
		 * @public
		 * 
		 * OSMF MediaPlayer controller
		 **/
		public var player:MediaPlayer = new MediaPlayer();
		
		/**
		 * @public
		 * 
		 * The current playlist.
		 */
		public var playlist:Playlist;
		
		/**
		 * @private
		 * 
		 * The OSMF MediaContainer object. Since OSMF is pure ActionScript based, this "container" cannot be
		 * used in Flex directly. Instead it must be wrapped into a Flex container with extra layout mechanism.
		 * 
		 */
		public var mediaContainer:MediaContainer = new MediaContainer();
		
		/**
		 * @private
		 * 
		 * The default OSMF media factory
		 */
		protected var factory:DefaultMediaFactory;
		
		/**
		 * @public
		 * 
		 * The current playing clip
		 */
		public var currentClip:Clip;
		
		/**
		 * @public
		 */
		public var currentBitrate:Number;
		
		/**
		 * @private
		 * 
		 * The PluginController is used to handle loading of plugins
		 */
		protected var pluginController:PluginController;
		
		/**
		 * @private
		 * 
		 * Singleton instance
		 */
		private static var _osmfController:OSMFController;
		
		/**
		 * @private
		 */
		public static function get osmfController():OSMFController
		{
			return initialize();
		}
		
		/**
		 * @private
		 */
		public static function initialize():OSMFController
		{
			if (_osmfController == null){
				_osmfController = new OSMFController();
			}
			return _osmfController;
		}
		
		/**
		 * Constructor
		 */
		public function OSMFController()
		{
			super();
			if( _osmfController != null ) throw new Error("Error: OSMFController already initialised.");
			if( _osmfController == null ) _osmfController = this;
		}
		
		/**
		 * @public
		 * 
		 * Bootstrap is the first step of initialization
		 */
		public function bootstrap():void{
			// Create a media player
			player.addEventListener(DRMEvent.DRM_STATE_CHANGE, onDRMStateChange, false, 0, true);
			player.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onPlayerStateChange, false, 0, true);
			
			// Initilize the media factory
			factory = new DefaultMediaFactory();
			
			// Setup listeners
			installListeners();
			
			// Load plugins. When loading is complete, PluginController will dispatch a CoreEvent.EXTERNAL_PLUGIN_LOADED
			// When we got that, we could continue to load playlists
			pluginController = new PluginController(factory);
			pluginController.addEventListener(CoreEvent.EXTERNAL_PLUGIN_LOADED, onExternalPluginLoaded, false, 0, true);
			pluginController.executeLoad();
		}
		
		/**
		 * @private
		 * 
		 * CoreEvent.OSMF_READY is dispatched after successfully loading all of the plugins. Loading of playlists must wait for this event.
		 * 
		 */
		private function onExternalPluginLoaded(evt:CoreEvent):void{
			pluginController.removeEventListener(CoreEvent.EXTERNAL_PLUGIN_LOADED, onExternalPluginLoaded);
			dispatchEvent(new CoreEvent(CoreEvent.OSMF_READY));
		}
		
		/**
		 * @public
		 * 
		 * Setup event listeners. Events may come from a wide range of objects, including plugins
		 */
		public function installListeners():void{
			// Automatically move on to the next clip if the current one has reached its end
			player.addEventListener(TimeEvent.COMPLETE, onMediaComplete, false, 0, true);
		}
			
		
		/**
		 * @public
		 * 
		 * Load a playlist/clip from the server, and then orchestrate it.
		 * 
		 * Note that the server always return a playlist XML, even if we are trying to get an individual video clip.
		 * In this case the result has its playlistId equals to -1, meaning that we have been requested a clip instead
		 * an existing playlist.
		 * 
		 * The type is a string defined in core.models.ResourceType class.
		 * 
		 */
		public function loadResource(id:String, type:String, params:Object = null):void{
			var request:URLRequest;
			
			if(type == ResourceType.PLAYLIST)
				request = new URLRequest(Environment.serverUrl + "/playlists.request.xml?id=" + id);
			else if(type == ResourceType.CLIP){
				var urlString:String = Environment.serverUrl + "/clips.request.xml?id=" + id;
				if(params && params.startTime && params.startTime != -1)
					urlString += "&startTime=" + params.startTime.toString();
				if(params && params.endTime && params.endTime != -1)
					urlString += "&endTime=" + params.endTime.toString();
				
				request = new URLRequest(urlString);
			}			
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onResourceLoaded, false, 0, true);
			loader.load(request);
		}
		
		/**
		 * @protected
		 * 
		 * Invoked when the resource is loaded.
		 * 
		 * If the advertising plugin is disabled, or the video sequence is not long enough to allow showing a long ad instead 
		 * (this is determined by the server, and marked in the playlist's adAvailability property), we simply continue orchestrating
		 * either with no ads at all, or with short ads. 
		 * 
		 * However if the playlist.adAvailability is set to "long", then the sequence is qualified for using long ads. In this case we dispatch an 
		 * event (AdModeEvent.NEED_TO_CHOOSE_AD_MODE) and wait until the user makes a decision. After that, we need to manually calling the orchestrate() method
		 * to continue. 
		 * 
		 */
		protected function onResourceLoaded(evt:Event = null):void{
			var loader:URLLoader = evt.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE, onResourceLoaded);
			
			var result:XML = XML(loader.data);
			
			// Create a playlist and its content
			playlist = ModelFactory.createPlayList(result);
			
			// Notify that the playlist has completed loading phase
			dispatchEvent(new CoreEvent(CoreEvent.PLAYLIST_LOADED));

			// Check advertising availibility. If the server allows choosing between long and short ads (like Hulu does),
			// then we have to halt the orchestration until the user chooses his/her ad mode.
			if(playlist.clips.length == 0)
				return;
			
			if(playlist.adAvailability == AdAvailability.LONG && pluginController.adPluginLoaded)
				dispatchEvent(new AdModeEvent(AdModeEvent.NEED_TO_CHOOSE_AD_MODE));
			else{
				playClip(playlist.clips[0]);
			}
		}
				
		/**
		 * @public
		 * 
		 * Populate a serialElement. Besides the clips that users chosed themselves, we also add certain ads before and during playback. 
		 * These ads are controlled by certain rules.
		 */
		
		public function orchestrate(clip:Clip):void{
			// Inspect each of the clip and assign metadata to them
			var resource:StreamingURLResource;
			if(clip.dvr)
				resource = new StreamingURLResource(clip.url, StreamType.DVR);
			else if(clip.live)
				resource = new StreamingURLResource(clip.url, StreamType.LIVE);
			else
				resource = new StreamingURLResource(clip.url, null, clip.startTime, clip.endTime);
			
			clip.resource = resource;
			// The following lines will orchestrate necessary metadata for the clip
			
			// If user prefer to view a long ad, then we only need to orchestrate the first clip with a long ad, and disable all other ad points
			// Insert AdMetadata only when ad is enabled
			var adMetadata:AdMetadata;
			if(playlist.adAvailability != AdAvailability.NONE){
				if(playlist.useLongAd){
					if(playlist.clips.indexOf(clip) == 0){
						adMetadata = AdMetadataFactory.createMetadata(clip, true);
						resource.addMetadataValue(AdPluginInfo.NS_AD_ENABLED, true);
					}
				}
				else{
					adMetadata = AdMetadataFactory.createMetadata(clip, false);
					resource.addMetadataValue(AdPluginInfo.NS_AD_ENABLED, true);					
				}
			}
			
			// If native tracking is enabled, then we should add extra metadata here
			var nativeTrackingMetadata:NativeTrackingMetadata = null; 
			if(PluginPolicy.enableNativeTracking){
				nativeTrackingMetadata = NativeTrackingMetadataFactory.createMetadata(clip);				
				resource.addMetadataValue(NativeTrackingPluginInfo.NS_NATIVE_TRACKING_ENABLED, true);
			}
			// Enable/disable comment plugin
			var annotationMetadata:AnnotationMetadata = null;
			if(PluginPolicy.enableComments){
				annotationMetadata = AnnotationMetadataFactory.createMetadata(clip);
				resource.addMetadataValue(AnnotationPluginInfo.NS_ANNOTATION_ENABLED, true);
			}
			
			// If Conviva plugin is enabled and loaded, then we add the metadata needed here
			if(PluginPolicy.enableConviva && pluginController.convivaPluginLoaded){
				var convivaMetadata:Dictionary = ConvivaMetadataFactory.createMetadata(clip);
				resource.addMetadataValue(Conviva.CONVIVA_NAMESPACE, convivaMetadata);
			}
			
			// If ComScore plugin is enabled and loaded, then we add ComScore metadata here
			if(PluginPolicy.enableComscore)
				resource.addMetadataValue(ComscorePluginInfo.COMSCORE_METADATA_NAMESPACE, ComscoreMetadataFactory.createMetadata(clip));
			
			// Create media element
			var mediaElement:MediaElement = factory.createMediaElement(resource);
			clip.mediaElement = mediaElement;
			
			if(adMetadata){
				mediaElement.addMetadata(AdMetadata.NS_AD_METADATA, adMetadata);
			}
			
			if(nativeTrackingMetadata){
				mediaElement.addMetadata(NativeTrackingMetadata.NS_NATIVE_TRACKING_METADATA, nativeTrackingMetadata);
			}

			if(annotationMetadata){
				mediaElement.addMetadata(AnnotationMetadata.NS_ANNOTATION_METADATA, annotationMetadata);
			}
			
			clip.orchestrated = true;
			if(playlist.adAvailability == AdAvailability.NONE
				|| (playlist.adAvailability == AdAvailability.LONG && playlist.clips.indexOf(clip) != 0))
				playClip(clip);
			else
				clip.addEventListener(AdProxyEvent.ORCHESTRATED, onAdsOrchestrated, false, 0, true);
		}
		
		/**
		 * @protected
		 * 
		 * Invoked when the ads being orchestrated. If the result clip is the first
		 * in the playlist, then we start playback immediately
		 */
		protected function onAdsOrchestrated(evt:AdProxyEvent):void{
			var clip:Clip = evt.clip;
			clip.removeEventListener(AdProxyEvent.ORCHESTRATED, onAdsOrchestrated);
			playClip(clip);
		}
		
		/**
		 * @public
		 * 
		 * Remove the current clip from the screen
		 */
		public function clearCurrentClip():void{
			if(!currentClip)
				return;
			
			if(player.playing || player.paused)
				player.stop();

			// Unload media
			player.media = null;
			
			if(currentClip && currentClip.mediaElement && mediaContainer.containsMediaElement(currentClip.mediaElement)){
				mediaContainer.removeMediaElement(currentClip.mediaElement);
			}
			
			currentClip = null;
		}
		
		/**
		 * @public
		 * 
		 * Switch to the specified clip in the playlist
		 */
		public function playClip(clip:Clip):void{
			// Stop current media and free up resources	
			if(clip != currentClip && currentClip != null)
				clearCurrentClip();
			
			if(!clip.orchestrated){
				orchestrate(clip);
				return;
			}
			
			// Set the target clip to be current clip
			currentClip = clip;
			player.media = clip.mediaElement;
			mediaContainer.addMediaElement(clip.mediaElement);
			
			// And play the new clip
			if(player.canPlay){
				player.play();
			}
			else{
				dispatchEvent(new PlaylistEvent(PlaylistEvent.SHOW_LOADING_SCREEN));
				
				player.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE, onCanPlayChange, false, 0, true);
			}
			
			// Dispatch a PlaylistEvent to nitify the UI that the current clip has changed
			var evt:PlaylistEvent = new PlaylistEvent(PlaylistEvent.CURRENT_CLIP_CHANGE);
			evt.selectedItem = currentClip;
			dispatchEvent(evt);			
		}
		
		/**
		 * @public
		 * 
		 * Delegate to MediaPlayer.play()
		 */
		public function play():void{
			if(player.canPlay){
				player.play();
			}
		}
		
		/**
		 * @public
		 * 
		 * Delegate to MediaPlayer.pause()
		 */
		public function pause():void{
			if(player.canPause){
				player.pause();
			}
		}
		
		/**
		 * @public
		 * 
		 * Stops media playback and unload media element
		 */
		public function stop():void{
			if(player.playing)
				player.stop();
			
			clearCurrentClip();
		}
		
		/**
		 * @public
		 * 
		 * Delegate to MediaPlayer.seek()
		 */
		public function seekTo(time:Number):void{
			if(player.canSeek){
				player.seek(time);
			}
		}
		
		/**
		 * @public
		 * 
		 * Return the next media in the playlist
		 */
		public function getNextClip():Clip{
			var currentIndex:Number = playlist.clips.indexOf(currentClip);
			var nextIndex:Number = (currentIndex == playlist.clips.length - 1) ? 0 : currentIndex + 1;

			return playlist.clips[nextIndex];
		}
		
		/**
		 * @protected
		 * 
		 * Invoked when the canPlay capacity has changed
		 */
		protected function onCanPlayChange(evt:MediaPlayerCapabilityChangeEvent):void{
			if(player.canPlay){
				player.removeEventListener(MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE, onCanPlayChange);
				dispatchEvent(new PlaylistEvent(PlaylistEvent.REMOVE_LOADING_SCREEN));
				
				player.play();
			}
		}
		
		/**
		 * @private
		 * 
		 * Invoked when a media has completed playback
		 */
		protected function onMediaComplete(evt:TimeEvent):void{
			// Auto play next
			playClip(getNextClip());
		}
		
		/**
		 * @private
		 */
		protected function onPlayerStateChange(evt:MediaPlayerStateChangeEvent):void{
			switch(evt.state){
				case MediaPlayerState.READY:
					onPlayerReady();
					break;
			}
		}
		
		/**
		 * @private
		 */
		protected function onPlayerReady():void{
			if(!currentClip || !currentClip.mediaElement || !currentClip.streaming)
				return;
			
			var resource:StreamingURLResource = currentClip.mediaElement.resource as StreamingURLResource;
			if(resource && resource.hasOwnProperty("streamItems")){
				currentBitrate = player.getBitrateForDynamicStreamIndex(player.currentDynamicStreamIndex);
				
				currentClip.bitrates = [];
				if(player.numDynamicStreams > 0){
					for(var i:uint = 0; i < player.numDynamicStreams; i++){
						currentClip.bitrates.push(player.getBitrateForDynamicStreamIndex(i));
					}
				}
			}
		}
		
		/**
		 * Invoked when the DRM status changed
		 */
		protected function onDRMStateChange(evt:DRMEvent):void{
			if(evt.drmState == DRMState.AUTHENTICATION_NEEDED){
				var drmTrait:DRMTrait = currentClip.mediaElement.getTrait(MediaTraitType.DRM) as DRMTrait;
				if(drmTrait){
					drmTrait.authenticate();
				}
			}
		}
		
	}
}