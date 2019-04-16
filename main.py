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
import os
import yaml

import tornado.gen
import tornado.ioloop
import webapp2
from nats.io.client import Client as NATS

class NatsHandler(webapp2.RequestHandler):
    def get(self, event_type):
        tornado.ioloop.IOLoop.current().run_sync(lambda: self.handler(event_type))
        self.response.headers['Content-Type'] = 'application/json'
        self.response.write(json.dumps({"status": "200"}))

    @tornado.gen.coroutine
    def handler(arg, event_type):
        nc = NATS()
        try:
            natServers = {
                "sandbox": "nats://sandbox-nats.my.andela.com:4222",
                "staging": "nats://staging-nats.my.andela.com:4222",
                "qa": "nats://qa-nats.my.andela.com:4222",
                "production": "nats://nats.my.andela.com:4222"
            }

            source = yaml_to_json(os.getcwd() + "/template.cron.yaml")
            servers = []
            for task in source["cron"]:
                if event_type in task['url']:
                    environments = task['targetEnvironment'].split(",")
                    for environment in environments:
                        servers.append(natServers[environment.strip()])

            opts = {"servers": servers}
            yield nc.connect(**opts)
            message = {
                "eventType": event_type
            }
            yield nc.publish("crons", str(message))
            yield nc.flush()
            print("Successfully published to '{0}', message: {1}".format("crons", message))
        except Exception, e:
            print(e)

def yaml_to_json(sourceFile):
    with open(sourceFile, "r") as stream:
        try:
            return yaml.load(stream)
        except yaml.YAMLError as exc:
            print(exc)
            return False

app = webapp2.WSGIApplication([
    webapp2.Route(r'/publish/<event_type>', handler=NatsHandler)
], debug=True)



