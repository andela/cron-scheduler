#!/usr/bin/env python

import os
import yaml

def from_yaml(sourceFile):
    with open(sourceFile, "r") as stream:
        try:
            return yaml.load(stream)
        except yaml.YAMLError as exc:
            print(exc)
            return False

def to_yaml(destinationFile, data):
    with open(destinationFile, "w+") as outfile:
        try:
            yaml.dump(data, outfile, default_flow_style=False)
            return True
        except yaml.YAMLError as exc:
            print(exc)
            return False

def generate_cron_file():
    source = from_yaml(os.getcwd() + "/template.cron.yaml")
    for task in source["cron"]:
        environment = task["targetEnvironment"]
        task["description"] += " in " + environment + " environment"
        del task["targetEnvironment"]

    to_yaml(os.getcwd() + "/cron.yaml", source)

generate_cron_file()