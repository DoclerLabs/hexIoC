package hex.ioc.assembler;

import hex.collection.HashMap;
import hex.core.HashCodeFactory;
import hex.ioc.assembler.ApplicationContext;
import hex.ioc.assembler.IApplicationAssembler;
import hex.ioc.core.BuilderFactory;
import hex.ioc.core.ContextTypeList;
import hex.ioc.core.ModuleLocator;
import hex.ioc.locator.MethodCallVOLocator;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.DomainListenerVOArguments;
import hex.ioc.vo.MapVO;
import hex.ioc.vo.MethodCallVO;
import hex.ioc.vo.PropertyVO;
import hex.ioc.vo.ServiceLocatorVO;
import hex.module.IModule;

/**
 * ...
 * @author Francis Bourre
 */
class ApplicationAssembler implements IApplicationAssembler
{
	public function new() 
	{
		
	}
	
	private var _mApplicationContext 		: HashMap<String, ApplicationContext> = new HashMap<String, ApplicationContext>();
	private var _mBuilderFactories 			: HashMap<ApplicationContext, BuilderFactory> = new HashMap<ApplicationContext, BuilderFactory>();
	
	public function startAssembling() : Void
	{
		var applicationContexts : Array<ApplicationContext> = this._mApplicationContext.getValues();
		for ( applicationcontext in applicationContexts )
		{
			applicationcontext._dispatch( ApplicationAssemblerMessage.ASSEMBLING_START );
		}
	}

	public function getBuilderFactory( applicationContext : ApplicationContext ) : BuilderFactory
	{
		return this._mBuilderFactories.get( applicationContext );
	}

	public function release() : Void
	{
		var builderFactories : Array<BuilderFactory> = this._mBuilderFactories.getValues();
		for ( builderFactory in builderFactories )
		{
			builderFactory.release();
		}
		this._mApplicationContext.clear();
		this._mBuilderFactories.clear();
	}

	public function buildProperty(  applicationContext 	: ApplicationContext,
									ownerID 			: String,
									name 				: String = null,
									value 				: String = null,
									type 				: String = null,
									ref 				: String = null,
									method 				: String = null,
									staticRef 			: String = null  ) : PropertyVO
	{
		return this.getBuilderFactory( applicationContext ).getPropertyVOLocator().addProperty( ownerID, name, value, type, ref, method, staticRef );
	}

	public function buildObject(    applicationContext 	: ApplicationContext,
									ownerID 			: String,
									type 				: String = null,
									args 				: Array<Dynamic> = null,
									factory 			: String = null,
									singleton 			: String = null,
									mapType 			: String = null,
									staticRef 			: String = null ) : ConstructorVO
	{
		if ( args != null )
		{
			var length : Int = args.length;
			var index : Int;
			var obj : Dynamic;

			if ( type == ContextTypeList.HASHMAP )
			{
				for ( index in 0...length )
				{
					obj = args[ index ];
					var keyDic 		: Dynamic 		= obj.key;
					var valueDic 	: Dynamic 		= obj.value;
					var pKeyDic 	: PropertyVO 	= this.getBuilderFactory( applicationContext ).getPropertyVOLocator().buildProperty( ownerID, keyDic.name, keyDic.value, keyDic.type, keyDic.ref, keyDic.method, keyDic.staticRef );
					var pValueDic 	: PropertyVO 	= this.getBuilderFactory( applicationContext ).getPropertyVOLocator().buildProperty( ownerID, valueDic.name, valueDic.value, valueDic.type, valueDic.ref, valueDic.method, valueDic.staticRef );
					args[ index ] 					= new MapVO( pKeyDic, pValueDic );
				}
			}
			else if ( type == ContextTypeList.SERVICE_LOCATOR )
			{
				for ( index in 0...length )
				{
					obj = args[ index ];
					var keySC 		: Dynamic 		= obj.key;
					var valueSC 	: Dynamic 		= obj.value;
					var pKeySC 		: PropertyVO 	= this.getBuilderFactory( applicationContext ).getPropertyVOLocator().buildProperty( ownerID, keySC.name, keySC.value, keySC.type, keySC.ref, keySC.method, keySC.staticRef );
					var pValueSC 	: PropertyVO 	= this.getBuilderFactory( applicationContext ).getPropertyVOLocator().buildProperty( ownerID, valueSC.name, valueSC.value, valueSC.type, valueSC.ref, valueSC.method, valueSC.staticRef );
					args[ index ] 					= new ServiceLocatorVO( pKeySC, pValueSC, obj.mapName );
				}
			}
			else
			{
				for ( index in 0...length )
				{
					obj = args[ index ];
					var propertyVO : PropertyVO = this.getBuilderFactory( applicationContext ).getPropertyVOLocator().buildProperty( ownerID, obj.name, obj.value, obj.type, obj.ref, obj.method, obj.staticRef );
					args[ index ] = propertyVO;
				}
			}
		}

		var constructorVO : ConstructorVO = new ConstructorVO( ownerID, type, args, factory, singleton, null, mapType, staticRef );
		this.getBuilderFactory( applicationContext ).getConstructorVOLocator().register( ownerID, constructorVO );
		return constructorVO;
	}

	public function buildMethodCall( applicationContext : ApplicationContext, ownerID : String, methodCallName : String, args : Array<Dynamic> = null ) : Void
	{
		var methodCallVOLocator : MethodCallVOLocator = this.getBuilderFactory( applicationContext ).getMethodCallVOLocator();

		if ( args != null )
		{
			var length : Int = args.length;
			for ( i in 0...length )
			{
				var obj : Dynamic = args[ i ];
				var prop : PropertyVO = new PropertyVO( obj.id, obj.name, obj.value, obj.type, obj.ref, obj.method, obj.staticRef );
				args[ i ] = prop;
			}
		}

		var method : MethodCallVO = new MethodCallVO( ownerID, methodCallName, args );
		var index : Int = methodCallVOLocator.keys().length +1;
		methodCallVOLocator.register( ApplicationAssembler._getStringKeyFromInt( index ), method );
	}

	public function buildDomainListener( applicationContext : ApplicationContext, ownerID : String, listenedDomainName : String, args : Array<DomainListenerVOArguments> = null ) : Void
	{
		var domainListenerVO : DomainListenerVO = new DomainListenerVO( ownerID, listenedDomainName, args );
		this.getBuilderFactory( applicationContext ).getDomainListenerVOLocator().register( "" + HashCodeFactory.getKey( domainListenerVO ), domainListenerVO );
	}

	public function registerID( applicationContext : ApplicationContext, ID : String ) : Bool
	{
		return this.getBuilderFactory( applicationContext ).getIDExpert().register( ID );
	}

	public function buildEverything() : Void
	{
		var builderFactories 	: Array<BuilderFactory> = this._mBuilderFactories.getValues();
		var len 				: Int 					= builderFactories.length;
		var i 					: Int;
		
		for ( i in 0...len ) ApplicationAssembler._buildAllObjects( builderFactories[ i ] );
		for ( i in 0...len ) ApplicationAssembler._assignAllDomainListeners( builderFactories[ i ] );
		for ( i in 0...len ) ApplicationAssembler._callAllMethods( builderFactories[ i ] );
		for ( i in 0...len ) ApplicationAssembler._callInitOnModules( builderFactories[ i ] );
		
		var applicationContexts : Array<ApplicationContext> = this._mApplicationContext.getValues();
		for ( applicationcontext in applicationContexts )
		{
			applicationcontext._dispatch( ApplicationAssemblerMessage.ASSEMBLING_END );
		}
	}

	public function getApplicationContext( applicationContextName : String, applicationContextClass : Class<ApplicationContext> = null ) : ApplicationContext
	{
		var applicationContext : ApplicationContext;

		if ( this._mApplicationContext.containsKey( applicationContextName ) )
		{
			applicationContext = this._mApplicationContext.get( applicationContextName );

		} else
		{
			if ( applicationContextClass != null )
			{
				applicationContext = Type.createInstance( applicationContextClass, [ this, applicationContextName ] );
			} 
			else
			{
				applicationContext = new ApplicationContext( this, applicationContextName );
			}
			
			this._mApplicationContext.put( applicationContextName, applicationContext );
			this._mBuilderFactories.put( applicationContext, new BuilderFactory( applicationContext ) );
		}

		return applicationContext;
	}

	static private function _buildAllObjects( builderFactory : BuilderFactory ) : Void
	{
		builderFactory.getConstructorVOLocator().buildAllObjects();
		builderFactory.getApplicationContext()._dispatch( ApplicationAssemblerMessage.OBJECTS_BUILT );
	}

	static private function _assignAllDomainListeners( builderFactory:BuilderFactory ) : Void
	{
		builderFactory.getDomainListenerVOLocator().assignAllDomainListeners();
		builderFactory.getApplicationContext()._dispatch( ApplicationAssemblerMessage.DOMAIN_LISTENERS_ASSIGNED );
	}

	static private function _callAllMethods( builderFactory:BuilderFactory ) : Void
	{
		builderFactory.getMethodCallVOLocator().callAllMethods();
		builderFactory.getApplicationContext()._dispatch( ApplicationAssemblerMessage.METHODS_CALLED );
	}
	
	static private function _callInitOnModules( builderFactory:BuilderFactory ) : Void
	{
		builderFactory.getModuleLocator().callModuleInitialisation();
		builderFactory.getApplicationContext()._dispatch( ApplicationAssemblerMessage.MODULES_INITIALIZED );
	}
	
	static private function _getStringKeyFromInt( index : Int ) : String
	{
		var value : Int 	= 5 - Std.string( index ).length;
		var src : String 	= "";

		if ( value > 0 )
		{
			for( i in 0...value )
			{
				src += "0";
			}
		}

		return src + index;
	}
}