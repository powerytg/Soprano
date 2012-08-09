package core.plugins.ad.elements
{
	import core.plugins.ad.events.DurationProxyElementEvent;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.elements.proxyClasses.DurationTimeTrait;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	
	public class DurationProxyElement extends ProxyElement
	{
		/**
		 * Constructor.
		 */		
		public function DurationProxyElement(proxiedElement:MediaElement, duration:Number)
		{
			_duration = duration;
			
			// Prepare the position timer.
			playheadTimer = new Timer(DEFAULT_PLAYHEAD_UPDATE_INTERVAL);
			playheadTimer.addEventListener(TimerEvent.TIMER, onPlayheadTimer, false, 0, true);
			
			super(proxiedElement);			
		}
		
		/**
		 * @private
		 */
		override protected function setupTraits():void
		{
			super.setupTraits();
			
			timeTrait = new DurationTimeTrait(_duration);
			
			timeTrait.addEventListener(TimeEvent.COMPLETE, onComplete, false, int.MAX_VALUE);
			addTrait(MediaTraitType.TIME, timeTrait);
			
			// Block seek trait
			var traitsToBeBlocked:Vector.<String> = new Vector.<String>;
			traitsToBeBlocked.push(MediaTraitType.SEEK);
			this.blockedTraits = traitsToBeBlocked;			
		}
		
		/**
		 * @public
		 */
		public function startTimer():void{
			absoluteStartTime = flash.utils.getTimer() - currentTime*1000;
			playheadTimer.start();			
		}
		
		// Internals
		//
		
		/**
		 * @private
		 */
		private function onPlayheadTimer(event:TimerEvent):void
		{
			if (currentTime >= _duration)
			{
				currentTime = _duration;
				playheadTimer.stop();
			}
			else
			{
				// Increment our currentTime on each Timer tick.
				currentTime = (flash.utils.getTimer() - absoluteStartTime)/1000;
			}
		}
		
		/**
		 * @private
		 */
		private function onComplete(event:TimeEvent = null):void
		{
			if(playheadTimer){
				playheadTimer.stop();
				playheadTimer.removeEventListener(TimerEvent.TIMER, onPlayheadTimer);
			}
			
			if(timeTrait){
				timeTrait.removeEventListener(TimeEvent.COMPLETE, onComplete);
				removeTrait(MediaTraitType.TIME);
			}
			
			dispatchEvent(new DurationProxyElementEvent(DurationProxyElementEvent.TIME_UP));
			
		}
		
		/**
		 * @private
		 */
		private function get currentTime():Number
		{
			return _currentTime;
		}
		
		/**
		 * @private
		 */
		private function set currentTime(value:Number):void
		{
			_currentTime = value;
			timeTrait.currentTime = value;
		}
		
		private static const DEFAULT_PLAYHEAD_UPDATE_INTERVAL:Number = 250;
		
		private var _currentTime:Number = 0; // seconds
		private var _duration:Number = 0;	// seconds
		private var absoluteStartTime:Number = 0; // milliseconds
		private var playheadTimer:Timer;
		
		private var timeTrait:DurationTimeTrait;
	}
}