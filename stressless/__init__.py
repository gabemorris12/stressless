from PyQt6.QtCore import QSettings, QStandardPaths, QCoreApplication

from .core import HopkinsonExperiment

# Set the application name and organization
QCoreApplication.setApplicationName("Stressless")
QCoreApplication.setOrganizationName("StandardMechanics")
QCoreApplication.setOrganizationDomain("standardmechanics.com")

# Initialize settings (stored based on the above metadata)
SETTINGS = QSettings()

# Define shared paths
LOG_PATH = QStandardPaths.writableLocation(QStandardPaths.StandardLocation.AppLocalDataLocation)
# CACHE_PATH = QStandardPaths.writableLocation(QStandardPaths.StandardLocation.CacheLocation)
# CONFIG_PATH = QStandardPaths.writableLocation(QStandardPaths.StandardLocation.ConfigLocation)

# Create directories if they don't exist (important for logging)
import os

os.makedirs(LOG_PATH, exist_ok=True)
# os.makedirs(CACHE_PATH, exist_ok=True)
# os.makedirs(CONFIG_PATH, exist_ok=True)

# Optionally clear settings for testing purposes
# SETTINGS.clear()
# SETTINGS.sync()
