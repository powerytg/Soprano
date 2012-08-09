package core.plugins.annotation.utils
{
	import core.plugins.annotation.models.Annotation;
	import core.plugins.annotation.models.AnnotationLayout;
	import core.models.Comment;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import org.osmf.metadata.CuePoint;
	import org.osmf.metadata.CuePointType;
	
	public class AnnotationFactory extends EventDispatcher
	{
		/**
		 * Constructor
		 */
		public function AnnotationFactory(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		/**
		 * Parse the xml and generate a collection of annotations and comments
		 */
		public static function createModelsFromXml(src:XMLList):Array{
			var collection:Array = new Array();
			
			for each(var annotationXml:XML in src.children()){
				var annotation:Annotation = createAnnotation(annotationXml);
				collection.push(annotation);
			}
			
			return collection;
		}
		
		/**
		 * @public
		 */
		public static function createAnnotation(source:XML):Annotation{
			var annotation:Annotation = new Annotation();
			annotation.id = String(source.id);
			annotation.content = String(source.content);
			annotation.duration = Number(source.duration);
			
			// Setup layout
			var layout:AnnotationLayout = new AnnotationLayout();
			layout.horizontalAlign = String(source.h_align);
			layout.verticalAlign = String(source.v_align);
			layout.horizontalPadding = Number(source.h_padding);
			layout.verticalPadding = Number(source.v_padding);
			layout.width = Number(source.width);
			layout.height = Number(source.height);
			
			annotation.layout = layout;
			
			// Setup cue points
			var cuePointTime:Number = Number(source.cue_point);
			var cuePoint:CuePoint = new CuePoint(CuePointType.ACTIONSCRIPT, cuePointTime, "annotation" + cuePointTime.toString(), null, annotation.duration);
			
			annotation.cuePoint = cuePoint;			
			return annotation;
		}

		
	}
}