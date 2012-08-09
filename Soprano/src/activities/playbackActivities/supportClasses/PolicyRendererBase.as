package activities.playbackActivities.supportClasses
{
	import polkit.Policy;
	
	import spark.components.Group;
	
	public class PolicyRendererBase extends Group
	{
		/**
		 * @public
		 */
		[Bindable]
		public var policy:Policy;
		
		/**
		 * Constructor
		 */
		public function PolicyRendererBase()
		{
			super();
		}
	}
}