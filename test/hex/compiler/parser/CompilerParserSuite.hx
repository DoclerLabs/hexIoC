package hex.compiler.parser;

import hex.compiler.parser.flow.CompilerFlowSuite;
import hex.compiler.parser.preprocess.PreprocessSuite;
import hex.compiler.parser.xml.CompilerXmlSuite;

/**
 * ...
 * @author Francis Bourre
 */
class CompilerParserSuite
{
	@Suite( "Parser" )
    public var list : Array<Class<Dynamic>> = 
	[ 
		PreprocessSuite, 
		CompilerFlowSuite, 
		CompilerXmlSuite 
	];
}