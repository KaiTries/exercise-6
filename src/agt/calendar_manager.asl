// calendar manager agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService (was:CalendarService)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/calendar-service.ttl").

/* Initial goals */ 
calenderState(_).

// The agent has the goal to start
!start.

@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService", Url) <-
    makeArtifact("calender", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId);
    !read_calendar.

+!read_calendar : true <-
    readProperty("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#ReadUpcomingEvent",  UpcomingEventList);
    .nth(0,UpcomingEventList,CalendarState); 
    -+calendarState(CalendarState); 
    .wait(5000);
    !read_calendar. 

+calendarState(State) : true <-
    .send(personal_assistant,untell,calendarState(_)); // removes the current belief about the calendar state from the personal assistant
    .send(personal_assistant,tell,calendarState(State)); // updates the personal assistant about the current calendar state
    .print("The event is ", State).


/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }
