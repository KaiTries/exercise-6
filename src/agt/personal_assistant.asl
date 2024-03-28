// personal assistant agent

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: true (the plan is always applicable)
 * Body: greets the user
*/
@start_plan
+!start : true <-
    .print("Hello world");
    !setupTool(C);
    !useDweet("HelloItsMe").


+!setupTool(C): true <- 
    makeArtifact("c0","room.DweetArtifact",[],C).


+!useDweet(Dweet): true <-
    .print("Sending dweet ",Dweet);
    sendDweet(Dweet,Response);
    .print("The response is ",Response).

    
/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }