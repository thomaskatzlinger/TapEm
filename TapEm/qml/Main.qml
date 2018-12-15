import VPlay 2.0
import QtQuick 2.0

GameWindow {
    id: gameWindow

    activeScene: startScreen

    screenWidth: 640
    screenHeight: 960

    // Possible values for gameState: wait, play, gameOver
    property string gameState: "wait"


    // create a licenseKey to hide the splash screen
    property bool splashFinished: false
    onSplashScreenFinished: { splashFinished = true}


    property int score: 0

    property color customGrey: "#222222"

    property bool spawnOnLeftSide: true


    /* The Start Screen is shown at the beginning of the game. If it gets tapped the Game starts */
    Scene{
        id: startScreen

        // the "logical size" - the scene content is auto-scaled to match the GameWindow size
        width: 320
        height: 480

        Rectangle {
            id:backgroundStart
            anchors.fill: parent
            color:customGrey

            Text{
                anchors.centerIn: parent
                color: "white"
                text: "< Tap to Start >"
            }
        }

        // start the Game on Click
        MouseArea{
            anchors.fill: parent
            onPressed: {startGame()}
        }

    }

    /* The Play Scene is the actual Game. */
    Scene {
        id: playScene
        visible: false

        onVisibleChanged: {
            if(visible) {
                timerLeft.start()  // start the timers on play
                timerRight.start()
            }
        }

        // the "logical size" - the scene content is auto-scaled to match the GameWindow size
        width: 320
        height: 480

        Rectangle {
            id: background
            anchors.fill: parent
            color: customGrey
        }

        // for creating entities at runtime dynamically
        EntityManager {
            id: entityManager
            entityContainer: playScene
        }

        /* There are two different types of Components. tapLeftComponents only spawn on the left side of the Screen
        *  and the other way around.
        *  This way it is not possible that more than two tapObjects spawn at the same time.
        *  The reason for that is that the player should always be able to play the game with two fingers (thumbs) only.
        */
        Component{
            id: tapLeftComponent

            TapObjectLeft{
                id: tapLeftEntityBase
            }
        }// Component

        Component{
            id: tapRightComponent

            TapObjectRight{
                id: tapRightEntityBase
            }
        }// Component


        Timer {
            id: timerLeft
            running: playScene.visible == true && splashFinished // only enable the creation timer, when the gameScene is visible
            repeat: true
            interval: utils.generateRandomValueBetween(1000, 3000) // a new tap object is spawned
            onTriggered: {spawnTapObject(true)}
        }

        Timer {
            id: timerRight
            running: playScene.visible == true && splashFinished // only enable the creation timer, when the gameScene is visible
            repeat: true
            interval: utils.generateRandomValueBetween(1000, 3000) // a new tap object is spawned
            onTriggered: {spawnTapObject(false)}
        }
    }// Play Scene

    // Spawn a new TapOject ether on the left or the right half of the screen
    function spawnTapObject(left) {
        if(left){
            gameWindow.spawnOnLeftSide = true;
            entityManager.createEntityFromComponent(tapLeftComponent)
        }
        else{
            gameWindow.spawnOnLeftSide = false;
            entityManager.createEntityFromComponent(tapRightComponent)
        }
    }

    // isGameLost gets called whenever a TapObject reaches the bottom of the screen
    // if the Object has not been tapped at least once the game is over
    function isGameLost(tapped){
        if(!tapped){
            stopGame();
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

        MouseArea{
            anchors.fill: parent
            onClicked: {if(visible){playScene.gameState = "wait"}}
        }

        onVisibleChanged: {
            if(visible) {
                returnToGameSceneTimer.start()  // make the scene invisible after 3 seconds, after it got visible
            }
        }

        Timer {
            id: returnToGameSceneTimer
            interval: 3000
            onTriggered: {restartGame()}
        }

    }// GameOver Scene


    /* ------------ Game State Handling ------------*/

    function startGame() {
        gameWindow.gameState = "play"
        startScreen.visible = false
        playScene.visible = true
    }

    function stopGame() {
        gameWindow.gameState = "gameOver"
        gameOverScene.visible = true
        playScene.visible = false
    }

    // unnecessary at the time but keept for later extensions
    function restartGame(){
        gameWindow.gameState = "play"
        playScene.visible = true
        gameOverScene.visible = false
        gameWindow.score = 0
    }
}

