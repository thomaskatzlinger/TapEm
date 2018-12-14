import VPlay 2.0
import QtQuick 2.0

GameWindow {
    id: gameWindow

    // You get free licenseKeys from https://v-play.net/licenseKey
    // With a licenseKey you can:
    //  * Publish your games & apps for the app stores
    //  * Remove the V-Play Splash Screen or set a custom one (available with the Pro Licenses)
    //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)
    //licenseKey: "<generate one from https://v-play.net/licenseKey>"

    activeScene: scene

    // the size of the Window can be changed at runtime by pressing Ctrl (or Cmd on Mac) + the number keys 1-8
    // the content of the logical scene size (480x320 for landscape mode by default) gets scaled to the window size based on the scaleMode
    // you can set this size to any resolution you would like your project to start with, most of the times the one of your main target device
    // this resolution is for iPhone 4 & iPhone 4S
    screenWidth: 640
    screenHeight: 960

    // create a licenseKey to hide the splash screen
    property bool splashFinished: false
    onSplashScreenFinished: { splashFinished = true}


    property int score: 0


    Scene {
        id: scene

        // the "logical size" - the scene content is auto-scaled to match the GameWindow size
        width: 320
        height: 480

        // background rectangle matching the logical scene size (= safe zone available on all devices)
        // see here for more details on content scaling and safe zone: https://v-play.net/doc/vplay-different-screen-sizes/
        Rectangle {
            id: background
            anchors.fill: parent
            color: "grey"
        }

        // for creating entities (monsters and projectiles) at runtime dynamically
        EntityManager {
            id: entityManager
            entityContainer: scene
        }


        Component{
            id: tapComponent


            EntityBase {
                entityType: "tapEntity" // required for removing all of these entities when the game is lost

                // generates integer values for x between 0 and 3 (incl.)
                x: Math.round(utils.generateRandomValueBetween(0,3)) * rec.width

                NumberAnimation on y {
                    from: 0 // start at the top
                    to: 480//scene.bottom // move the tapObject to the bottom of the screen
                    duration: 3000 // the time it takes the object to reach the bottom in milliseconds
                    onStopped: {
                        isGameLost(rec.tapped)
                        // changeToGameOverScene(checkIfLost)
                    }
                }

                Rectangle{
                    property bool tapped : false
                    id: rec

                    // if the red rectangle gets tapped it turns black
                    color: tapped ? "black" : "red"
                    // keep the size responsive depending on the display size
                    width: scene.width/4;
                    height: scene.height/8;


                    MouseArea {
                        anchors.fill: parent
                        onClicked: {rec.objectTapped()}
                    }
                    function objectTapped() {
                        if(!rec.tapped){ // only increase the score the first time the objects gets tapped
                            gameWindow.score++;
                        }

                        rec.tapped = true;
                    }
                }





            }// EntityBase
        }// Component


        Timer {
            running: scene.visible == true && splashFinished // only enable the creation timer, when the gameScene is visible
            repeat: true
            interval: 1000 // a new target(=monster) is spawned every second
            onTriggered: {spawnTapObject()}
        }



    }

    function spawnTapObject() {
        console.debug("spawn");
        entityManager.createEntityFromComponent(tapComponent)
    }
    function isGameLost(tapped){
        if(!tapped){
            console.debug("You lost.");

            gameOverScene.visible = true
            scene.visible = false
        }
    }

    // switch to this scene, after the game was lost or won and it switches back to the gameScene after 3 seconds
    Scene {
        id: gameOverScene
        visible: false
        Rectangle{
            id: bgGameOver
            color: "white"
            anchors.fill: parent
        }

        Text {
            anchors.centerIn: parent
            color: "black"
            text:"Score: " + score
        }

        onVisibleChanged: {
            if(visible) {
                returnToGameSceneTimer.start()  // make the scene invisible after 3 seconds, after it got visible
            }
        }

        Timer {
            id: returnToGameSceneTimer
            interval: 3000
            onTriggered: {
                scene.visible = true
                gameOverScene.visible = false
                gameWindow.score = 0
            }
        }
    }// GameOverScene
}
