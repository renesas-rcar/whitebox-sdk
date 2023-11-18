#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import asyncio
import websockets
import time
import json
from datetime import datetime

# settings
dest_url = "ws://localhost:3000"

# get unixtime
def get_unixtime():
    now = datetime.now()
    return (int)(now.timestamp() * 1000)

base_json_data = {
	"Ver": "001",
	"Timestamp": 1678443770610,
	"geometry": {
		"coordinates": {
			"Latitude": 40.76445,
			"Longitude": -73.98926,
			"Altitude": 16.563,
			"HorizAccu": 1.3,
			"AltAccu": 1.3,
			"Heading": 301.207,
			"HeadingAccu": 2.7,
			"Speed": 7.5,
			"SpeedAccu": 0.7
		}
	},
	"RunningStatus": {
		"Acceleration": {
			"X": 0,
			"Y": -0.002,
			"Z": 0.252
		},
		"Vehicle": {
			"Speed": 27358
		},
		"Engine": {
			"Speed": 2973
		},
		"Brake": {
			"PedalPosition": 0
		},
		"Accelerator": {
			"PedalPosition": 100
		},
		"Fuel": {
			"Level": 60
		},
		"SteeringWheel": {
			"Angle": 0
		},
		"Transmission": {
			"Gear": 3
		},
		"ParkingBrake": {
			"IsEngaged": False
		},
		"Battery": {
			"Capacity": 90
		}
	},
	"Body": {
		"Door": {
			"FrontLeft": {
				"IsOpen": False,
				"IsLocked": True,
				"WindowPosition": 100,
				"IsMirrorOpen": True
			},
			"FrontRight": {
				"IsOpen": False,
				"IsLocked": True,
				"WindowPosition": 100,
				"IsMirrorOpen": True
			},
			"RearLeft": {
				"IsOpen": False,
				"IsLocked": True,
				"WindowPosition": 100
			},
			"RearRight": {
				"IsOpen": False,
				"IsLocked": True,
				"WindowPosition": 100
			}
		},
		"Bonnet": {
			"IsOpen": False
		},
		"Trunk": {
			"IsOpen": False
		},
		"Light": {
			"IsHazardOn": False,
			"IsLowBeamOn": False,
			"IsHighBeamOn": False,
			"IsFrontFogOn": False,
			"IsRearFogOn": False
		},
		"Wiper": {
			"Front": {
				"Status": "medium"
			},
			"Rear": {
				"Status": "off"
			}
		},
		"FuelCap": {
			"IsOpen": False
		}
	},
	"Cabin": {
		"Seat": {
			"FrontLeft": {
				"Recline": 90,
				"IsSeatbeltOn": True,
				"IsAirbagDeployed": False
			},
			"FrontRight": {
				"Recline": 90,
				"IsSeatbeltOn": True,
				"IsAirbagDeployed": False
			},
			"RearLeft": {
				"Recline": 90,
				"IsSeatbeltOn": True
			},
			"RearRight": {
				"Recline": 90,
				"IsSeatbeltOn": True
			}
		},
		"HVAC": {
			"FrontLeft": {
				"Temperature": 23
			},
			"FrontRight": {
				"Temperature": 23
			},
			"RearLeft": {
				"Temperature": 23
			},
			"RearRight": {
				"Temperature": 23
			},
			"AmbientAir": {
				"Temperature": 28
			}
		},
		"Sunroof": {
			"Position": 100
		}
	},
	"DriveTrain": {
		"Tire": {
			"FrontLeft": {
				"Pressure": 350
			},
			"FrontRight": {
				"Pressure": 350
			},
			"RearLeft": {
				"Pressure": 350
			},
			"RearRight": {
				"Pressure": 350
			}
		},
		"ADAS": {
			"SuspensionMode": "Nomal",
			"ABS": False
		},
		"OBD": {
			"OilLevel": 100,
			"CoolantTemperature": 35
		}
	},
	"Navigation": {
		"SpeedLimit": 40,
		"Turn": {
			"Direction": "",
			"Angle": 0
		},
		"Curve": {
			"Direction": "",
			"Level": ""
		}
	},
	"Event": {
		"Unstable": False,
		"RedLight": False,
		"Tire": False,
		"Pedestrian": False,
		"Accident": False,
		"Approaching": {
            "Front": False,
			"Rear": False,
			"RearRight": False,
			"RearLeft": False,
    	}
    }
}

import random
# main
async def start():
    async with websockets.connect(dest_url) as websocket:
        send_list = []
        # get telemetry data from json file
        json_data = base_json_data.copy()

        _d = json.dumps(json_data)
        d = json.loads(_d)
        send_list.append(d)

        print("telemetry_data num:" + str(len(send_list)))

        # send at 1 second interval
        while True:
            for data in send_list:
                data['Timestamp'] = get_unixtime()
                data["RunningStatus"]["Vehicle"]["Speed"] = random.randint(0,180)* 1000
                data["RunningStatus"]["Engine"]["Speed"] = random.randint(0,7000)
                data["RunningStatus"]["Fuel"]["Level"] = random.randint(0,100)
                data["RunningStatus"]["Transmission"]["Gear"] = random.randint(-1,3)
                data["RunningStatus"]["Battery"]["Capacity"] = random.randint(0,100)
                simformat = {'arg': ''}
                simformat['arg'] = data
                jsonstr = json.dumps(simformat)
                await websocket.send(jsonstr)
                await asyncio.sleep(0)  # yield control to the event loop

                print("send: " + json.dumps(data))
                time.sleep(1)


if __name__ == "__main__":
    asyncio.get_event_loop().run_until_complete(start())
