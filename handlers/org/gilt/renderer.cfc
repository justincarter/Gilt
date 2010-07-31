<cfcomponent accessors="true">

	<cfproperty name="reader">
	<cfproperty name="renderFormat">
	<cfproperty name="formatXML">
	<cfproperty name="formatCFC">

	<cfset CRLF = chr(13) & chr(10)>
	<cfset TAB = chr(9)>


	<cffunction name="init">
		<cfargument name="format" default="html">
		<cfset setRenderFormat(arguments.format)>
		<cfreturn this>	
	</cffunction>

	
	<cffunction name="setRenderFormat">
		<cfargument name="format">
		
		<cfset renderFormat = arguments.format>

		<!--- get control templates from format xml/cfc files --->
		<cfset var formatPath = "#GetDirectoryFromPath(GetCurrentTemplatePath())#/formats">
		<cffile action="read" file="#formatPath#/#renderFormat#.xml" variable="formatXML">
		<cfset formatXML = xmlParse(formatXML)>
		<cfif fileExists("#formatPath#/#renderFormat#.cfc")>
			<cfset formatCFC = createObject("component", "org.gilt.formats.#renderFormat#").init(this)>
		</cfif>

	</cffunction>


	<cffunction name="processTemplate">
		<cfargument name="node">
		<cfargument name="control">
		
		<!--- get template --->
		<cfset var tpl = node.xmlText>
		
		<!--- trim template to avoid whitespace, add a trailing space --->
		<cfset var str = trim(tpl) & " ">
		
		<!--- find template variables --->
		<cfset matches = reMatch("{{(.*?)}}", str)>

		<cfloop array="#matches#" index="item">
			<!--- strip braces from template variable name --->
			<cfset var name = replace(replace(item, "{{", ""), "}}", "")>
			<!--- replace variable with value if found in control struct --->
			<cfif isDefined("control.#name#")>
				<cfset str = replace(str, "{{#name#}}", control[name])>
			<!--- replace variable with value if found in custom data struct --->
			<cfelseif isDefined("control.json.#name#")>
				<cfset str = replace(str, "{{#name#}}", control.json[name])>
			</cfif>
		</cfloop>
	
		<cfreturn str>
	</cffunction>

	<cffunction name="getControlOutput">
		<cfargument name="name">
		<cfargument name="control">

		<cfset tpl = "">
		<!--- get control template nodes from XML --->
		<cfset var tplNodeArray = xmlSearch(formatXML, "format/control[@name='#arguments.name#']")>
		
		<cfif arrayLen(tplNodeArray)>
			<!--- get template node --->
			<cfset node = tplNodeArray[1]>
			<!--- replace template variables with values from controls query --->
			<cfset tpl = processTemplate(node, arguments.control)>
			<!--- append CRLF --->
			<cfif isDefined("node.xmlAttributes.crlf") AND node.xmlAttributes.crlf eq "true">
				<cfset tpl &= CRLF> 
			</cfif> 
			<!--- prefix with indent level --->
			<cfif isDefined("node.xmlAttributes.indent")>
				<cfset tpl = RepeatString(TAB, node.xmlAttributes.indent) & tpl> 
			</cfif> 
		</cfif>

		<cfreturn tpl>	
	</cffunction>
	
	
	<cffunction name="output">

		<!--- get controls from reader --->
		<cfset var qControls = duplicate(variables.reader.getControls())>
	
		<!--- loop over controls to build output --->
		<cfset var out = "">
		<cfset var outCustom = "">
		<cfset var outDefault = "">
		
		<cfoutput query="qControls" group="y">

			<!--- start of row --->
			<cfset outRow = "">

			<!--- process each control on the row --->		
			<cfoutput>

				<!--- get control name --->
				<cfset var name = qControls.control>
	
				<!--- get control struct from query row --->
				<cfset var stControl = getControlStruct(qControls)>
			
				<!--- append output for this control --->
				<cfif isDefined("formatCFC.get#name#")>
					<!--- custom processing --->
					<cfinvoke component="#formatCFC#" method="get#name#" returnvariable="outCustom">
						<cfinvokeargument name="name" value="#name#">
						<cfinvokeargument name="control" value="#stControl#">
					</cfinvoke>
					<cfif trim(outCustom) neq "">
						<cfset outRow &= outCustom>
					</cfif> 
				<cfelse>
					<!--- default processing --->
					<cfset outDefault = getControlOutput(name, stControl)>
					<cfif trim(outDefault) neq "">
						<cfset outRow &= outDefault>
					</cfif> 
				</cfif>
			
				<!--- set processed flag--->
				<cfset querySetCell(qControls, "processed", true, qControls.currentRow)>

			</cfoutput>
			
			<!--- end of row --->
			<cfif len(outRow)>
				<!--- TODO: add logic for when a row should be wraped with rowstart and rowend templates --->
				<cfset rowStart = getControlOutput("RowStart", {})>
				<cfif len(rowStart)>
					<cfset outRow = rowStart & outRow>
				</cfif>
				<cfset rowEnd = getControlOutput("RowEnd", {})>
				<cfif len(rowEnd)>
					<cfset outRow &= rowEnd>
				</cfif>
				<cfset out &= outRow>
				<cfset out &= CRLF>
			</cfif>

		</cfoutput>
		
		<cfreturn out>
	</cffunction>


	<cffunction name="getControlStruct">
		<cfargument name="qry">
		
		<!--- convert query row into struct --->
		<cfset var st = {}>
		<cfloop list="#qry.columnList#" index="item">
			<cfset st[item] = qry[item][qry.currentRow]>		
		</cfloop> 

		<cfreturn st>
	</cffunction>

</cfcomponent>