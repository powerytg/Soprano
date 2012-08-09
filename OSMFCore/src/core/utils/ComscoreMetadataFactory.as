package core.utils
{
	import core.env.Comscore;
	
	import org.osmf.metadata.Metadata;
	import core.models.Clip;

	public class ComscoreMetadataFactory
	{
		/**
		 * Constructor
		 */
		public function ComscoreMetadataFactory()
		{
		}
		
		/**
		 * @public
		 */
		public static function createMetadata(clip:Clip):Metadata{
			// Reformat the clip's title, replacing " " with "_"
			var clipName:String = clip.name.split().join("_"); 
			
			var metadata:Metadata = new Metadata();
			metadata.addValue("c1", 1);
			metadata.addValue("c2", Comscore.c2);
			metadata.addValue("c3", Comscore.c3);
			metadata.addValue("c4", Comscore.c4);
			metadata.addValue("c5", Comscore.c5);
			metadata.addValue("c6", clipName);
			
			return metadata;			
		}
	}
}