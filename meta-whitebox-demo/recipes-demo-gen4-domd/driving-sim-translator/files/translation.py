#!/usr/bin/env python3
# -*- coding: utf-8 -*-

def translate_body(arg):
    return [
        # arg.Body.Bonnet.IsOpen
        {
            'path': 'Vehicle.Private.Body.Bonnet.IsOpen',
            'value': arg['Bonnet']['IsOpen']
        },
        # arg.Body.Door.FrontLeft.IsLocked
        {
            'path': 'Vehicle.Cabin.Door.Row1.Left.IsLocked',
            'value': arg['Door']['FrontLeft']['IsLocked']
        },
        # arg.Body.Door.FrontLeft.IsMirrorOpen
        {
            'path': 'Vehicle.Body.Mirrors.Left.Pan',
            # If closed, return -100, which means "Fully Right Position".
            'value': -100 if not arg['Door']['FrontLeft']['IsMirrorOpen'] else 0
        },
        # arg.Body.Door.FrontLeft.IsOpen
        {
            'path': 'Vehicle.Cabin.Door.Row1.Left.IsOpen',
            'value': arg['Door']['FrontLeft']['IsOpen']
        },
        # arg.Body.Door.FrontLeft.WindowPosition
        {
            'path': 'Vehicle.Cabin.Door.Row1.Left.Window.Position',
            'value': int(arg['Door']['FrontLeft']['WindowPosition'])
        },
        # arg.Body.Door.FrontRight.IsLocked
        {
            'path': 'Vehicle.Cabin.Door.Row1.Right.IsLocked',
            'value': arg['Door']['FrontRight']['IsLocked']
        },
        # arg.Body.Door.FrontRight.IsMirrorOpen
        {
            'path': 'Vehicle.Body.Mirrors.Right.Pan',
            # If closed, return 100, which means "Fully Left Position".
            'value': 100 if not arg['Door']['FrontRight']['IsMirrorOpen'] else 0
        },
        # arg.Body.Door.FrontRight.IsOpen
        {
            'path': 'Vehicle.Cabin.Door.Row1.Right.IsOpen',
            'value': arg['Door']['FrontRight']['IsOpen']
        },
        # arg.Body.Door.FrontRight.WindowPosition
        {
            'path': 'Vehicle.Cabin.Door.Row1.Right.Window.Position',
            'value': int(arg['Door']['FrontRight']['WindowPosition'])
        },
        # arg.Body.Door.RearLeft.IsLocked
        {
            'path': 'Vehicle.Cabin.Door.Row2.Left.IsLocked',
            'value': arg['Door']['RearLeft']['IsLocked']
        },
        # arg.Body.Door.RearLeft.IsOpen
        {
            'path': 'Vehicle.Cabin.Door.Row2.Left.IsOpen',
            'value': arg['Door']['RearLeft']['IsOpen']
        },
        # arg.Body.Door.RearLeft.WindowPosition
        {
            'path': 'Vehicle.Cabin.Door.Row2.Left.Window.Position',
            'value': int(arg['Door']['RearLeft']['WindowPosition'])
        },
        # arg.Body.Door.RearRight.IsLocked
        {
            'path': 'Vehicle.Cabin.Door.Row2.Right.IsLocked',
            'value': arg['Door']['RearRight']['IsLocked']
        },
        # arg.Body.Door.RearRight.IsOpen
        {
            'path': 'Vehicle.Cabin.Door.Row2.Right.IsOpen',
            'value': arg['Door']['RearRight']['IsOpen']
        },
        # arg.Body.Door.RearRight.WindowPosition
        {
            'path': 'Vehicle.Cabin.Door.Row2.Right.Window.Position',
            'value': int(arg['Door']['RearRight']['WindowPosition'])
        },
        # arg.Body.FuelCap.IsOpen
        {
            'path': 'Vehicle.Private.Body.FuelCap.IsOpen',
            'value': arg['FuelCap']['IsOpen']
        },
        # arg.Body.Light.IsFrontFogOn
        {
            'path': 'Vehicle.Body.Lights.IsFrontFogOn',
            'value': arg['Light']['IsFrontFogOn']
        },
        # arg.Body.Light.IsHazardOn
        {
            'path': 'Vehicle.Body.Lights.IsHazardOn',
            'value': arg['Light']['IsHazardOn']
        },
        # arg.Body.Light.IsHighBeamOn
        {
            'path': 'Vehicle.Body.Lights.IsHighBeamOn',
            'value': arg['Light']['IsHighBeamOn']
        },
        # arg.Body.Light.IsLowBeamOn
        {
            'path': 'Vehicle.Body.Lights.IsLowBeamOn',
            'value': arg['Light']['IsLowBeamOn']
        },
        # arg.Body.Light.IsRearFogOn
        {
            'path': 'Vehicle.Body.Lights.IsRearFogOn',
            'value': arg['Light']['IsRearFogOn']
        },
        # arg.Body.Trunk.IsOpen
        {
            'path': 'Vehicle.Body.Trunk.IsOpen',
            'value': arg['Trunk']['IsOpen']
        },
        # arg.Body.Wiper.Front.Status
        {
            'path': 'Vehicle.Body.Windshield.Front.Wiping.Status',
            'value': arg['Wiper']['Front']['Status']
        },
        # arg.Body.Wiper.Rear.Status
        {
            'path': 'Vehicle.Body.Windshield.Rear.Wiping.Status',
            'value': arg['Wiper']['Rear']['Status']
        }
    ]


def translate_cabin(arg):
    return [
        # arg.Cabin.HVAC.AmbientAir.Temperature
        {
            'path': 'Vehicle.Cabin.HVAC.AmbientAirTemperature',
            'value': float(arg['HVAC']['AmbientAir']['Temperature'])
        },
        # arg.Cabin.HVAC.FrontLeft.Temperature
        {
            'path': 'Vehicle.Cabin.HVAC.Station.Row1.Left.Temperature',
            'value': int(arg['HVAC']['FrontLeft']['Temperature'])
        },
        # arg.Cabin.HVAC.FrontRight.Temperature
        {
            'path': 'Vehicle.Cabin.HVAC.Station.Row1.Right.Temperature',
            'value': int(arg['HVAC']['FrontRight']['Temperature'])
        },
        # arg.Cabin.HVAC.RearLeft.Temperature
        {
            'path': 'Vehicle.Cabin.HVAC.Station.Row2.Left.Temperature',
            'value': int(arg['HVAC']['RearLeft']['Temperature'])
        },
        # arg.Cabin.HVAC.RearRight.Temperature
        {
            'path': 'Vehicle.Cabin.HVAC.Station.Row2.Right.Temperature',
            'value': int(arg['HVAC']['RearRight']['Temperature'])
        },
        # arg.Cabin.Seat.FrontLeft.IsAirbagDeployed
        {
            'path': 'Vehicle.Cabin.Seat.Row1.Pos1.Airbag.IsDeployed',
            'value': arg['Seat']['FrontLeft']['IsAirbagDeployed']
        },
        # arg.Cabin.Seat.FrontLeft.IsSeatbeltOn
        {
            'path': 'Vehicle.Cabin.Seat.Row1.Pos1.IsBelted',
            'value': arg['Seat']['FrontLeft']['IsSeatbeltOn']
        },
        # arg.Cabin.Seat.FrontLeft.Recline
        {
            'path': 'Vehicle.Cabin.Seat.Row1.Pos1.Recline',
            'value': int(arg['Seat']['FrontLeft']['Recline'])
        },
        # arg.Cabin.Seat.FrontRight.IsAirbagDeployed
        {
            'path': 'Vehicle.Cabin.Seat.Row1.Pos2.Airbag.IsDeployed',
            'value': arg['Seat']['FrontRight']['IsAirbagDeployed']
        },
        # arg.Cabin.Seat.FrontRight.IsSeatbeltOn
        {
            'path': 'Vehicle.Cabin.Seat.Row1.Pos2.IsBelted',
            'value': arg['Seat']['FrontRight']['IsSeatbeltOn']
        },
        # arg.Cabin.Seat.FrontRight.Recline
        {
            'path': 'Vehicle.Cabin.Seat.Row1.Pos2.Recline',
            'value': int(arg['Seat']['FrontRight']['Recline'])
        },
        # arg.Cabin.Seat.RearLeft.IsSeatbeltOn
        {
            'path': 'Vehicle.Cabin.Seat.Row2.Pos1.IsBelted',
            'value': arg['Seat']['RearLeft']['IsSeatbeltOn']
        },
        # arg.Cabin.Seat.RearLeft.Recline
        {
            'path': 'Vehicle.Cabin.Seat.Row2.Pos1.Recline',
            'value': int(arg['Seat']['RearLeft']['Recline'])
        },
        # arg.Cabin.Seat.RearRight.IsSeatbeltOn
        {
            'path': 'Vehicle.Cabin.Seat.Row2.Pos2.IsBelted',
            'value': arg['Seat']['RearRight']['IsSeatbeltOn']
        },
        # arg.Cabin.Seat.RearRight.Recline
        {
            'path': 'Vehicle.Cabin.Seat.Row2.Pos2.Recline',
            'value': int(arg['Seat']['RearRight']['Recline'])
        },
        # arg.Cabin.Sunroof.Position
        {
            'path': 'Vehicle.Cabin.Sunroof.Position',
            'value': int(arg['Sunroof']['Position'])
        }
    ]


def translate_drive_train(arg):
    return [
        # arg.DriveTrain.ADAS.ABS
        {
            'path': 'Vehicle.ADAS.ABS.IsEngaged',
            'value': arg['ADAS']['ABS']
        },
        # arg.DriveTrain.ADAS.SuspensionMode
        {
            'path': 'Vehicle.Private.ADAS.SuspensionMode',
            'value': arg['ADAS']['SuspensionMode']
        },
        # arg.DriveTrain.OBD.CoolantTemperature
        {
            'path': 'Vehicle.OBD.CoolantTemperature',
            'value': float(arg['OBD']['CoolantTemperature'])
        },
        # arg.DriveTrain.OBD.OilLevel
        {
            'path': 'Vehicle.Private.OBD.OilLevel',
            'value': float(arg['OBD']['OilLevel'])
        },
        # arg.DriveTrain.Tire.FrontLeft.Pressure
        {
            'path': 'Vehicle.Chassis.Axle.Row1.Wheel.Left.Tire.Pressure',
            'value': int(arg['Tire']['FrontLeft']['Pressure'])
        },
        # arg.DriveTrain.Tire.FrontRight.Pressure
        {
            'path': 'Vehicle.Chassis.Axle.Row1.Wheel.Right.Tire.Pressure',
            'value': int(arg['Tire']['FrontRight']['Pressure'])
        },
        # arg.DriveTrain.Tire.RearLeft.Pressure
        {
            'path': 'Vehicle.Chassis.Axle.Row2.Wheel.Left.Tire.Pressure',
            'value': int(arg['Tire']['RearLeft']['Pressure'])
        },
        # arg.DriveTrain.Tire.RearRight.Pressure
        {
            'path': 'Vehicle.Chassis.Axle.Row2.Wheel.Right.Tire.Pressure',
            'value': int(arg['Tire']['RearRight']['Pressure'])
        }
    ]


def translate_event(arg):
    return [
        # arg.Event.Accident
        {
            'path': 'Vehicle.Private.Event.Accident',
            'value': arg['Accident']
        },
        # arg.Event.Approaching.Front
        {
            'path': 'Vehicle.Private.Event.Approaching.Front',
            'value': arg['Approaching']['Front']
        },
        # arg.Event.Approaching.Rear
        {
            'path': 'Vehicle.Private.Event.Approaching.Rear',
            'value': arg['Approaching']['Rear']
        },
        # arg.Event.Approaching.RearLeft
        {
            'path': 'Vehicle.Private.Event.Approaching.RearLeft',
            'value': arg['Approaching']['RearLeft']
        },
        # arg.Event.Approaching.RearRight
        {
            'path': 'Vehicle.Private.Event.Approaching.RearRight',
            'value': arg['Approaching']['RearRight']
        },
        # arg.Event.Pedestrian
        {
            'path': 'Vehicle.Private.Event.Pedestrian',
            'value': arg['Pedestrian']
        },
        # arg.Event.RedLight
        {
            'path': 'Vehicle.Private.Event.RedLight',
            'value': arg['RedLight']
        },
        # arg.Event.Tire
        {
            'path': 'Vehicle.Private.Event.Tire',
            'value': arg['Tire']
        },
        # arg.Event.Unstable
        {
            'path': 'Vehicle.Private.Event.Unstable',
            'value': arg['Unstable']
        }
    ]


def translate_navigation(arg):
    return [
        # arg.Navigation.Curve.Direction
        {
            'path': 'Vehicle.Private.Navigation.Curve.Direction',
            'value': arg['Curve']['Direction']
        },
        # arg.Navigation.Curve.Level
        {
            'path': 'Vehicle.Private.Navigation.Curve.Level',
            'value': arg['Curve']['Level']
        },
        # arg.Navigation.SpeedLimit
        {
            'path': 'Vehicle.Private.Navigation.SpeedLimit',
            'value': float(arg['SpeedLimit'])
        },
        # arg.Navigation.Turn.Angle
        {
            'path': 'Vehicle.Private.Navigation.Turn.Angle',
            'value': float(arg['Turn']['Angle'])
        },
        # arg.Navigation.Turn.Direction
        {
            'path': 'Vehicle.Private.Navigation.Turn.Direction',
            'value': arg['Turn']['Direction']
        }
    ]


def translate_running_status(arg):
    return [
        # arg.RunningStatus.Acceleration.X
        {
            'path': 'Vehicle.Acceleration.Longitudinal',
            'value': float(arg['Acceleration']['X'])
        },
        # arg.RunningStatus.Acceleration.Y
        {
            'path': 'Vehicle.Acceleration.Lateral',
            'value': float(arg['Acceleration']['Y'])
        },
        # arg.RunningStatus.Acceleration.Z
        {
            'path': 'Vehicle.Acceleration.Vertical',
            'value': float(arg['Acceleration']['Z'])
        },
        # arg.RunningStatus.Accelerator.PedalPosition
        {
            'path': 'Vehicle.Chassis.Accelerator.PedalPosition',
            'value': int(arg['Accelerator']['PedalPosition'])
        },
        # arg.RunningStatus.Battery.Capacity
        {
            # 'path': 'Vehicle.Powertrain.Battery.GrossCapacity',
            # 'path': 'Vehicle.Powertrain.TractionBattery.GrossCapacity',
            'path': 'Vehicle.Powertrain.TractionBattery.StateOfCharge.Displayed',
            'value': float(arg['Battery']['Capacity'])
        },
        # arg.RunningStatus.Brake.PedalPosition
        {
            'path': 'Vehicle.Chassis.Brake.PedalPosition',
            'value': int(arg['Brake']['PedalPosition'])
        },
        # arg.RunningStatus.Engine.Speed
        {
            # 'path': 'Vehicle.Powertrain.CombustionEngine.Engine.Speed',
            # 'path': 'Vehicle.Powertrain.CombustionEngine.Speed',
            'path': 'Vehicle.OBD.EngineSpeed',
            'value': float(arg['Engine']['Speed'])
        },
        # arg.RunningStatus.Fuel.Level
        {
            'path': 'Vehicle.Powertrain.FuelSystem.Level',
            'value': int(arg['Fuel']['Level'])
        },
        # arg.RunningStatus.ParkingBrake.IsEngaged
        {
            'path': 'Vehicle.Chassis.ParkingBrake.IsEngaged',
            'value': arg['ParkingBrake']['IsEngaged']
        },
        # arg.RunningStatus.SteeringWheel.Angle
        {
            'path': 'Vehicle.Chassis.SteeringWheel.Angle',
            'value': int(arg['SteeringWheel']['Angle'])
        },
        # arg.RunningStatus.Transmission.Gear
        {
            'path': 'Vehicle.Powertrain.Transmission.Gear',
            'value': int(arg['Transmission']['Gear'])
        },
        # arg.RunningStatus.Vehicle.Speed
        {
            'path': 'Vehicle.Speed',
            'value': arg['Vehicle']['Speed'] / 1000.0
        }
    ]


def translate_geometry(arg):
    result = []
    if 'TrafficInfo' in arg:
        result += [
            # arg.geometry.TrafficInfo.Intersection
            {
                'path': 'Vehicle.Private.TrafficInfo.Intersection',
                'value': arg['TrafficInfo']['Intersection']
            },
            # arg.geometry.TrafficInfo.SegmentLane
            {
                'path': 'Vehicle.Private.TrafficInfo.SegmentLane',
                'value': arg['TrafficInfo']['SegmentLane']
            }
        ]

    return result + [
        # arg.geometry.coordinates.AltAccu
        {
            'path': 'Vehicle.CurrentLocation.Accuracy',
            'value': float(arg['coordinates']['AltAccu'])
        },
        # arg.geometry.coordinates.Altitude
        {
            'path': 'Vehicle.CurrentLocation.Altitude',
            'value': float(arg['coordinates']['Altitude'])
        },
        # arg.geometry.coordinates.Heading
        {
            'path': 'Vehicle.CurrentLocation.Heading',
            'value': float(arg['coordinates']['Heading'])
        },
        # arg.geometry.coordinates.HeadingAccu
        {
            'path': 'Vehicle.Private.geometry.coordinates.HeadingAccu',
            'value': float(arg['coordinates']['HeadingAccu'])
        },
        # arg.geometry.coordinates.HorizAccu
        {
            'path': 'Vehicle.Private.geometry.coordinates.HorizAccu',
            'value': float(arg['coordinates']['HorizAccu'])
        },
        # arg.geometry.coordinates.Latitude
        {
            'path': 'Vehicle.CurrentLocation.Latitude',
            'value': float(arg['coordinates']['Latitude'])
        },
        # arg.geometry.coordinates.Longitude
        {
            'path': 'Vehicle.CurrentLocation.Longitude',
            'value': float(arg['coordinates']['Longitude'])
        },
        # arg.geometry.coordinates.Speed
        {
            'path': 'Vehicle.Private.geometry.coordinates.Speed',
            'value': float(arg['coordinates']['Speed'])
        },
        # arg.geometry.coordinates.SpeedAccu
        {
            'path': 'Vehicle.Private.geometry.coordinates.SpeedAccu',
            'value': float(arg['coordinates']['SpeedAccu'])
        }
    ]


def translate(arg):
    result = []
    result += translate_body(arg['Body'])
    result += translate_cabin(arg['Cabin'])
    result += translate_drive_train(arg['DriveTrain'])
    result += translate_event(arg['Event'])
    result += translate_navigation(arg['Navigation'])
    result += translate_running_status(arg['RunningStatus'])
    result += translate_geometry(arg['geometry'])

    return result
