// lights controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights (was:Lights)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/lights.ttl").

// The agent initially believes that the lights are "off"
lights("off").

/* Initial goals */ 
!register.

+!register <- .df_register("participant");
              .df_subscribe("initiator").

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Lights is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", Url) <-
    makeArtifact("lights", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId).

+!set_lights(LightsState) : true <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", [LightsState]);
    -+lights(LightsState).

+lights(State) : true <-
    .send(personal_assistant,tell,lights(State)); // tell the new belief
    .print("The lights are ", State).




// answer to Call For Proposal
+cfp(CNPId,Task)[source(personal_assistant)]:  provider(personal_assistant,"initiator") & lights("off") <- 
    +proposal(CNPId,Task,set_lights("on")); // remember my proposal
    .send(personal_assistant,tell,propose(CNPId,set_lights("on"))).

// plan to refuse a Call For Proposal
+cfp(CNPId,_Service)[source(personal_assistant)]:  provider(personal_assistant,"initiator") & lights("on") <- 
    .send(personal_assistant,tell,refuse(CNPId)).


// plan if I won the Call For Proposal
+accept_proposal(CNPId): proposal(CNPId,Task,Offer) <- 
    .print("My proposal '",Offer,"' won CNP ",CNPId, " for ",Task,"!");
    !Offer. // do the task


// plan if I lost the Call For Proposal 
+reject_proposal(CNPId) <- 
    .print("I lost CNP ",CNPId, ".");
    -proposal(CNPId,_,_). // clear memory




/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }