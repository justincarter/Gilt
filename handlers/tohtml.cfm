<cfsetting enablecfoutputonly="true" showdebugoutput="false">

<!--- get event data from IDE --->
<cfset ide = new org.madfellas.ideEvent()>

<!--- get bbml from selection --->
<cfset bbml = ide.getSelectionText()> 
<cfif bbml eq "">
	<cfoutput>#ide.displayError("To use Gilt to convert Balsamiq Mockups BBML to HTML choose ""File - Export Mockup..."" in Balsamiq Mockups, paste the BBML from your clipboard into CF Builder and select/highlight it, then right click on the selected text and choose ""Gilt - Convert to HTML"".")#</cfoutput>
	<cfabort>
</cfif>

<!--- parse bbml --->
<cftry>
	<cfset reader = new org.gilt.bbmlReader()>
	<cfset reader.parse(bbml)>
	<cfcatch type="gilt.bbmlReader.parseError">
		<cfoutput>#ide.displayError("There was an error parsing your document. Please ensure that your text selection is valid Balsamiq Mockups .bbml.")#</cfoutput>
		<cfabort>
	</cfcatch>
</cftry>

<!--- generate output --->
<cfset renderer = new org.gilt.renderer("html")>
<cfset renderer.setReader(reader)> 

<!--- send output to IDE --->
<cfheader name="Content-Type" value="text/xml">
<cfoutput>#ide.insertText(renderer.output())#</cfoutput>

<cfsetting enablecfoutputonly="false">