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

    Scene {
        id: scene

        // the "logical size" - the scene content is auto-scaled to match the GameWindow size
        width: 320
        height: 480

        // background rectangle matching the logical scene size (= safe zone available on all devices)
        // see here for more details on content scaling and safe zone: https://v-play.net/doc/vplay-different-screen-sizes/
        Rectangle {
            id: rectangle
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
                x: Math.round(utils.generateRandomValueBetween(0,3))* rec.width

                NumberAnimation on y {
                    from: 0 // start at the top
                    to: 480//scene.bottom // move the tapObject to the bottom of the screen
                    duration: 1000 // it takes the Objects 1 Second to get to the bottom of the screen
                    onStopped: {
                        console.debug("monster reached base - change to gameover scene because the player lost")
                        //   changeToGameOverScene(false)
                    }
                }

                Rectangle{
                    id: rec
                    color: "red"
                    // keep the size responsive depending on the display size
                    width: scene.width/4;
                    height: scene.height/8;
                    x: 0
                    y: 0

                }


                MouseArea {
                    anchors.fill: parent
                    onClicked: {

                    }
                }// MouseArea

                function tapped(){
                    rectangle.color = "black";
                }
            }// EntityBase
        }// Component


        Timer {
            running: scene.visible == true && splashFinished // only enable the creation timer, when the gameScene is visible
            repeat: true
            interval: 1000 // a new target(=monster) is spawned every second
            onTriggered: {scene.spawnTapObject()}
        }

        function spawnTapObject() {
            console.debug("spqwn");
            entityManager.createEntityFromComponent(tapComponent)
        }
    }

}
