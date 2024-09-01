let Teams = []


function start(){ 
    let noOfTeams = Teams.length
    initLevel = Math.floor(Math.log2(noOfTeams)) + 1;
    const match = document.getElementById("match");
    match.innerHTML = "";
    createMatch(initLevel);
}

function addTeam(){
    var team = document.getElementById("inputTeams");
    let printTeams = document.getElementById("Teams");
    Teams.push(team.value);
    team.value = "";
    let displayTeam = document.createElement("div");
    displayTeam.innerHTML = Teams[Teams.length - 1];
    printTeams.appendChild(displayTeam);
}

function deleteTeam(){
    if(Teams == "") return;
    Teams.pop();
    let printTeams = document.getElementById("Teams");
    printTeams.removeChild(printTeams.lastChild);
}

function createMatch(initLevel){
    var tempLevel = initLevel; 
    while(tempLevel>1){
        tempLevel--;
        createNewLevel(tempLevel); 
    }
}


function createNewLevel(level){
    if(level<1)
        return;
    var newLevelDiv = document.createElement("div");
    newLevelDiv.classList.add("level");
    newLevelDiv.textContent = "level: "+level;
    newLevelDiv.id = level;
    for(let noOfVs = 2 ** (level-1); noOfVs > 0; noOfVs--){
        requestAnimationFrame(() => createNewVs(noOfVs * 2, newLevelDiv, level));
        console.log("noOfVs",noOfVs);
    }
    match.appendChild(newLevelDiv);
}

function createNewVs(noOfVs, newLevelDiv, level){
    let noOfTeams = Teams.length
    let initLevel = Math.floor(Math.log2(noOfTeams)) + 1;
    let newVs = document.createElement("div");
    newVs.classList.add("vs");
    newVs.id = "vs" + noOfVs;
    console.log("init",initLevel);
    if(newLevelDiv.id == initLevel - 1){
        requestAnimationFrame(() => createNewBracket([noOfVs - 1], newVs, true, level));
        requestAnimationFrame(() => createNewBracket([noOfVs - 2], newVs, true, level));
    }
    else{
        requestAnimationFrame(() => createNewBracket([noOfVs - 1], newVs, false, level));
        requestAnimationFrame(() => createNewBracket([noOfVs - 2], newVs, false, level));
    }
     newLevelDiv.append(newVs);
}


function createNewBracket(index, newVs, show, level){
    let newBracket = document.createElement("button");
    newBracket.classList.add("bracket");
    newBracket.id = level + "s" + index.toString()
    newBracket.addEventListener("click",winner_bracket);
    if(show){
        newBracket.innerHTML = Teams[index];
    }
    else{
        newBracket.innerHTML = "";
    }
    newVs.append(newBracket);
}


function winner_bracket(){

    const clickedBracket = event.target;
    const vsDiv = clickedBracket.parentElement;
    const parentLevelDiv = vsDiv.parentElement;
    let parentLevelId = parseInt((parentLevelDiv.id));

    if(parentLevelId == 1){
        const buttons = vsDiv.querySelectorAll(".bracket");
        buttons.forEach(button => button.classList.remove("final"));
        clickedBracket.classList.toggle("final");
        return;
    }

    const buttons = vsDiv.querySelectorAll(".bracket");
    buttons.forEach(button => button.classList.remove("winner"));
    clickedBracket.classList.toggle("winner");

    let clickedBracketId = clickedBracket.id.split("s")[1];
    const nextLevel = document.getElementById((parentLevelId - 1).toString());
    const nextWinnerId = nextLevel.id + "s" +Math.floor(parseInt(clickedBracketId) / 2).toString();
    const nextWinner = document.getElementById(nextWinnerId)
    nextWinner.innerHTML = clickedBracket.innerHTML;
    console.log(nextWinner);
}



// -------------------------------------------------------------------------

var input = document.getElementById("inputTeams");

input.addEventListener("keypress", function(event) {
  if (event.key === "Enter") {
    event.preventDefault();
    document.getElementById("add").click();
  }
});
