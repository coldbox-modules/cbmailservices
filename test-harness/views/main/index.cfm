<cfoutput>
<h1>CB Mail Services</h1>
<cfdump var="#prc.mailResults#" label="Mail Results">
<cfdump var="#prc.mailservices.getTokenMarker()#" label="Token Marker">
<cfdump var="#prc.mailservices.getMailers().keyArray()#" label="Mailers">
</cfoutput>