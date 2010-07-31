<cfcomponent accessors="true">

	<cfproperty name="text">
	<cfproperty name="controls">
	

	<cffunction name="init">
		<cfargument name="text" default="">
		<cfset variables.text = arguments.text>	
	</cffunction>


	<cffunction name="parse">
		<cfargument name="text" default="#variables.text#">
		
		<cfif NOT isXML(arguments.text)>
			<cfthrow type="gilt.bbmlReader.parseError" message="BBML input must be valid XML">
		</cfif>
		
		<!--- parse BBML --->
		<cfset var xml = xmlParse(arguments.text)>
		<cfset var aControls = xml.mockup.controls>

		<!--- store controls in a query object --->
		<cfset controls = queryNew("control,text,id,data,x,y,rawX,rawY,processed,json")>
		<cfloop from="1" to="#arrayLen(aControls.xmlChildren)#" index="i">
			
			<!--- get control attributes --->
			<cfset var control = aControls.xmlChildren[i]>
			<cfset var controlName = replace(control.xmlAttributes.controlTypeID, "com.balsamiq.mockups::", "", "all")>
			<cfset var controlText = isNull(control.controlProperties.text) ? "" : URLDecode(control.controlProperties.text.xmlText)>
			<!--- get custom control ID / Data (controlData must be URL decoded twice for some reason) --->
			<cfset var controlID = isNull(control.controlProperties.customID) ? "" : URLDecode(control.controlProperties.customID.xmlText)>
			<cfset var controlData = isNull(control.controlProperties.customData) ? "" : URLDecode(URLDecode(control.controlProperties.customData.xmlText))>

			<!--- snap control x and y coordinates to nearest multiple of 32 --->
			<cfset var controlX = int(round(control.xmlAttributes.x / 16) / 2) * 32>
			<cfset var controlY = int(round(control.xmlAttributes.y / 16) / 2) * 32>
		
			<!--- add control properties to query --->
			<cfset queryAddRow(controls)>
			<cfset querySetCell(controls, "control", controlName)>
			<cfset querySetCell(controls, "text", controlText)>
			<cfset querySetCell(controls, "id", controlID)>
			<cfset querySetCell(controls, "data", controlData)>
			<cfset querySetCell(controls, "x", controlX)>
			<cfset querySetCell(controls, "y", controlY)>
			<cfset querySetCell(controls, "rawX", control.xmlAttributes.x)>
			<cfset querySetCell(controls, "rawY", control.xmlAttributes.y)>
			<cfset querySetCell(controls, "processed", false)>

		</cfloop>
		
		<!--- reorder controls from top to bottom, left to right --->
		<cfquery name="controls" dbtype="query">
			SELECT *
			FROM controls
			ORDER BY y, x	
		</cfquery>
		
		<!--- deserialize JSON in custom data --->
		<cfloop query="controls">
			<cfif isJSON(controls.data)>
				<cfset querySetCell(controls, "json", deserializeJSON(controls.data), controls.currentRow)>
			</cfif>
		</cfloop>

		<cfreturn controls>
	</cffunction>

</cfcomponent>