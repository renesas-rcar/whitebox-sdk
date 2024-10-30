import datetime
import json
import numpy
import boto3

class DummyTemperatureSensor(object):
    def __init__(self, loc=25, scale=1, size=1):
        self.loc = loc
        self.scale = scale
        self.size = size

    def get_value(self):
        return numpy.random.normal(self.loc, self.scale, self.size)[0]


def lambda_handler(event, context):
    print(event)
    # AWS IoT connection
    iot = boto3.client('iot-data', endpoint_url='https://xxxxxxxxxxxxxxx-ats.iot.ap-southeast-1.amazonaws.com')
    # get temperature
    sensor = DummyTemperatureSensor()
    # set publish paramater
    topic='topic/sensor/temperature'
    payload = {
        "timestamp": str( datetime.datetime.now() ),
        "temperature": sensor.get_value()
    }
    print(payload)
    # publish to AWS IoT
    iot.publish(
        topic=topic,
        qos=0,
        payload=json.dumps(payload, ensure_ascii=False)
    )

