package hex.compiler.parser.flow;

#if macro
import haxe.macro.Expr;
import hex.factory.BuildRequest;
import hex.parser.AbstractParserCollection;

/**
 * ...
 * @author Francis Bourre
 */
class ParserCollection extends AbstractParserCollection<AbstractExprParser, Expr>
{
	public function new() 
	{
		super();
	}
	
	override function _buildParserList() : Void
	{
		this._parserCollection.push( new ApplicationContextParser() );
		this._parserCollection.push( new StateParser() );
		this._parserCollection.push( new ObjectParser() );
		this._parserCollection.push( new Launcher() );
	}
}
#end