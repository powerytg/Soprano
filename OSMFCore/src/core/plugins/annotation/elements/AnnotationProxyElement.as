package core.plugins.annotation.elements
{
	import core.controllers.OSMFController;
	import core.env.Environment;
	import core.models.Clip;
	import core.plugins.annotation.events.*;
	import core.plugins.annotation.models.*;
	import core.plugins.annotation.utils.AnnotationFactory;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimelineMetadataEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.metadata.CuePoint;
	import org.osmf.metadata.TimelineMetadata;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.SeekTrait;
	
	public class AnnotationProxyElement extends ProxyElement
	{
		/**
		 * @private
		 */
		protected var timer:Timer;
		
		/**
		 * @private
		 * 
		 * A reference to the clip being tracked
		 */
		protected var clip:Clip;
		
		/**
		 * @private
		 * 
		 * A factory used to create comment elements
		 */
		protected var factory:MediaFactory;
		
		/**
		 * @private
		 * 
		 * Comment metadata
		 */
		protected var annotationMetadata:AnnotationMetadata;
		
		/**
		 * @private
		 */
		private var annotationByCuePoint:Dictionary = new Dictionary(true);
		
		/**
		 * @private
		 */
		private var activeAnnotations:Vector.<Annotation> = new Vector.<Annotation>();
		
		/**
		 * Constructor
		 */
		public function AnnotationProxyElement(proxiedElement:MediaElement=null)
		{
			super(proxiedElement);
			
			// Create a media factory
			factory = new DefaultMediaFactory();
			
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
				annotationMetadata = getMetadata(AnnotationMetadata.NS_ANNOTATION_METADATA) as AnnotationMetadata;
				
				if(!metadata)
					return;
				
				clip = annotationMetadata.clip;
				
				// Initialize a timeline for our cue points
				var timeline:TimelineMetadata = getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
				if(!timeline){
					timeline = new TimelineMetadata(proxiedElement);
					addMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE, timeline);
				}
				timeline.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onCuePointReached, false, 0, true);
				timeline.addEventListener(TimelineMetadataEvent.MARKER_DURATION_REACHED, onCuePointDurationReached, false, 0, true);
 
				// Capture seek events
				var seekTrait:SeekTrait = proxiedElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
				if(seekTrait){
					proxiedElement.addEventListener(SeekEvent.SEEKING_CHANGE, onSeek, false, 0, true);
				}
				else
					proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onSeekTraitAdded, false, 0, true);

				
				// Load comments from server
				getAnnotations();
			}
		}
		
		/**
		 * Fetch the comments from the server
		 */
		protected function getAnnotations():void{
			var request:URLRequest = new URLRequest(Environment.serverUrl + "/clips.get_annotations.xml?id=" + clip.id);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onGetAnnotations, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
			loader.load(request);
		}
		
		/**
		 * @private
		 */
		private function onIOError(evt:IOErrorEvent):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			loader.removeEventListener(Event.COMPLETE, onGetAnnotations);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);

			trace("[AnnotationPlugin] Error when reading annotations from server");
			trace(loader.data);
		}
		
		/**
		 * Invoked when we have received comments from the server
		 */
		protected function onGetAnnotations(evt:Event):void{
			var loader:URLLoader = evt.currentTarget as URLLoader;
			loader.removeEventListener(Event.COMPLETE, onGetAnnotations);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);

			var result:XML = XML(loader.data);
			var annotationXml:XMLList = XMLList(result.child("annotations"));
			
			// We'll need to parse the comments from the xml
			clip.annotations = new Vector.<Annotation>();
			var timeline:TimelineMetadata = getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
			
			var collection:Array = AnnotationFactory.createModelsFromXml(annotationXml);
			for each(var annotation:Annotation in collection){
				clip.annotations.push(annotation);
				timeline.addMarker(annotation.cuePoint);
				
				// Make up reference
				annotationByCuePoint[annotation.cuePoint] = annotation;
			}
			
		}

		/**
		 * @protected
		 * 
		 * Invoked when an annotation is about to be displayed
		 */
		protected function onCuePointReached(evt:TimelineMetadataEvent):void{
			// Accept only annotation cue points
			if((evt.marker as CuePoint).name.match(/^annotation/) == null)
				return;
			
			// Find out the respective annotation
			var annotation:Annotation = annotationByCuePoint[evt.marker as CuePoint];
			
			var event:AnnotationEvent = new AnnotationEvent(AnnotationEvent.CUE_POINT_REACHED);
			event.currentAnnotation = annotation;
			OSMFController.osmfController.dispatchEvent(event);
			
			if(activeAnnotations.indexOf(annotation) == -1)
				activeAnnotations.push(annotation);
		}

		/**
		 * @protected
		 * 
		 * Invoked when an annotation expires
		 */
		protected function onCuePointDurationReached(evt:TimelineMetadataEvent):void{
			// Accept only annotation cue points
			if((evt.marker as CuePoint).name.match(/^annotation/) == null)
				return;
			
			// Find out the respective annotation
			var annotation:Annotation = annotationByCuePoint[evt.marker as CuePoint];
			
			var event:AnnotationEvent = new AnnotationEvent(AnnotationEvent.CUE_POINT_EXPIRED);
			event.currentAnnotation = annotation;
			OSMFController.osmfController.dispatchEvent(event);		
			
			if(activeAnnotations.indexOf(annotation) != -1)
				activeAnnotations.splice(activeAnnotations.indexOf(annotation), 1);
		}
		
		/**
		 * @protected
		 * 
		 * Invoked when the original element gains the seek trait
		 */
		protected function onSeekTraitAdded(evt:MediaElementEvent):void{
			if(evt.traitType == MediaTraitType.SEEK){
				var seekTrait:SeekTrait = proxiedElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
				seekTrait.addEventListener(SeekEvent.SEEKING_CHANGE, onSeek, false, 0, true);
			}
		}

		/**
		 * @private
		 */
		protected function onSeek(evt:SeekEvent):void{
			// Iterate through the annotations
			if(!clip)
				return;
			
			var event:AnnotationEvent;
			for each(var annotation:Annotation in clip.annotations){
				if(annotation.cuePoint.time > evt.time || annotation.cuePoint.time + annotation.duration < evt.time){
					if(activeAnnotations.indexOf(annotation) != -1){
						activeAnnotations.splice(activeAnnotations.indexOf(annotation), 1);
						
						event = new AnnotationEvent(AnnotationEvent.CUE_POINT_EXPIRED);
						event.currentAnnotation = annotation;
						OSMFController.osmfController.dispatchEvent(event);		
					}
				}
				else{
					if(activeAnnotations.indexOf(annotation) == -1){
						activeAnnotations.push(annotation);
						
						event = new AnnotationEvent(AnnotationEvent.CUE_POINT_REACHED);
						event.currentAnnotation = annotation;
						OSMFController.osmfController.dispatchEvent(event);
					}

				}
			
					
			}
		}

	}	
}