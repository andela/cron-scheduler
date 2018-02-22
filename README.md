# Cron Scheduler
In distributed systems, such as a suite of microservices, it is challenging to for each service to manage their own jobs and setup cron services.

Google AppEngine provides a Cron service. Using this service for scheduling and
Google Cloud Pub/Sub for distributed messaging, we can build an application to
reliably schedule tasks across a suite of microservices.

Check out this [write up](https://cloud.google.com/solutions/reliable-task-scheduling-compute-engine) for more details about this design pattern.

## How it works

This scheduler contains two components:

* An App Engine application, that uses App Engine Cron Service
    to relay cron messages to Cloud Pub/Sub topics.

* An event handler logic on any microservice. A service monitors a Cloud Pub/Sub
    topic. When it detects a new message with a defined eventType, it runs the corresponding command
    locally on the service.

You specify the cron messages to send in the `cron.yaml` file of the App Engine
application. This file is written in
[YAML format](http://cloud.google.com/appengine/docs/python/config/cron#Python_app_yaml_About_cron_yaml).
The App Engine application publishes all events to `cron` topic.It uses the event-type URL param as the event type. For example, if an event handler is specified as `url: /publish/USER_CREATED_EVENT`, the Cloud Pub/Sub topic name
will remain `cron` while the event type is `USER_CREATED_EVENT`.

When the Cron Service fires a scheduled event, the App Engine
application handles the request and passes the cron message to the corresponding
Cloud Pub/Sub topic. If the specified Cloud Pub/Sub topic does not exist,
the App Engine application creates it.

The event handler on the service receives cron messages from
Cloud Pub/Sub and runs the specified handler function that are normally run by cron.

## How to run the scheduler
The overview for configuring and running this sample is as follows:

1. Create a project and other cloud resources.
2. Clone or download this code.
3. Specify cron jobs in a YAML file.
4. Deploy the App Engine application.


### Specify cron jobs

App Engine Cron Service job descriptions are specified in `cron.yaml`, a file in
the App Engine application. You define tasks for App Engine Task Scheduler
in [YAML format](http://yaml.org/). The following example
shows the syntax.

    cron:
      - description: <description of the job>
               url: /events/<event type to publish>
               schedule: <frequency in human-readable format>

For a complete description of how to use YAML to specify jobs for Cron Service,
including the schedule format, see
[Scheduled Tasks with Cron for Python](https://cloud.google.com/appengine/docs/python/config/cron#Python_app_yaml_The_schedule_format).

Leave the default cron.yaml as is for now to run through the sample.

### Upload the application to App Engine

In order for the App Engine application to schedule and relay your events,
you must upload it to a Developers Console project. This is the project
that you created in **Prerequisites**.

1. Configure the `gcloud` command-line tool to use the project you created in
    Prerequisites.

        $ gcloud config set project <your-project-id>

    Where you replace `<your-project-id>`  with the identifier of your cloud
    project.

1. Include the Python API client in your App Engine application.

        $ pip install -t lib -r requirements.txt

    Note: if you get an error and used Homebrew to install Python on OS X,
    see [this fix](https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Homebrew-and-Python.md#note-on-pip-install---user).

1. Create an App Engine App

		$ gcloud app create

1. Deploy the application to App Engine.

        $ gcloud app deploy --version=1 app.yaml cron.yaml

After you deploy the App Engine application it uses the App Engine Cron Service
to schedule sending messages to Cloud Pub/Sub. If a Cloud Pub/Sub topic
specified in `cron.yaml` does not exist, the application creates it.

You can see the cron jobs under in the console under:

Compute > App Engine > Task queues > Cron Jobs

You can also see the auto-created topic (after about a minute) in the console:

Big Data > Pub/Sub
