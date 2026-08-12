import subprocess
import re

out = subprocess.getoutput("netstat -ano")
ports = []
for line in out.splitlines():
    if "LISTENING" in line and ("127.0.0.1:" in line or "0.0.0.0:" in line):
        m = re.search(r':(\d+)\s+.*LISTENING', line)
        if m:
            ports.append(m.group(1))

print("Active listening ports:", sorted(set(ports)))
