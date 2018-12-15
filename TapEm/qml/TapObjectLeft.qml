import VPlay 2.0
import QtQuick 2.0

EntityBase {
   // property int xPos: Math.round(utils.generateRandomValueBetween(0,3))
    property int xPos : Math.round(utils.generateRandomValueBetween(0,1))// Math.round(utils.generateRandomValueBetween(0,1)) : Math.round(utils.generateRandomValueBetween(2,3))
    entityType: "tapEntity" // required for removing all of these entities when the game is lost

    // generates integer values for x between 0 and 3 (incl.)
    x: xPos * tapObject.width

    NumberAnimation on y {
        from: 0-tapObject.height // start at the top
        to: 480//scene.bottom // move the tapObject to the bottom of the screen
        duration: 3000 // the time it takes the object to reach the bottom in milliseconds
        onStopped: {
            isGameLost(tapObject.tapped) // if the Object has reached the bottom of the screen without being tapped the game is lost
        }
    }

    Rectangle{
        property bool tapped : false
        id: tapObject

        // if the red rectangle gets tapped it turns black
        color: tapped ? "black" : "white"
        // keep the size responsive depending on the display size
        width: playScene.width/4
        height: playScene.width/2
        radius: width*0.5

        MouseArea {
            anchors.fill: parent
            onClicked: {tapObject.objectTapped()}
        }
        function objectTapped() {
            if(!tapObject.tapped){ // only increase the score the first time the objects gets tapped
                gameWindow.score++;
            }

            tapObject.tapped = true;
        }


    }
}// EntityBase
