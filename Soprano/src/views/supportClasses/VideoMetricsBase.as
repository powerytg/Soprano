package views.supportClasses
{
	import core.events.MetricsEvent;
	import core.models.videoMetrics.VideoMetrics;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class VideoMetricsBase extends SkinnableComponent
	{
		/**
		 * @private
		 */
		protected var _metrics:VideoMetrics;
		 
		/**
		 * @private
		 */
		protected var metricsChanged:Boolean = false;
		
		/**
		 * Constructor
		 */
		public function VideoMetricsBase()
		{
			super();
		}
		
		/**
		 * private
		 */
		public function get metrics():VideoMetrics
		{
			return _metrics;
		}

		/**
		 * @private
		 */
		public function set metrics(value:VideoMetrics):void
		{
			if ( _metrics == value ) {
				return;
			}
			
			if ( _metrics ) {
				_metrics.removeEventListener( MetricsEvent.UPDATE, onMetricsUpdate );
			}
			
			_metrics = value;
			
			if ( _metrics ) {
				_metrics.addEventListener( MetricsEvent.UPDATE, onMetricsUpdate, false, 0, true );
			}
			
			metricsChanged = true;
		}

		/**
		 * @private
		 */
		protected function onMetricsUpdate(evt:MetricsEvent):void{
			// Do nothing in base class
		}
		
	}
}