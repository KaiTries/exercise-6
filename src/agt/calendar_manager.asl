// calendar manager agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService (was:CalendarService)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/calendar-service.ttl").

/* Initial goals */ 
calenderState("now").

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:CalendarService is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService", Url) <-
    .print("Hello world");
    makeArtifact("calender", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId);
    !read_calender. // creates the goal



@read_owner_state_plan
+!read_calender : true <-
    // performs an action that exploits the TD Property Affordance of type was:ReadOwnerState 
    // the action unifies OwnerStateLst with a list holding the owner's state, e.g. ["asleep"]
    readProperty("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#ReadUpcomingEvent",  UpcomingEventList);
    .nth(0,UpcomingEventList,CalenderState); // performs an action that unifies OwnerState with the element of the list OwnerStateLst at index 0
    -+calenderState(CalenderState); // updates the beleif owner_state 
    .wait(5000);
    !read_calender. // creates the goal !read_owner_state

/* 
 * Plan for reacting to the addition of the belief !owner_state
 * Triggering event: addition of belief !owner_state
 * Context: true (the plan is always applicable)
 * Body: announces the current state of the owner
*/
@owner_state_plan
+calenderState(State) : true <-
    .print("The calender is ", State).


/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }
