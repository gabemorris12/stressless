import logging
import os
from pathlib import Path

# Import the QSettings and configure logging to have a log file
from PyQt6.QtCore import QSettings, QStandardPaths, QCoreApplication

from stressless.util.logger import logger, APP_NAME

# Set the application name and organization
QCoreApplication.setApplicationName("Stressless")
QCoreApplication.setOrganizationName("StandardMechanics")
QCoreApplication.setOrganizationDomain("standardmechanics.com")

# Initialize settings (stored based on the above metadata)
_SETTINGS = QSettings()

# Define shared paths
LOG_PATH = QStandardPaths.writableLocation(QStandardPaths.StandardLocation.AppLocalDataLocation)
# CACHE_PATH = QStandardPaths.writableLocation(QStandardPaths.StandardLocation.CacheLocation)
# CONFIG_PATH = QStandardPaths.writableLocation(QStandardPaths.StandardLocation.ConfigLocation)

os.makedirs(LOG_PATH, exist_ok=True)
# os.makedirs(CACHE_PATH, exist_ok=True)
# os.makedirs(CONFIG_PATH, exist_ok=True)

# Optionally clear settings for testing purposes
# SETTINGS.clear()
# SETTINGS.sync()

# Define the log directory and file
LOG_DIR = Path(LOG_PATH)
LOG_FILE = LOG_DIR/f"{APP_NAME.lower()}.log"

# Ensure the log directory exists
LOG_DIR.mkdir(parents=True, exist_ok=True)

# --- File Handler ---
file_handler = logging.FileHandler(LOG_FILE, mode='a')
file_handler.setLevel(logging.DEBUG)  # Log everything to the file

# Include timestamp and level in file log
file_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
file_handler.setFormatter(file_formatter)

# Add handler
logger.addHandler(file_handler)

# Example log message to verify setup
logger.debug("App initialized. Logs will be written to: %s", LOG_FILE)
