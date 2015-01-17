/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtLocation 5.0
import Sailfish.Silica 1.0

MapQuickItem {
    id: marker
    anchorPoint.x: movingImage.width/2
    anchorPoint.y: movingImage.height/2
    coordinate: map.position.coordinate
    visible: map.ready
    sourceItem: Item {
        Image {
            id: movingImage
            rotation: map.direction || 0
            source: "icons/position-direction.png"
            visible: map.direction || false
        }
        Image {
            id: stillImage
            anchors.centerIn: movingImage
            source: "icons/position.png"
            visible: !movingImage.visible
        }
        MouseArea {
            anchors.fill: movingImage
            onClicked: {
                if (app.conf.get("auto_center")) {
                    app.conf.set("auto_center", false);
                    map.autoCenter = false;
                    bubble.message = "Auto-center off";
                } else {
                    app.conf.set("auto_center", true);
                    map.autoCenter = true;
                    map.centerOnPosition();
                    bubble.message = "Auto-center on";
                }
                bubble.visible = true;
                timer.restart();
            }
        }
        Rectangle {
            id: bubble
            anchors.bottom: movingImage.top
            anchors.bottomMargin: 18
            anchors.horizontalCenter: movingImage.horizontalCenter
            color: "#bb000000"
            height: label.height + Theme.paddingLarge
            radius: label.font.pixelSize/2
            visible: false
            width: label.width + 1.5*Theme.paddingLarge
            property string message: ""
            Label {
                id: label
                anchors.centerIn: bubble
                color: "white"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                text: bubble.message
            }
        }
        Image {
            id: arrow
            anchors.top: bubble.bottom
            // Try to avoid a stripe between bubble and arrow.
            anchors.topMargin: -0.5
            anchors.horizontalCenter: bubble.horizontalCenter
            source: "icons/bubble-arrow.png"
            visible: bubble.visible
        }
        Timer {
            id: timer
            interval: 2000
            onTriggered: bubble.visible = !bubble.visible;
        }
    }
    z: 300
}
