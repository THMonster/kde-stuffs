/*
 *   Copyright 2016 David Edmundson <davidedmundson@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.2

import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "../components"

SessionManagementScreen {

    property Item mainPasswordBox: passwordBox
    property bool lockScreenUiVisible: false

    //the y position that should be ensured visible when the on screen keyboard is visible
    property int visibleBoundary: mapFromItem(loginButton, 0, 0).y
    onHeightChanged: visibleBoundary = mapFromItem(loginButton, 0, 0).y + loginButton.height + units.smallSpacing
    /*
     * Login has been requested with the following username and password
     * If username field is visible, it will be taken from that, otherwise from the "name" property of the currentIndex
     */
    signal loginRequest(string password)

    function startLogin() {
        var password = passwordBox.text

        //this is partly because it looks nicer
        //but more importantly it works round a Qt bug that can trigger if the app is closed with a TextField focused
        //See https://bugreports.qt.io/browse/QTBUG-55460
        loginButton.forceActiveFocus();
        loginRequest(password);
    }

    RowLayout {
        id: pwRow
        state: lockScreenRoot.uiVisible ? "on" : "off"
        Layout.fillWidth: true
        Layout.leftMargin: units.gridUnit * 2

        states: [
            State {
                name: "on"

                PropertyChanges {
                    target: pwRow
                    opacity: 0.9
                }

                /* PropertyChanges { */
                /*     target: passwordBox */
                /*     y: 0 */
                /* } */

            },
            State {
                name: "off"
                PropertyChanges {
                    target: pwRow
                    opacity: 0
                }

                /* PropertyChanges { */
                /*     target: passwordBox */
                /*     y: 40 */
                /* } */

            }
        ]

        transitions: [
            Transition {
                from: "*"
                to: "on"

                /* PathAnimation { */
                /*     target: passwordBox */
                /*     easing.type: Easing.OutQuart */
                /*     duration: 500 */
                /*     path: Path { */
                /*         startX: units.gridUnit * 1.5; startY: passwordBox.y+10 */
                /*         PathLine {} */
                /*     } */
                /* } */


                SequentialAnimation {
                    PauseAnimation {
                        duration: 350
                    }
                    ParallelAnimation {
                        NumberAnimation {
                            target: pwRow
                            property: "y"
                            duration: 500
                            from: 40
                            to: 0
                            /* easing.type: Easing.InOutQuad */
                            easing.type: Easing.OutQuart
                        }
                        NumberAnimation {
                            target: pwRow
                            property: "opacity"
                            duration: 500
                            /* easing.type: Easing.InOutQuad */
                            easing.type: Easing.OutQuart
                        }
                    }
                }
            },
            Transition {
                from: "*"
                to: "off"

                /* PathAnimation { */
                /*     target: passwordBox */
                /*     easing.type: Easing.OutQuart */
                /*     duration: 500 */
                /*     path: Path { */
                /*         /\* startX: passwordBox.x; startY: passwordBox.y+10 *\/ */
                /*         PathLine {x: units.gridUnit * 1.5; y: passwordBox.y+10} */
                /*     } */
                /* } */

                SequentialAnimation {
                    PauseAnimation {
                        duration: 350
                    }
                    ParallelAnimation {
                        NumberAnimation {
                            target: pwRow
                            property: "y"
                            duration: 500
                            from: 0
                            to: -40
                            /* easing.type: Easing.InOutQuad */
                            easing.type: Easing.OutQuart
                        }
                        NumberAnimation {
                            target: pwRow
                            property: "opacity"
                            duration: 500
                            easing.type: Easing.OutQuart
                        }
                    }
                }
            }
        ]

        PlasmaComponents.TextField {
            id: passwordBox
            /* Layout.alignment: Qt.AlignHCenter */
            /* Layout.fillWidth: true */
            /* Layout.rightMargin: 50 */
            /* Layout.alignment: Qt.AlignCenter */
            /* Layout.alignment: Qt.AlignRight */
            /* Layout.leftMargin: units.gridUnit * 2 */
            Layout.preferredWidth: units.gridUnit * 12
            /* Layout.preferredHeight: units.gridUnit * 1.5 */
            /* x: units.gridUnit * 1.5 */

            /* anchors { */
            /*     horizontalCenter: parent.horizontalCenter */
            /* } */

            placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password")
            focus: true
            /* opacity: 0.8 */
            echoMode: TextInput.Password
            inputMethodHints: Qt.ImhHiddenText | Qt.ImhSensitiveData | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            enabled: !authenticator.graceLocked
            revealPasswordButtonShown: true

            onAccepted: {
                if (lockScreenUiVisible) {
                    startLogin();
                }
            }

            style: TextFieldStyle {
                /* textColor: passwordFieldOutlined ? "white" : "black" */
                /* placeholderTextColor: passwordFieldOutlined ? "white" : "black" */
                /* passwordCharacter: config.PasswordFieldCharacter == "" ? "●" : config.PasswordFieldCharacter */

                background: Rectangle {
                    radius: 3
                    /* implicitWidth: mainBlock.width * 0.13 */
                    /* implicitWidth: units.gridUnit * 12 */
                    implicitHeight: units.gridUnit * 1.5
                    /* border.color: "white" */
                    /* border.width: 1 */
                    /* color: passwordFieldOutlined ? "transparent" : "white" */
                }

            }

            //if empty and left or right is pressed change selection in user switch
            //this cannot be in keys.onLeftPressed as then it doesn't reach the password box
            Keys.onPressed: {
                if (event.key == Qt.Key_Left && !text) {
                    userList.decrementCurrentIndex();
                    event.accepted = true
                }
                if (event.key == Qt.Key_Right && !text) {
                    userList.incrementCurrentIndex();
                    event.accepted = true
                }
            }

            Keys.onReleased: {
                if (loginButton.opacity == 0 && length > 0) {
                    showLoginButton.start()
                }
                if (loginButton.opacity > 0 && length == 0) {
                    hideLoginButton.start()
                }
            }

            Connections {
                target: root
                onClearPassword: {
                    passwordBox.forceActiveFocus()
                    passwordBox.selectAll()
                }
            }
        }

        Image {
            id: loginButton
            source: "../components/artwork/login.svgz"
            smooth: true
            sourceSize: Qt.size(passwordBox.height, passwordBox.height)

            /* color: black */

            /* anchors { */
            /*     left: passwordBox.right */
            /*     verticalCenter: passwordBox.verticalCenter */
            /* } */

            /* anchors.leftMargin: 8 */
            visible: opacity > 0
            opacity: 0
            MouseArea {
                anchors.fill: parent
                onClicked: startLogin();
            }
            PropertyAnimation {
                id: showLoginButton
                target: loginButton
                properties: "opacity"
                to: 0.75
                duration: 100
            }
            PropertyAnimation {
                id: hideLoginButton
                target: loginButton
                properties: "opacity"
                to: 0
                duration: 80
            }
        }
    }

    /* PlasmaComponents.Button { */
    /*     id: loginButton */
    /*     Layout.fillWidth: true */
    /*     text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Unlock") */
    /*     onClicked: startLogin() */
    /* } */

}
