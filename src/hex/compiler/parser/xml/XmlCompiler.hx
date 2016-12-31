package hex.compiler.parser.xml;

import hex.runtime.ApplicationAssembler;

#if macro
import haxe.macro.Expr;
import hex.compiletime.CompileTimeApplicationAssembler;
import hex.preprocess.MacroConditionalVariablesProcessor;
import hex.ioc.assembler.ConditionalVariablesChecker;
import hex.ioc.parser.xml.XmlAssemblingExceptionReporter;
#end

using StringTools;

/**
 * ...
 * @author Francis Bourre
 */
class XmlCompiler
{
	#if macro
	static function _readXmlFile( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr, ?applicationAssemblerExpr : Expr ) : ExprOf<ApplicationAssembler>
	{
		var conditionalVariablesMap 	= MacroConditionalVariablesProcessor.parse( conditionalVariables );
		var conditionalVariablesChecker = new ConditionalVariablesChecker( conditionalVariablesMap );
		
		var positionTracker				= new PositionTracker();
		var dslReader					= new DSLReader( positionTracker );
		var document 					= dslReader.read( fileName, preprocessingVariables, conditionalVariablesChecker );
		
		var assembler 					= new CompileTimeApplicationAssembler( applicationAssemblerExpr );
		var parser 						= new CompileTimeParser( new ParserCollection() );
		
		parser.setImportHelper( new ClassImportHelper() );
		parser.setExceptionReporter( new XmlAssemblingExceptionReporter( positionTracker ) );
		parser.parse( assembler, document );

		return assembler.getMainExpression();
	}
	#end
	
	macro public static function readXmlFile( fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr ) : ExprOf<ApplicationAssembler>
	{
		return _readXmlFile( fileName, preprocessingVariables, conditionalVariables );
	}
	
	macro public static function readXmlFileWithAssembler( assemblerExpr : Expr, fileName : String, ?preprocessingVariables : Expr, ?conditionalVariables : Expr ) : ExprOf<ApplicationAssembler>
	{
		return _readXmlFile( fileName, preprocessingVariables, conditionalVariables, assemblerExpr );
	}
}
