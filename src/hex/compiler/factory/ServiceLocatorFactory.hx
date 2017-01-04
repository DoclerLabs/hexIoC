package hex.compiler.factory;

import haxe.macro.Context;
import hex.config.stateful.ServiceLocator;
import hex.ioc.vo.ConstructorVO;
import hex.ioc.vo.FactoryVO;
import hex.ioc.vo.MapVO;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ServiceLocatorFactory
{
	function new()
	{

	}

	#if macro
	static public function build( factoryVO : FactoryVO ) : Dynamic
	{
		//build arguments
		MapArgumentFactory.build( factoryVO );
		
		var constructorVO : ConstructorVO = factoryVO.constructorVO;
		var args : Array<MapVO> = cast constructorVO.arguments;
		
		var idVar = constructorVO.ID;
		var typePath = MacroUtil.getTypePath( Type.getClassName( ServiceLocator ) );
		var e = macro @:pos( constructorVO.filePosition ) { new $typePath(); };
		factoryVO.expressions.push( macro @:mergeBlock { var $idVar = $e; } );
		
		var extVar = macro $i{ idVar };
		if ( args.length <= 0 )
		{
			Context.warning( "ServiceLocatorFactory.build(" + args + ") returns an empty ServiceConfig.", constructorVO.filePosition );

		} else
		{
			for ( item in args )
			{
				if ( item.key != null )
				{
					var a = [ item.key, item.value, macro { $v { item.mapName } } ];
					factoryVO.expressions.push( macro @:pos( constructorVO.filePosition ) @:mergeBlock { $extVar.addService( $a{ a } ); } );
					
				} else
				{
					Context.warning( "ServiceLocatorFactory.build() adds item with a 'null' key for '"  + item.value +"' value.", constructorVO.filePosition );
				}
			}
		}
		
		return e;
	}
	#end
}