"""
Gunicorn configuration file
Usage: gunicorn -c gunicorn_config.py portfolio.wsgi
"""

import multiprocessing
import os

# Server socket
bind = "unix:/run/gunicorn/portfolio.sock"
backlog = 2048

# Worker processes
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "sync"
worker_connections = 1000
timeout = 30
keepalive = 2

# Logging
accesslog = "/home/portfolio/logs/gunicorn_access.log"
errorlog = "/home/portfolio/logs/gunicorn_error.log"
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Process naming
proc_name = 'portfolio-gunicorn'

# Server mechanics
daemon = False
pidfile = "/run/gunicorn/portfolio.pid"
umask = 0
user = None
group = None
tmp_upload_dir = None

# SSL (handled by Nginx, so disabled here)
keyfile = None
certfile = None

# Application
raw_env = []
