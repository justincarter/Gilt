component accessors="true" 
{

	property fileName;
	property fileContent;
	property selectionStartLine;
	property selectionStartColumn;
	property selectionEndLine;
	property selectionEndColumn;
	property selectionText;


	function init() {
		var data = xmlParse(form.ideEventInfo);
		
		// TODO: detect event type
		// editor / projectview / rdsview 

		fileName = data.event.ide.editor.file.xmlAttributes.location;
		fileContent = fileRead(fileName);
		
		if (isDefined("data.event.ide.editor.selection")) {
			selectionStartLine = data.event.ide.editor.selection.xmlAttributes.startline;
			selectionStartColumn = data.event.ide.editor.selection.xmlAttributes.startcolumn;
			selectionEndLine = data.event.ide.editor.selection.xmlAttributes.endline;
			selectionEndColumn = data.event.ide.editor.selection.xmlAttributes.endcolumn;
			selectionText = data.event.ide.editor.selection.text.xmlText;
		}
		
		
	}


	function insertText(text) {
		var xml = '
			<response>
			<ide>
			<commands>
			<command type="inserttext">
				<params>
					<param key="text"><![CDATA[#text#]]></param>
				</params>
			</command>
			</commands>
			</ide>
			</response>
		';
		return xml;
	}

	function displayError(text) {
		var html = '
			<p>#text#</p>
		';
		return html;
	}

}