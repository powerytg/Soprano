package core.utils
{
	import flash.utils.Dictionary;
	import core.models.Clip;
	import core.models.Tag;
	
	public class ConvivaMetadataFactory
	{
		/**
		 * Constructor
		 */
		public function ConvivaMetadataFactory()
		{
		}
		
		/**
		 * @public
		 */
		public static function createMetadata(clip:Clip):Dictionary{
			// Translate the tag vector into an object
			var tags:Object = new Object();
			for each(var tag:Tag in clip.tags){
				tags[tag.name] = tag.name;
			}
			
			// Additional metadata
			tags["name"] = clip.name;
			tags["duration"] = clip.duration;
			tags["cdnName"] = clip.cdn.name;
			
			// Major metadata
			var metadata:Dictionary = new Dictionary(true);
			metadata["objectId"] = clip.id;
			metadata["isLive"] = false;
			metadata["tags"] = tags;
			
			return metadata;
		}
		
	}
}