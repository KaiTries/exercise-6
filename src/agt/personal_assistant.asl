// personal assistant agent

/* Initial goals */ 
artificial_light(1).
natural_light(0).
best_option(Option):- Option = 0.





// beliefs and inferenes needed for the CNP
taskId(1). // to keep track of CNP tasks
noOneWon(false). // to identify once both options where used
triedDweets(0). // to keep track of the number of dweets sent

all_proposals_received(CNPId,NP) :-              // NP = number of participants
     .count(propose(CNPId,_)[source(_)], NO) &   // number of proposes received
     .count(refuse(CNPId)[source(_)], NR) &      // number of refusals received
     NP = NO + NR.



// The agent has the goal to start
!start.

// setup for CNP
!register.
+!register <- .df_register(initiator).

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: true (the plan is always applicable)
 * Body: greets the user
*/
@start_plan
+!start : true <-
    !setupTool(C).
    //!useDweet("HelloItsMe").

@create_dweetArtifact_plan
+!setupTool(C): true <- 
    makeArtifact("c0","room.DweetArtifact",[],C).

@send_dweet_plan
+!useDweet(Action, Receiver, Performative, Content): true <-
    sendDweet(Action, Receiver, Performative, Content).

@calender_now_owner_awake_plan
+calendarState("now"): owner_state("awake") <- 
    .print("Enjoy your event").

@owner_awake_calender_now_plan
+owner_state("awake"): calendarState("now") <- 
    .print("Enjoy your event").

@calendar_now_owner_asleep_plan
+calendarState("now"): owner_state("asleep") & noOneWon(false) <-
    .print("Starting wake up routine");
    !wakeUpRoutine.

@owner_asleep_calendar_now_plan
+owner_state("asleep"): calendarState("now") & noOneWon(false) <-
    .print("Starting wake up routine");
    !wakeUpRoutine.



@calendar_now_owner_asleep_noOneWon_plan
+calendarState("now"): owner_state("asleep") & noOneWon(true) & triedDweets(Num) & Num < 5 <-
    .print("Tried both raising blinds and turning on the lights. Messaging a friend for help.");
    -+triedDweets(Num + 1);
    !useDweet(send, "alice, bob, eve", achieve, help_friend_to_wake_up(kai)).


@start_wakeUpRoutine_plan
+!wakeUpRoutine: true & taskId(Num) <-
    !cnp(Num, "increaseIlluminance");
    -+taskId(Num + 1).

@cnp
+!cnp(Id,Task) <- 
    !call(Id,Task,LP);
    !bid(Id,LP);
    !winner(Id,LO,WAg);
    !result(Id,LO,WAg).


/* 
 * Plan for reacting to the addition of the goal !cnp
 * Triggering event: addition of goal !cnp
 * Context: true (the plan is always applicable)
 * Body: starts the CNP
*/
@cnp_plan
+!call(Id,Task,LP) <- 
    .print("Waiting participants for task ",Task,"...");
    .wait(2000);  // wait participants introduction
    .df_search("participant",LP);
    .print("Sending CFP to ",LP);
    .send(LP,tell,cfp(Id,Task)).

+!bid(Id,LP) <- // the deadline of the CNP is now + 4 seconds (or all proposals received)
    .wait(all_proposals_received(Id,.length(LP)), 4000, _).


/*
We do not need to set a prefered wakeup method if we just write the plan for the prefered method first since this will be the 
plan that is called first. -> Implicit ordering of plans
*/
+!winner(Id,LO,WAg) : .findall(offer(set_blinds("raised"),A),propose(Id,set_blinds("raised"))[source(A)],LO) & LO \== [] <- // there is a offer
    .print("Offers are ",LO);
    .min(LO,offer(WOf,WAg)); // the first offer is the best
    .print("Winner is ",WAg," with ",WOf).

+!winner(Id,LO,WAg) : .findall(offer(set_lights("on"),A),propose(Id,set_lights("on"))[source(A)],LO) & LO \== [] <- // there is a offer
    .print("Offers are ",LO);
    .min(LO,offer(WOf,WAg)); // the first offer is the best
    .print("Winner is ",WAg," with ",WOf).


+!winner(_,_,nowinner) <-
    -+noOneWon(true); // flag that no one won
    .print("no winner. Asking a friend for help"); // no offer case
    !useDweet(send, "alice, bob, eve", achieve, help_friend_to_wake_up(kai)).


+!result(_,[],_).
+!result(CNPId,[offer(_,WAg)|T],WAg) <- // announce result to the winner
    .send(WAg,tell,accept_proposal(CNPId));
    !result(CNPId,T,WAg).

+!result(CNPId,[offer(_,LAg)|T],WAg) <- // announce to others
    .send(LAg,tell,reject_proposal(CNPId));
    !result(CNPId,T,WAg).

    
/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }