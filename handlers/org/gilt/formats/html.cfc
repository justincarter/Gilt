<cfcomponent accessors="true">

	<cfproperty name="renderer">

	<cfset CRLF = chr(13) & chr(10)>
	<cfset TAB = chr(9)>


	<cffunction name="init">
		<cfargument name="renderer" required="true">
		<cfset variables.renderer = arguments.renderer>
		<cfreturn this>	
	</cffunction>


	<cffunction name="getComboBox">
		<cfargument name="name">
		<cfargument name="control">

		<cfset var out = "">

		<!--- combobox start --->
		<cfset out &= renderer.getControlOutput(name & "Start", control)>
		<!--- combobox options --->
		<cfloop list="#control.text#" delimiters="#CRLF#" index="item">
			<cfset var stItem.item = item>
			<cfset out &= renderer.getControlOutput(name & "Option", stItem)>
		</cfloop> 
		<!--- combobox end --->
		<cfset out &= renderer.getControlOutput(name & "End", control)>

		<cfreturn out>
	</cffunction>
	
</cfcomponent>