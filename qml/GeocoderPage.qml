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
import "."

Dialog {
    id: dialog
    allowedOrientations: app.defaultAllowedOrientations
    property string pid: py.evaluate("poor.app.geocoder.id")
    SilicaListView {
        id: listView
        anchors.fill: parent
        delegate: ListItem {
            id: listItem
            contentHeight: nameLabel.height + descriptionLabel.height
            ListItemLabel {
                id: nameLabel
                color: (model.active || listItem.highlighted) ?
                    Theme.highlightColor : Theme.primaryColor;
                height: implicitHeight + Theme.paddingMedium
                text: model.name
                verticalAlignment: Text.AlignBottom
            }
            ListItemLabel {
                id: descriptionLabel
                anchors.top: nameLabel.bottom
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                height: implicitHeight + 1.5*Theme.paddingMedium
                text: "%1\nSource: %2\n%3".arg(model.description).arg(model.source).arg(model.attribution)
                verticalAlignment: Text.AlignTop
                wrapMode: Text.WordWrap
            }
            onClicked: {
                dialog.pid = model.pid;
                dialog.accept();
            }
        }
        header: DialogHeader {}
        model: ListModel {}
        VerticalScrollDecorator {}
        Component.onCompleted: {
            // Load geocoder model entries from the Python backend.
            var defpid = app.conf.getDefault("geocoder");
            py.call("poor.util.get_geocoders", [], function(geocoders) {
                for (var i = 0; i < geocoders.length; i++) {
                    if (geocoders[i].pid === defpid)
                        geocoders[i].name = "%1 (default)".arg(geocoders[i].name);
                    listView.model.append(geocoders[i]);
                }
            });
        }
    }
    onAccepted: {
        py.call_sync("poor.app.set_geocoder", [dialog.pid]);
    }
}
