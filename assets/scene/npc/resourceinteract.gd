extends Resource

export (String) var alias_name
export (bool) var greeting = true
export (String,"single","branch","option") var greeting_type= "single"
export (Array,String) var greeting_option
export (Array,String) var greeting_callback
export (String) var greeting_key = "greet"
export (bool) var bye = true
export (String) var bye_key = "bye"

##==========================
#Create custom interactions. There needs to be a reply from
#the greeting_callback variable. The shape is like this:
#if callback option return "quest2"
#	quest2:
#		{
#			type: "single/branch/option",
#			option: []
#			callback: []
#		}
##===========================

export (Dictionary) var custom_interact
