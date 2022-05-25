extends Node

# default list of events
var default_events:Dictionary = {
	"": 
		load(Paths.event("Nothing")).instance(),
	"Hey!": 
		load(Paths.event("Hey!")).instance(),
	"Add Camera Zoom": 
		load(Paths.event("Add Camera Zoom")).instance(),
}
