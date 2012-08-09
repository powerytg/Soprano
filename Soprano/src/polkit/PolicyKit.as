package polkit
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import polkit.events.PolicyKitEvent;
	
	public class PolicyKit extends EventDispatcher
	{
		/**
		 * @private
		 */
		public var policies:Dictionary = new Dictionary(true);
		
		/**
		 * @private
		 */
		private static var _policyKit:PolicyKit;
		
		/**
		 * @public
		 */
		public static function get policyKit():PolicyKit
		{
			return initialize();
		}
		
		/**
		 * @public
		 */
		public static function initialize():PolicyKit
		{
			if (_policyKit == null){
				_policyKit = new PolicyKit();
			}
			return _policyKit;
		}
		
		/**
		 * Constructor
		 */
		public function PolicyKit()
		{
			super();
			if( _policyKit != null ) throw new Error("Error:PolicyKit already initialised.");
			if( _policyKit == null ) _policyKit = this;
			
			installPolicies();
		}
		
		/**
		 * @public
		 */
		public function installPolicy(policy:Policy):void{
			policies[policy.key] = policy;
		}
		
		/**
		 * @public
		 */
		public function getPolicy(key:String):Policy{
			if(policies[key]){
				var policy:Policy = policies[key] as Policy;
				return policy;
			}

			return null;
		}
		
		/**
		 * @public
		 */
		public function changePolicy(key:String, newValue:Object):void{
			var policy:Policy = getPolicy(key);
			
			if(!policy)
				return;
			
			var oldValue:Object = policy.value;
			policy.value = newValue;
			
			var evt:PolicyKitEvent = new PolicyKitEvent(PolicyKitEvent.POLICY_CHANGE);
			evt.policy = policy;
			evt.oldValue = oldValue;
			evt.newValue = newValue;
			
			dispatchEvent(evt);
		}
		
		/**
		 * @private
		 */
		private function installPolicies():void{
			// Whether to use TwinView 
			var p:Policy = new Policy();
			p.key = PolicyStrings.USE_TWIN_VIEW;
			p.value = true;
			p.kind = PolicyKind.BOOLEAN;
			p.description = "Use Twin View";
			
			installPolicy(p);
			
			// Whether to use TwinView on small screens (like phones)
			p = new Policy();
			p.key = PolicyStrings.USE_TWIN_VIEW_ON_SMALL_SCREEN;
			p.value = true;
			p.kind = PolicyKind.BOOLEAN;
			p.description = "Use Twin View on Small Screens";
			
			installPolicy(p);
		}
			
		
	}
}