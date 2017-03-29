package hex.compiler.parser.flow;

import hex.core.IApplicationAssembler;

#if macro
import haxe.macro.Expr;
import hex.compiler.core.CompileTimeContextFactory;
import hex.compiletime.CompileTimeApplicationAssembler;
import hex.compiletime.CompileTimeParser;
import hex.compiletime.flow.DSLReader;
import hex.compiletime.flow.FlowAssemblingExceptionReporter;
import hex.compiletime.util.ClassImportHelper;
import hex.compiletime.basic.CompileTimeApplicationContext;
#end

/**
 * ...
 * @author Francis Bourre
 */
class FlowCompiler 
{
	#if macro
	static function _readFile( 	fileName : String, 
								?applicationContextName : String,
								?preprocessingVariables : Expr, 
								?applicationAssemblerExpr : Expr ) : ExprOf<IApplicationAssembler>
	{
		var reader						= new DSLReader();
		var document 					= reader.read( fileName, preprocessingVariables );
		
		var assembler 					= new CompileTimeApplicationAssembler( applicationAssemblerExpr );
		var parser 						= new CompileTimeParser( new ParserCollection() );
		
		parser.setImportHelper( new ClassImportHelper() );
		parser.setExceptionReporter( new FlowAssemblingExceptionReporter() );
		parser.parse( assembler, document, CompileTimeContextFactory, CompileTimeApplicationContext, applicationContextName );
		
		return assembler.getMainExpression();
	}
	#end

	macro public static function compile( 	fileName : String, 
											?applicationContextName : String,
											?preprocessingVariables : Expr ) : ExprOf<IApplicationAssembler>
	{
		return FlowCompiler._readFile( fileName, applicationContextName, preprocessingVariables );
	}
	
	macro public static function compileWithAssembler( 	assemblerExpr : Expr, 
														fileName : String, 
														?applicationContextName : String,
														?preprocessingVariables : Expr ) : ExprOf<IApplicationAssembler>
	{
		return FlowCompiler._readFile( fileName, applicationContextName, preprocessingVariables, assemblerExpr );
	}
}