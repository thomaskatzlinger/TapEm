import VPlay 2.0
import QtQuick 2.0
import QtGraphicalEffects 1.0

EntityBase {
    // property int xPos: Math.round(utils.generateRandomValueBetween(0,3))
    property int xPos : Math.round(utils.generateRandomValueBetween(2,3))// Math.round(utils.generateRandomValueBetween(0,1)) : Math.round(utils.generateRandomValueBetween(2,3))
    entityType: "tapEntity" // required for removing all of these entities when the game is lost

    // generates integer values for x between 0 and 3 (incl.)
    x: xPos * tapObject.width

    NumberAnimation on y {
        property double dur : 3000 - score*score;
        from: 0-tapObject.height // start at the top
        to: 480//scene.bottom // move the tapObject to the bottom of the screen
        duration: dur > 500 ? dur : 500 // the time it takes the object to reach the bottom in milliseconds
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

        // Objects getting tapped and then disappear
        PropertyAnimation {
            id: anim
            target: tapObject
            property: "color"
            to: "#00222222"
            duration: 300

        }

        RadialGradient {
            anchors.fill: parent
            gradient: Gradient {

                GradientStop {
                    position: 0.0
                    color: "#00111111"
                }
                GradientStop {
                    position: 1.0
                    color: "#FF222222"
                }
            }
        }// RadialGradient



        function objectTapped() {
            if(!tapObject.tapped){ // only increase the score the first time the objects gets tapped
                gameWindow.score++;
                anim.running = true;
            }

            tapObject.tapped = true;
        }


    }
}// EntityBase
