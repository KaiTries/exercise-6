// blinds controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds (was:Blinds)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/blinds.ttl").

// the agent initially believes that the blinds are "lowered"
blinds("lowered").

/* Initial goals */ 
!register.

+!register <- .df_register("participant");
              .df_subscribe("initiator").

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Blinds is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", Url) <-
    makeArtifact("blinds", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId).

@blinds_plan
+!set_blinds(BlindsState) : true <-
    .println("Setting blinds to ", BlindsState);
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", [BlindsState]);
    -+blinds(BlindsState).

+blinds(State) : true <-
    .send(personal_assistant,tell,blinds(State)); // tell the new belief
    .print("The blinds are ", State).



// answer to Call For Proposal
+cfp(CNPId,Task)[source(personal_assistant)]:  provider(personal_assistant,"initiator") & blinds("lowered") <- 
    +proposal(CNPId,Task,set_blinds("raised")); // remember my proposal
    .send(personal_assistant,tell,propose(CNPId,set_blinds("raised"))).

// plan to refuse a CFP
+cfp(CNPId,_Service)[source(personal_assistant)]:  provider(personal_assistant,"initiator") & blinds("raised") <- 
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