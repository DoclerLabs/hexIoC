package hex.ioc.parser;

import hex.error.VirtualMethodException;
import hex.ioc.assembler.AbstractApplicationContext;
import hex.ioc.assembler.IApplicationAssembler;

/**
 * ...
 * @author Francis Bourre
 */
class AbstractContextParser<ContentType> implements IContextParser<ContentType>
{
	var _applicationAssembler 	: IApplicationAssembler;
	var _contextData 			: ContentType;

	function new() 
	{
		//
	}
	
	@final
	public function setApplicationAssembler( applicationAssembler : IApplicationAssembler ) : Void
	{
		this._applicationAssembler = applicationAssembler;
	}
	
	@final
	public function getApplicationAssembler() : IApplicationAssembler
	{
		return this._applicationAssembler;
	}

	@final
	public function getContextData() : ContentType
	{
		return this._contextData;
	}

	public function parse() : Void
	{
		throw new VirtualMethodException( "parse must be implemented in concrete class." );
	}

	public function setContextData( data : ContentType ) : Void
	{
		throw new VirtualMethodException( "setContextData must be implemented in concrete class." );
	}
	
	public function getApplicationContext() : AbstractApplicationContext
	{
		throw new VirtualMethodException( "getApplicationContext must be implemented in concrete class." );
	}
}