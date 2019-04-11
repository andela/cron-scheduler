# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import json
import sys
sys.path.append("./lib")

import time

import tornado.gen
import tornado.ioloop
import webapp2
from nats.io.client import Client as NATS

class NatsHandler(webapp2.RequestHandler):
    def get(self, event_type):
        tornado.ioloop.IOLoop.current().run_sync(self.handler)
        self.response.headers['Content-Type'] = 'application/json'
        self.response.write(json.dumps({"status": "200"}))

    @tornado.gen.coroutine
    def handler(arg):
        nc = NATS()
        try:
            opts = {"servers": ["nats://foo:bar@localhost:4222"]}
            yield nc.connect(**opts)
            yield nc.publish("Test", {})
            yield nc.flush()
            print("Published to '{0}', message: {1}".format("Test", {}))
        except Exception, e:
            print(e)

app = webapp2.WSGIApplication([
    webapp2.Route(r'/publish/<event_type>', handler=NatsHandler)
], debug=True)



