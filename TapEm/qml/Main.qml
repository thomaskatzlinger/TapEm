import VPlay 2.0
import QtQuick 2.0
import QtGraphicalEffects 1.0


GameWindow {
    id: gameWindow

    activeScene: startScreen

    screenWidth: 640
    screenHeight: 960

    // Possible values for gameState: wait, play, gameOver
    property string gameState: "wait"

    property int score: 0

    /* The Start Screen is shown at the beginning of the game. If it gets tapped the Game starts */
    Scene{
        id: startScreen

        // the "logical size" - the scene content is auto-scaled to match the GameWindow size
        width: 320
        height: 480

        Rectangle {
            id:backgroundStart
            anchors.fill: parent
            // color:customGrey

            // RadialGradient doesn't work properly for some reason; possible bug?
            RadialGradient{
                anchors.fill: parent
                GradientStop {
                    position: 0.0
                    color: "#FF0000"
                }
                GradientStop {
                    position: 0.1
                    color: "#00FF00"
                }
                GradientStop {
                    position: 1.0
                    color: "#0000FF"
                }
            }

            // it is important that Text is declared after RadialGradient because otherwise
            // it would be in the background  and therefore could not be seen
            Text {
                //   anchors.top:  parent
                y: parent.height/8*2.5
                x: parent.width/2 - width/2 // horizontal center

                color: "Black"
                font.family: "Futura"
                font.bold: true
                font.pointSize: 40

                text: "Tap 'em"
            }
            Text {
                id: tapToStart
                // anchors.bottom: parent
                y: (parent.height/8*5)
                x: parent.width/2 - width/2 // horizontal center

                color: "Black"
                font.family: "Futura"
                font.bold: true

                text: "< Tap to Start >"
                font.pointSize: 8
            }

            // This animation make the tapToStart Text pulsate
            SequentialAnimation{
                running: true
                loops: Animation.Infinite
                NumberAnimation {
                    target: tapToStart
                    property: "font.pointSize"
                    duration: 200
                    from: 8
                    to: 11
                }
                NumberAnimation {
                    target: tapToStart
                    property: "font.pointSize"
                    duration: 200
                    from: 11
                    to: 8
                }
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
            color: "#222222"
        }

        Text {
            x: parent.width/2 - width/2 // horizontal center
            y: 10
            color: "white"
            text:"Score: " + score
            font.family: "Futura"
            font.bold: true

            z: 100 // force to display on top meaning it's always visible
        }

        // for creating entities at runtime dynamically
        EntityManager {
            id: entityManager
            entityContainer: playScene
        }


        Component{
            id: tapComponent

            TapObject{
                id: tapEntityBase
            }
        }// Component


        /*
        *  There are two different Timers.
        *  This way it is not possible that more than two tapObjects spawns at the same time on each half of the screen.
        *  The reason for that is that the player should always be able to play the game with two fingers (thumbs) only.
        */

        // Spawn Timer for the left half
        Timer {
            id: timerLeft
            property double rdm : utils.generateRandomValueBetween(600-score*10, 1000-score*5) // decreases difficulty over time
            running: playScene.visible == true// only enable the creation timer, when the gameScene is visible
            repeat: true
            interval: rdm > 100 ? rdm : 100  /// makes sure the spawn interval does not drop below 100
            onTriggered: {spawnTapObject([0,1])}

        }

        // Spawn Timer for the right half
        Timer {
            id: timerRight
            property double rdm : utils.generateRandomValueBetween(600-score*10, 1000-score*5) // decreases difficulty over time

            running: playScene.visible == true// only enable the creation timer, when the gameScene is visible
            repeat: true
            interval: rdm > 100 ? rdm : 100  // makes sure the spawn interval does not drop below 100
            onTriggered: {spawnTapObject([2,3])}
        }
    }// Play Scene

    function spawnTapObject(boarder) {
        var rdm = utils.generateRandomValueBetween(600-score*10, 1000-score*5);
        if(boarder[0] === 0){
            timerLeft.interval = rdm > 100 ? rdm : 100
        }else{
            timerRight.interval = rdm > 100 ? rdm : 100
        }

        entityManager.createEntityFromComponentWithProperties(tapComponent, {x: Math.round(utils.generateRandomValueBetween(boarder[0],boarder[1]))*playScene.width/4})
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

        // the "logical size" - the scene content is auto-scaled to match the GameWindow size
        width: 320
        height: 480


        Rectangle{
            id: bgGameOver
            color: "white"
            anchors.fill: parent
        }

        Text {
            y: parent.height/8*2.5
            x: parent.width/2 - width/2 // horizontal center

            color: "black"
            font.family: "futura"

            text:"Score: " + score
        }

        Text {
            id: tapToRestart

            y: (parent.height/8*5)
            x: parent.width/2 - width/2 // horizontal center

            color: "Black"
            font.family: "Futura"
            font.bold: true

            text: "You can do better than that!\n\n< Restarting in 3 Seconds... >"
            font.pointSize: 8
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

    // unnecessary at this moment in the time but keept for later extensions
    function restartGame(){
        gameWindow.score = 0
        gameWindow.gameState = "play"
        gameOverScene.visible = false
        playScene.visible = true
    }
}

