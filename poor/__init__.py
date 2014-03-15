# -*- coding: utf-8 -*-

# Copyright (C) 2014 Osmo Salomaa
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

"""An application to display maps and stuff."""

__version__ = "0.0"

from poor.paths import *
from poor import util

from poor.config import *
conf = ConfigurationStore()

from poor.tilecollection import *
from poor.tilesource import *
from poor.application import *

def main():
    """Initialize application."""
    import http.server
    import pyotherside
    import threading
    conf.read()
    pyotherside.atexit(conf.write)
    global app
    app = Application()
    # Start our own bogus tile server, see qml/MapPlugin.qml.
    from poor.server import NullHandler
    httpd = http.server.HTTPServer(("127.0.0.1", 64409), NullHandler)
    thread = threading.Thread(target=httpd.serve_forever, daemon=True)
    thread.start()