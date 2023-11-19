import os
import sys
import socket
import datetime
import time

FILE = os.path.join(os.getcwd(), "networkinfo.log")

def ping():
    try:
        socket.setdefaulttimeout(3)
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        host = "8.8.8.8"
        port = 53
        server_address = (host, port)
        s.connect(server_address)
    except OSError as error:
        return False
    else:
        s.close()
        return True

def calculate_time(start, stop):
    difference = stop - start
    seconds = float(str(difference.total_seconds()))
    return str(datetime.timedelta(seconds=seconds)).split(".")[0]

def first_check():
    if ping():
        live = "\nCONNECTION ACQUIRED\n"
        print(live)
        connection_acquired_time = datetime.datetime.now()
        acquiring_message = "connection acquired at: " + \
            str(connection_acquired_time).split(".")[0]
        print(acquiring_message)

        with open(FILE, "a") as file:
            file.write(live)
            file.write(acquiring_message)
        return True
    else:
        not_live = "\nCONNECTION NOT ACQUIRED\n"
        print(not_live)
        with open(FILE, "a") as file:
            file.write(not_live)
        return False

def main():
    monitor_start_time = datetime.datetime.now()
    monitoring_date_time = "monitoring started at: " + \
        str(monitor_start_time).split(".")[0]
    if first_check():
        print(monitoring_date_time)
    else:
        while True:
            if not ping():
                time.sleep(1)
            else:
                first_check()
                print(monitoring_date_time)
                break
    with open(FILE, "a") as file:
        file.write("\n")
        file.write(monitoring_date_time + "\n")
    while True:
        if ping():
            time.sleep(5)
        else:
            down_time = datetime.datetime.now()
            fail_msg = "disconnected at: " + str(down_time).split(".")[0]
            print(fail_msg)
            with open(FILE, "a") as file:
                file.write(fail_msg + "\n")
            while not ping():
                time.sleep(1)
            up_time = datetime.datetime.now()
            uptime_message = "connected again: " + str(up_time).split(".")[0]
            down_time = calculate_time(down_time, up_time)
            unavailability_time = "connection was unavailable for: " + down_time
            print(uptime_message)
            print(unavailability_time)
            with open(FILE, "a") as file:
                file.write(uptime_message + "\n")
                file.write(unavailability_time + "\n")
    