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
import Sailfish.Silica 1.0

Column {
    id: column
    ComboBox {
        id: timetypeComboBox
        label: "Bind"
        menu: ContextMenu {
            MenuItem { text: "Departure" }
            MenuItem { text: "Arrival" }
        }
        property var keys: ["departure", "arrival"]
        Component.onCompleted: {
            page.params.timetype = "departure";
            var index = timetypeComboBox.keys.indexOf(page.params.timetype);
            timetypeComboBox.currentIndex = index;
        }
        onCurrentIndexChanged: {
            var index = timetypeComboBox.currentIndex;
            page.params.timetype = timetypeComboBox.keys[index];
        }
    }
    ValueButton {
        id: dateButton
        label: "Date"
        value: "Today"
        property var date: new Date()
        onClicked: {
            var dialog = pageStack.push(
                "Sailfish.Silica.DatePickerDialog", {
                    date: dateButton.date
                });
            dialog.accepted.connect(function() {
                dateButton.date = dialog.date;
                dateButton.value = dialog.dateText;
                // Journey Planner wants date in format YYYYMMDD.
                var year = dialog.year.toString();
                var month = dialog.month.toString();
                var day = dialog.day.toString();
                if (month.length < 2) month = "0%1".arg(month);
                if (day.length < 2) day = "0%1".arg(day);
                page.params.date = year + month + day;
            });
        }
    }
    ValueButton {
        id: timeButton
        label: "Time"
        value: "Now"
        property var time: new Date()
        onClicked: {
            var dialog = pageStack.push(
                "Sailfish.Silica.TimePickerDialog", {
                    "hourMode": DateTime.TwentyFourHours,
                    "hour": time.getHours(),
                    "minute": time.getMinutes()
                });
            dialog.accepted.connect(function() {
                timeButton.time = dialog.time;
                timeButton.value = dialog.timeText;
                // Journey Planner wants time in format HHMM.
                var hour = dialog.hour.toString();
                var minute = dialog.minute.toString();
                if (hour.length < 2) hour = "0%1".arg(hour);
                if (minute.length < 2) minute = "0%1".arg(minute);
                page.params.time = hour + minute;
            });
        }
    }
    ComboBox {
        id: prefComboBox
        label: "Criterion"
        menu: ContextMenu {
            MenuItem { text: "Default" }
            MenuItem { text: "Fastest" }
            MenuItem { text: "Least transfers" }
            MenuItem { text: "Least walking" }
        }
        property var keys: ["default", "fastest", "least_transfers", "least_walking"]
        Component.onCompleted: {
            var key = app.conf.get("routers.hsl.optimize");
            prefComboBox.currentIndex = prefComboBox.keys.indexOf(key);
        }
        onCurrentIndexChanged: {
            var index = prefComboBox.currentIndex;
            app.conf.set("routers.hsl.optimize", prefComboBox.keys[index]);
        }
    }
    Row {
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin - Theme.paddingLarge/2
        height: implicitHeight + Theme.paddingLarge
        Repeater {
            id: repeater
            model: 5
            property var keys: ["bus", "tram", "metro", "train", "uline"]
            property string option: "routers.hsl.transport_types"
            IconButton {
                id: vehicleSwitch
                height: icon.sourceSize.height + 2*Theme.paddingLarge
                icon.opacity: checked ? 0.9 : 0.3
                icon.source: app.getIcon("hsl/%1".arg(repeater.keys[index]))
                width: icon.sourceSize.width + Theme.paddingLarge
                property bool checked: false
                Component.onCompleted: {
                    vehicleSwitch.checked = app.conf.setContains(
                        repeater.option, repeater.keys[index]);
                }
                onClicked: {
                    vehicleSwitch.checked = !vehicleSwitch.checked;
                    vehicleSwitch.checked ?
                        app.conf.setAdd(repeater.option, repeater.keys[index]) :
                        app.conf.setRemove(repeater.option, repeater.keys[index]);
                    if (repeater.keys[index] === "bus") {
                        // Include service lines when toggling bus use.
                        vehicleSwitch.checked ?
                            app.conf.setAdd(repeater.option, "service") :
                            app.conf.setRemove(repeater.option, "service");
                    }
                }
            }
        }
    }
}
